defmodule OpenAi.Client do
  @moduledoc """
  Configurable HTTP client for the OpenAI REST API.

  Resource modules return decoded response bodies. Use `request_raw/4` when HTTP
  status, headers, or the `x-request-id` value are needed.
  """

  alias OpenAi.{Error, Response, SSE}

  @default_base_url "https://api.openai.com/v1"
  @retryable_statuses [408, 409, 429]

  @derive {Inspect, except: [:api_key, :requester, :streamer, :sleep]}
  @enforce_keys [:api_key]
  defstruct api_key: nil,
            organization: nil,
            project: nil,
            base_url: @default_base_url,
            finch: OpenAiFinch,
            headers: [],
            receive_timeout: 60_000,
            pool_timeout: 5_000,
            max_retries: 2,
            retry_base_delay: 250,
            retry_max_delay: 8_000,
            requester: nil,
            streamer: nil,
            sleep: nil

  @type t :: %__MODULE__{
          api_key: String.t(),
          organization: String.t() | nil,
          project: String.t() | nil,
          base_url: String.t(),
          finch: atom(),
          headers: [{String.t(), String.t()}],
          receive_timeout: non_neg_integer(),
          pool_timeout: non_neg_integer(),
          max_retries: non_neg_integer(),
          retry_base_delay: non_neg_integer(),
          retry_max_delay: non_neg_integer(),
          requester: function(),
          streamer: function(),
          sleep: function()
        }

  @type request_options :: [
          body: term(),
          query: map() | keyword(),
          headers: map() | [{String.t(), String.t()}],
          decode: boolean(),
          receive_timeout: non_neg_integer(),
          pool_timeout: non_neg_integer(),
          max_retries: non_neg_integer(),
          retry: boolean()
        ]

  @doc "Builds a client from options, application config, and environment variables."
  @spec new(keyword()) :: t()
  def new(options \\ []) do
    config = Application.get_all_env(:openai)
    legacy_retry = config[:retry_config] || %{}
    api_key = configured(options, config, :api_key, System.get_env("OPENAI_API_KEY"))
    default_base_url = System.get_env("OPENAI_BASE_URL") || @default_base_url
    validate_api_key!(api_key)

    %__MODULE__{
      api_key: api_key,
      organization:
        configured(
          options,
          config,
          :organization,
          config[:organization_key] || System.get_env("OPENAI_ORG_ID")
        ),
      project: configured(options, config, :project, System.get_env("OPENAI_PROJECT_ID")),
      base_url: configured(options, config, :base_url, default_base_url) |> String.trim_trailing("/"),
      finch: configured(options, config, :finch, OpenAiFinch),
      headers: configured(options, config, :headers, []) |> header_entries(),
      receive_timeout: configured(options, config, :receive_timeout, 60_000),
      pool_timeout: configured(options, config, :pool_timeout, 5_000),
      max_retries: configured(options, config, :max_retries, legacy_retry[:retries] || 2),
      retry_base_delay: configured(options, config, :retry_base_delay, legacy_retry[:delay] || 250),
      retry_max_delay: configured(options, config, :retry_max_delay, 8_000),
      requester: configured(options, config, :requester, &__MODULE__.default_requester/3),
      streamer: configured(options, config, :streamer, &__MODULE__.default_streamer/5),
      sleep: configured(options, config, :sleep, &Process.sleep/1)
    }
  end

  @doc "Performs a request and returns its decoded body."
  @spec request(t(), atom(), String.t(), request_options()) :: {:ok, term()} | {:error, Error.t()}
  def request(%__MODULE__{} = client, method, path, options \\ []) do
    case request_raw(client, method, path, options) do
      {:ok, %Response{body: body}} -> {:ok, body}
      {:error, %Error{} = error} -> {:error, error}
    end
  end

  @doc "Performs a request and raises `OpenAi.Error` when it fails."
  @spec request!(t(), atom(), String.t(), request_options()) :: term()
  def request!(%__MODULE__{} = client, method, path, options \\ []) do
    case request(client, method, path, options) do
      {:ok, body} -> body
      {:error, %Error{} = error} -> raise error
    end
  end

  @doc "Performs a request and retains HTTP response metadata."
  @spec request_raw(t(), atom(), String.t(), request_options()) ::
          {:ok, Response.t()} | {:error, Error.t()}
  def request_raw(%__MODULE__{} = client, method, path, options \\ []) do
    with {:ok, request} <- build_request(client, method, path, options),
         {:ok, response} <- perform_request(client, request, options, 0) do
      parse_response(response, options)
    end
  end

  @doc "Builds a Finch request. Useful for custom transports and request inspection."
  @spec build_request(t(), atom(), String.t(), request_options()) ::
          {:ok, Finch.Request.t()} | {:error, Error.t()}
  def build_request(%__MODULE__{} = client, method, path, options \\ []) do
    with {:ok, body, body_headers} <- encode_body(Keyword.get(options, :body)) do
      headers = build_headers(client, path, body_headers, Keyword.get(options, :headers, []))
      url = build_url(client.base_url, path, Keyword.get(options, :query, []))
      {:ok, Finch.build(method, url, headers, body)}
    end
  end

  @doc "Streams decoded server-sent event maps to a one-argument callback."
  @spec stream(t(), atom(), String.t(), (map() -> term()), request_options()) ::
          {:ok, Response.t()} | {:error, Error.t()}
  def stream(%__MODULE__{} = client, method, path, on_event, options \\ [])
      when is_function(on_event, 1) do
    options = put_request_header(options, "accept", "text/event-stream")

    with {:ok, request} <- build_request(client, method, path, options),
         {:ok, state} <-
           client.streamer.(
             request,
             client.finch,
             stream_state(),
             &stream_chunk(&1, &2, on_event),
             request_options(client, options)
           ) do
      finish_stream(state, on_event)
    else
      {:error, %Error{} = error} -> {:error, error}
      {:error, cause} -> {:error, Error.transport(cause)}
    end
  end

  @doc "Percent-encodes a value for use as one URL path segment."
  @spec path_segment(term()) :: String.t()
  def path_segment(value), do: URI.encode(to_string(value), &URI.char_unreserved?/1)

  @doc false
  def default_requester(request, finch, options), do: Finch.request(request, finch, options)

  @doc false
  def default_streamer(request, finch, acc, callback, options),
    do: Finch.stream(request, finch, acc, callback, options)

  defp perform_request(client, request, options, attempt) do
    result = client.requester.(request, client.finch, request_options(client, options))
    max_retries = effective_max_retries(client, options)

    if retry?(result) and attempt < max_retries do
      delay = retry_delay(client, result, attempt)
      client.sleep.(delay)
      perform_request(client, request, options, attempt + 1)
    else
      case result do
        {:ok, %Finch.Response{} = response} -> {:ok, response}
        {:error, cause} -> {:error, Error.transport(cause)}
      end
    end
  end

  defp parse_response(%Finch.Response{} = response, options) do
    metadata = %Response{
      status: response.status,
      headers: response.headers,
      body: response.body,
      request_id: response_header(response.headers, "x-request-id")
    }

    case decode_response(metadata, options) do
      {:ok, decoded} when response.status in 200..299 -> {:ok, decoded}
      {:ok, decoded} -> {:error, Error.from_response(decoded)}
      {:error, %Error{} = error} -> {:error, error}
    end
  end

  defp decode_response(%Response{body: body} = response, options) do
    decode? = Keyword.get(options, :decode, true)
    content_type = Response.header(response, "content-type") || ""
    json? = String.contains?(String.downcase(content_type), "json")
    error_status? = response.status not in 200..299

    cond do
      body in [nil, ""] ->
        {:ok, %{response | body: nil}}

      (decode? and json?) or error_status? ->
        decode_json(response, error_status?)

      true ->
        {:ok, response}
    end
  end

  defp decode_json(%Response{body: body} = response, error_status?) do
    case Jason.decode(body) do
      {:ok, decoded} -> {:ok, %{response | body: decoded}}
      {:error, _cause} when error_status? -> {:ok, response}
      {:error, cause} -> {:error, Error.decoding(response, cause)}
    end
  end

  defp retry?({:error, _cause}), do: true

  defp retry?({:ok, %Finch.Response{status: status, headers: headers}}) do
    case response_header(headers, "x-should-retry") do
      "true" -> true
      "false" -> false
      _ -> status in @retryable_statuses or status in 500..599
    end
  end

  defp effective_max_retries(client, options) do
    cond do
      Keyword.get(options, :retry) == false -> 0
      streaming_body?(Keyword.get(options, :body)) and Keyword.get(options, :retry) != true -> 0
      true -> Keyword.get(options, :max_retries, client.max_retries)
    end
  end

  defp streaming_body?({:multipart, _multipart}), do: true
  defp streaming_body?({:stream, _enumerable}), do: true
  defp streaming_body?(_body), do: false

  defp retry_delay(client, {:ok, %Finch.Response{headers: headers}}, attempt) do
    case retry_after(headers) do
      nil -> exponential_delay(client, attempt)
      delay -> min(delay, client.retry_max_delay)
    end
  end

  defp retry_delay(client, _result, attempt), do: exponential_delay(client, attempt)

  defp retry_after(headers) do
    with nil <- parse_non_negative_integer(response_header(headers, "retry-after-ms")),
         seconds when is_integer(seconds) <- parse_non_negative_integer(response_header(headers, "retry-after")) do
      seconds * 1_000
    end
  end

  defp parse_non_negative_integer(nil), do: nil

  defp parse_non_negative_integer(value) do
    case Integer.parse(value) do
      {integer, ""} when integer >= 0 -> integer
      _ -> nil
    end
  end

  defp exponential_delay(client, attempt) do
    ceiling = min(client.retry_base_delay * Integer.pow(2, attempt), client.retry_max_delay)
    if ceiling == 0, do: 0, else: :rand.uniform(ceiling + 1) - 1
  end

  defp encode_body(nil), do: {:ok, nil, []}

  defp encode_body({:multipart, fields}) when is_map(fields) or is_list(fields) do
    multipart = OpenAi.Multipart.build(fields)
    body = {:stream, Multipart.body_stream(multipart)}

    headers = [
      {"content-type", Multipart.content_type(multipart, "multipart/form-data")},
      {"content-length", to_string(Multipart.content_length(multipart))}
    ]

    {:ok, body, headers}
  end

  defp encode_body({:stream, _enumerable} = body), do: {:ok, body, []}
  defp encode_body(body) when is_binary(body), do: {:ok, body, []}

  defp encode_body(body) when is_map(body) or is_list(body) do
    case Jason.encode(body) do
      {:ok, encoded} -> {:ok, encoded, [{"content-type", "application/json"}]}
      {:error, cause} -> {:error, Error.encoding(cause)}
    end
  end

  defp build_headers(client, path, body_headers, request_headers) do
    base = [
      {"authorization", "Bearer #{client.api_key}"},
      {"user-agent", "openai-elixir/#{Application.spec(:openai, :vsn)}"},
      {"accept", "application/json"},
      {"openai-organization", client.organization},
      {"openai-project", client.project},
      {"openai-beta", beta_header(path)}
    ]

    [base, client.headers, body_headers, header_entries(request_headers)]
    |> List.flatten()
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
    |> Enum.reduce(%{}, fn {key, value}, headers ->
      Map.put(headers, String.downcase(to_string(key)), to_string(value))
    end)
    |> Map.to_list()
  end

  # Assistants/Threads and ChatKit endpoints reject requests without their beta opt-in.
  defp beta_header("/" <> path), do: beta_header(path)
  defp beta_header("assistants" <> _rest), do: "assistants=v2"
  defp beta_header("threads" <> _rest), do: "assistants=v2"
  defp beta_header("chatkit" <> _rest), do: "chatkit_beta=v1"
  defp beta_header(_path), do: nil

  defp build_url(base_url, path, query) do
    path = "/" <> String.trim_leading(path, "/")
    path = URI.encode(path, &path_character?/1)
    encoded_query = encode_query(query)

    cond do
      encoded_query == "" -> base_url <> path
      String.contains?(path, "?") -> base_url <> path <> "&" <> encoded_query
      true -> base_url <> path <> "?" <> encoded_query
    end
  end

  defp path_character?(character) do
    URI.char_unreserved?(character) or character in ~c"/:@!$&'()*+,;=%?"
  end

  defp encode_query(query) do
    query
    |> query_entries()
    |> Enum.map_join("&", fn {key, value} ->
      URI.encode_www_form(key) <> "=" <> URI.encode_www_form(query_value(value))
    end)
  end

  defp query_entries(query) when is_map(query) do
    query
    |> Enum.sort_by(fn {key, _value} -> to_string(key) end)
    |> Enum.flat_map(fn {key, value} -> flatten_query(to_string(key), value) end)
  end

  defp query_entries(query) when is_list(query) do
    Enum.flat_map(query, fn {key, value} -> flatten_query(to_string(key), value) end)
  end

  defp query_entries(nil), do: []

  defp flatten_query(_key, nil), do: []

  defp flatten_query(key, value) when is_map(value) do
    value
    |> Enum.sort_by(fn {nested_key, _value} -> to_string(nested_key) end)
    |> Enum.flat_map(fn {nested_key, nested_value} ->
      flatten_query("#{key}[#{nested_key}]", nested_value)
    end)
  end

  defp flatten_query(key, value) when is_list(value) do
    key = if String.ends_with?(key, "[]"), do: key, else: key <> "[]"
    Enum.flat_map(value, &flatten_query(key, &1))
  end

  defp flatten_query(key, value), do: [{key, value}]

  defp query_value(value) when is_binary(value), do: value
  defp query_value(value), do: to_string(value)

  defp request_options(client, options) do
    [
      receive_timeout: Keyword.get(options, :receive_timeout, client.receive_timeout),
      pool_timeout: Keyword.get(options, :pool_timeout, client.pool_timeout)
    ]
  end

  defp header_entries(headers) when is_map(headers), do: Map.to_list(headers)
  defp header_entries(headers) when is_list(headers), do: headers

  defp put_request_header(options, key, value) do
    headers = options |> Keyword.get(:headers, []) |> header_entries() |> Map.new()
    Keyword.put(options, :headers, Map.put(headers, key, value))
  end

  defp response_header(headers, name) do
    name = String.downcase(name)

    Enum.find_value(headers, fn {key, value} ->
      if String.downcase(key) == name, do: value
    end)
  end

  defp stream_state do
    %{status: nil, headers: [], parser: SSE.new(), error_body: [], parse_error: nil}
  end

  defp stream_chunk({:status, status}, state, _on_event), do: %{state | status: status}
  defp stream_chunk({:headers, headers}, state, _on_event), do: %{state | headers: state.headers ++ headers}

  defp stream_chunk({:data, data}, %{status: status} = state, on_event) when status in 200..299 do
    {parser, events} = SSE.feed(state.parser, data)
    dispatch_events(%{state | parser: parser}, events, on_event)
  end

  defp stream_chunk({:data, data}, state, _on_event), do: %{state | error_body: [data | state.error_body]}

  defp dispatch_events(state, events, on_event) do
    Enum.reduce(events, state, &dispatch_event(&1, &2, on_event))
  end

  defp dispatch_event(_event, %{parse_error: error} = state, _on_event) when not is_nil(error), do: state

  defp dispatch_event(event, state, on_event) do
    case decode_event(event) do
      :done ->
        state

      {:ok, decoded} ->
        on_event.(decoded)
        state

      {:error, error} ->
        %{state | parse_error: error}
    end
  end

  defp decode_event(%SSE.Event{data: "[DONE]"}), do: :done
  defp decode_event(%SSE.Event{data: ""}), do: :done

  defp decode_event(%SSE.Event{} = event) do
    case Jason.decode(event.data) do
      {:ok, decoded} when is_map(decoded) and not is_nil(event.event) ->
        {:ok, Map.put_new(decoded, "type", event.event)}

      {:ok, decoded} ->
        {:ok, decoded}

      {:error, cause} ->
        {:error, Error.stream("OpenAI returned invalid JSON in an SSE event", cause)}
    end
  end

  defp finish_stream(%{status: status} = state, on_event) when status in 200..299 do
    {_parser, trailing_events} = SSE.finish(state.parser)
    state = dispatch_events(state, trailing_events, on_event)

    if state.parse_error do
      {:error, state.parse_error}
    else
      {:ok,
       %Response{
         status: status,
         headers: state.headers,
         body: nil,
         request_id: response_header(state.headers, "x-request-id")
       }}
    end
  end

  defp finish_stream(%{status: status} = state, _on_event) when is_integer(status) do
    response = %Finch.Response{
      status: status,
      headers: state.headers,
      body: state.error_body |> Enum.reverse() |> IO.iodata_to_binary()
    }

    case parse_response(response, []) do
      {:error, error} -> {:error, error}
      {:ok, response} -> {:ok, response}
    end
  end

  defp finish_stream(_state, _on_event),
    do: {:error, Error.stream("OpenAI stream ended before an HTTP status was received")}

  defp configured(options, config, key, default) do
    Keyword.get(options, key) || Keyword.get(config, key) || default
  end

  defp validate_api_key!(api_key) when is_binary(api_key) and api_key != "", do: :ok

  defp validate_api_key!(_api_key) do
    raise ArgumentError,
          "OpenAI API key is missing; pass :api_key, configure :openai, or set OPENAI_API_KEY"
  end
end
