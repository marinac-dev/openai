defmodule OpenAi.Response do
  @moduledoc """
  The HTTP metadata and decoded body returned by `OpenAi.Client.request_raw/4`.
  """

  @enforce_keys [:status, :headers]
  defstruct [:status, :headers, :body, :request_id]

  @type t :: %__MODULE__{
          status: non_neg_integer(),
          headers: [{String.t(), String.t()}],
          body: term(),
          request_id: String.t() | nil
        }

  @doc "Returns a response header using a case-insensitive name comparison."
  @spec header(t(), String.t()) :: String.t() | nil
  def header(%__MODULE__{headers: headers}, name) do
    name = String.downcase(name)

    Enum.find_value(headers, fn {key, value} ->
      if String.downcase(key) == name, do: value
    end)
  end
end
