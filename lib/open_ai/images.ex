defmodule OpenAi.Images do
  @moduledoc "Client functions for image generation, edits, and variations."

  alias OpenAi.{Client, Multipart}

  @doc "Creates images from a prompt. `POST /images/generations`"
  @spec generate(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def generate(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/images/generations", Keyword.put(options, :body, body))
  end

  @spec stream_generation(Client.t(), map(), (map() -> term()), keyword()) ::
          {:ok, OpenAi.Response.t()} | {:error, OpenAi.Error.t()}
  def stream_generation(%Client{} = client, body, on_event, options \\ []) when is_map(body) do
    body = put_stream(body)

    Client.stream(
      client,
      :post,
      "/images/generations",
      on_event,
      Keyword.put(options, :body, body)
    )
  end

  @doc "Edits images from a JSON request. `POST /images/edits`"
  @spec edit(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def edit(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/images/edits", Keyword.put(options, :body, body))
  end

  @doc "Multipart form of `edit/3` for binary image uploads (same endpoint, not counted separately)."
  @spec edit_upload(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def edit_upload(%Client{} = client, params, options \\ []) when is_map(params) do
    multipart_request(client, "/images/edits", params, [:image, :mask], options)
  end

  @doc "Streams image edits from a multipart request, forcing `stream: true`."
  @spec stream_edit(Client.t(), map(), (map() -> term()), keyword()) ::
          {:ok, OpenAi.Response.t()} | {:error, OpenAi.Error.t()}
  def stream_edit(%Client{} = client, params, on_event, options \\ []) when is_map(params) do
    body = {:multipart, params |> put_stream() |> Multipart.put_files([:image, :mask])}
    Client.stream(client, :post, "/images/edits", on_event, Keyword.put(options, :body, body))
  end

  @doc "Creates image variations. `POST /images/variations`"
  @spec variation(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def variation(%Client{} = client, params, options \\ []) when is_map(params) do
    multipart_request(client, "/images/variations", params, [:image], options)
  end

  defp multipart_request(client, path, params, file_keys, options) do
    body = {:multipart, Multipart.put_files(params, file_keys)}
    Client.request(client, :post, path, Keyword.put(options, :body, body))
  end

  defp put_stream(body) do
    if Map.has_key?(body, "stream") do
      Map.put(body, "stream", true)
    else
      Map.put(body, :stream, true)
    end
  end
end
