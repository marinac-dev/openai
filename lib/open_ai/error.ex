defmodule OpenAi.Error do
  @moduledoc """
  A normalized OpenAI API, transport, or response decoding error.
  """

  alias OpenAi.Response

  defexception [
    :message,
    :status,
    :type,
    :param,
    :code,
    :request_id,
    :headers,
    :body,
    :cause,
    kind: :api
  ]

  @type t :: %__MODULE__{
          message: String.t(),
          status: non_neg_integer() | nil,
          type: String.t() | nil,
          param: String.t() | nil,
          code: String.t() | nil,
          request_id: String.t() | nil,
          headers: [{String.t(), String.t()}] | nil,
          body: term(),
          cause: term(),
          kind: :api | :transport | :encoding | :decoding | :stream | :webhook
        }

  @doc false
  @spec from_response(Response.t()) :: t()
  def from_response(%Response{} = response) do
    details = error_details(response.body)

    %__MODULE__{
      message: details["message"] || "OpenAI API request failed with status #{response.status}",
      status: response.status,
      type: details["type"],
      param: details["param"],
      code: stringify(details["code"]),
      request_id: response.request_id,
      headers: response.headers,
      body: response.body,
      kind: :api
    }
  end

  @doc false
  @spec transport(term()) :: t()
  def transport(cause) do
    %__MODULE__{
      message: "OpenAI request failed: #{Exception.format_banner(:error, cause)}",
      cause: cause,
      kind: :transport
    }
  end

  @doc false
  @spec encoding(term()) :: t()
  def encoding(cause) do
    %__MODULE__{
      message: "Could not encode OpenAI request body: #{Exception.message(cause)}",
      cause: cause,
      kind: :encoding
    }
  end

  @doc false
  @spec decoding(Response.t(), term()) :: t()
  def decoding(%Response{} = response, cause) do
    %__MODULE__{
      message: "OpenAI returned invalid JSON: #{Exception.message(cause)}",
      status: response.status,
      request_id: response.request_id,
      headers: response.headers,
      body: response.body,
      cause: cause,
      kind: :decoding
    }
  end

  @doc false
  @spec stream(String.t(), term()) :: t()
  def stream(message, cause \\ nil) do
    %__MODULE__{message: message, cause: cause, kind: :stream}
  end

  defp error_details(%{"error" => error}) when is_map(error), do: error
  defp error_details(error) when is_map(error), do: error
  defp error_details(_body), do: %{}

  defp stringify(nil), do: nil
  defp stringify(value) when is_binary(value), do: value
  defp stringify(value), do: to_string(value)
end
