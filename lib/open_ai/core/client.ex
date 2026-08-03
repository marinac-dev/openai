defmodule OpenAi.Core.Client do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      @doc false
      def request(method, path, body, headers, params) do
        full_url = api_url() <> api_path() <> path

        base = %{
          "Authorization" => api_key(),
          "Content-Type" => "application/json"
        }

        base =
          case get_organization() do
            nil -> base
            organization -> Map.put(base, "OpenAI-Organization", organization)
          end

        headers = Map.merge(base, headers) |> Map.to_list()

        Finch.build(method, full_url, headers, body, params)
      end

      def request_with_retry(request_builder_fn, retry_config \\ retry_config())

      def request_with_retry(request_builder_fn, %{retries: retries, delay: delay}) do
        case request_builder_fn.() do
          {:ok, response} ->
            {:ok, response}

          {:error, error} ->
            if retries > 0 do
              :timer.sleep(delay)
              request_with_retry(request_builder_fn, %{retries: retries - 1, delay: delay * 2})
            else
              {:error, error}
            end
        end
      end

      def request_with_retry(request_builder_fn, _), do: request_builder_fn.()

      defp retry_config do
        case Application.get_env(:openai, :retry_config) do
          nil -> %{}
          retry_config -> retry_config
        end
      end

      defp get_organization do
        Application.get_env(:openai, :organization) ||
          Application.get_env(:openai, :organization_key)
      end

      defp api_key do
        case Application.get_env(:openai, :api_key) do
          nil -> raise "OpenAI API key is not set"
          api_key -> "Bearer #{api_key}"
        end
      end

      defp api_url, do: unquote(__MODULE__).legacy_api_url()

      import OpenAi.Core.Client
    end
  end

  @doc false
  @spec legacy_api_url() :: String.t()
  def legacy_api_url do
    :openai
    |> Application.get_env(:base_url, System.get_env("OPENAI_BASE_URL") || "https://api.openai.com/v1")
    |> String.trim_trailing("/")
    |> String.trim_trailing("/v1")
  end

  @doc false
  defmacro scope(path) do
    quote do
      def api_path, do: unquote(path)
    end
  end

  defmacro get(path, body, headers, params) do
    quote do
      request_with_retry(fn ->
        request(:get, unquote(path), unquote(body), unquote(headers), unquote(params))
        |> Finch.request(OpenAiFinch)
      end)
    end
  end

  defmacro post(path, body, headers, params) do
    quote do
      request_with_retry(fn ->
        request(:post, unquote(path), unquote(body), unquote(headers), unquote(params))
        |> Finch.request(OpenAiFinch)
      end)
    end
  end

  defmacro delete(path, body, headers, params) do
    quote do
      request_with_retry(fn ->
        request(:delete, unquote(path), unquote(body), unquote(headers), unquote(params))
        |> Finch.request(OpenAiFinch)
      end)
    end
  end

  defmacro stream(method, path, body, params, acc, callback) do
    quote do
      request_with_retry(fn ->
        request(unquote(method), unquote(path), unquote(body), %{}, unquote(params))
        |> Finch.stream(OpenAiFinch, unquote(acc), unquote(callback))
      end)
    end
  end
end
