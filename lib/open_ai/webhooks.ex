defmodule OpenAi.Webhooks do
  @moduledoc """
  Verifies and decodes OpenAI webhook deliveries (Standard Webhooks signatures).

  Event types: `batch.cancelled`, `batch.completed`, `batch.expired`, `batch.failed`,
  `eval.run.canceled`, `eval.run.failed`, `eval.run.succeeded`, `fine_tuning.job.cancelled`,
  `fine_tuning.job.failed`, `fine_tuning.job.succeeded`, `live.call.incoming`,
  `realtime.call.incoming`, `response.cancelled`, `response.completed`, `response.failed`,
  `response.incomplete`.

  The signature covers the exact raw request body, so it must be captured before JSON parsing. With
  Plug, configure `Plug.Parsers` with a `body_reader` that stores the raw body in `conn.assigns`
  (or `conn.private`), then call `OpenAi.Webhooks.unwrap(raw_body, conn.req_headers)`.

  The secret defaults to `config :openai, :webhook_secret` or the `OPENAI_WEBHOOK_SECRET`
  environment variable.
  """

  alias OpenAi.Error

  @default_tolerance 300

  @type headers :: [{String.t(), String.t()}] | %{optional(String.t()) => String.t()}

  @doc "Verifies the signature and timestamp of a webhook payload."
  @spec verify(binary(), headers(), String.t() | nil, keyword()) :: :ok | {:error, Error.t()}
  def verify(payload, headers, secret \\ nil, opts \\ []) when is_binary(payload) do
    key = secret |> resolve_secret() |> decode_secret()
    headers = normalize_headers(headers)

    with {:ok, id} <- fetch_header(headers, "webhook-id"),
         {:ok, timestamp} <- fetch_header(headers, "webhook-timestamp"),
         {:ok, signature} <- fetch_header(headers, "webhook-signature"),
         :ok <- check_timestamp(timestamp, opts) do
      check_signature(key, "#{id}.#{timestamp}.#{payload}", signature)
    end
  end

  @doc "Verifies a webhook payload and decodes it into an event map."
  @spec unwrap(binary(), headers(), String.t() | nil, keyword()) :: {:ok, map()} | {:error, Error.t()}
  def unwrap(payload, headers, secret \\ nil, opts \\ []) when is_binary(payload) do
    with :ok <- verify(payload, headers, secret, opts) do
      case Jason.decode(payload) do
        {:ok, event} -> {:ok, event}
        {:error, cause} -> {:error, error("Webhook payload is not valid JSON", cause)}
      end
    end
  end

  defp resolve_secret(nil) do
    Application.get_env(:openai, :webhook_secret) || System.get_env("OPENAI_WEBHOOK_SECRET") ||
      raise ArgumentError,
            "missing webhook secret: pass one or set :webhook_secret / OPENAI_WEBHOOK_SECRET"
  end

  defp resolve_secret(secret) when is_binary(secret), do: secret

  defp decode_secret("whsec_" <> encoded) do
    case Base.decode64(encoded) do
      {:ok, key} -> key
      :error -> raise ArgumentError, "webhook secret is not valid base64"
    end
  end

  defp decode_secret(secret), do: secret

  defp normalize_headers(headers) do
    Map.new(headers, fn {name, value} -> {String.downcase(to_string(name)), value} end)
  end

  defp fetch_header(headers, name) do
    case Map.get(headers, name) do
      value when is_binary(value) and value != "" -> {:ok, value}
      _ -> {:error, error("Missing required webhook header: #{name}")}
    end
  end

  defp check_timestamp(timestamp, opts) do
    tolerance = Keyword.get(opts, :tolerance, @default_tolerance)
    now = Keyword.get_lazy(opts, :now, fn -> System.os_time(:second) end)

    case Integer.parse(timestamp) do
      {seconds, ""} when seconds < now - tolerance -> {:error, error("Webhook timestamp is too old")}
      {seconds, ""} when seconds > now + tolerance -> {:error, error("Webhook timestamp is too new")}
      {_seconds, ""} -> :ok
      _ -> {:error, error("Invalid webhook timestamp")}
    end
  end

  defp check_signature(key, content, header) do
    expected = :crypto.mac(:hmac, :sha256, key, content) |> Base.encode64()

    matched? =
      header
      |> String.split(" ", trim: true)
      |> Enum.any?(fn
        "v1," <> signature -> byte_size(signature) == byte_size(expected) and :crypto.hash_equals(signature, expected)
        _ -> false
      end)

    if matched?, do: :ok, else: {:error, error("No matching webhook signature found")}
  end

  defp error(message, cause \\ nil), do: %Error{kind: :webhook, message: message, cause: cause}
end
