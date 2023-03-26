defmodule OpenAi.Core.Client do
  defmacro __using__(_opts) do
    quote do
      def request_builder(method, path, body, params) do
        full_url = api_url() <> api_path() <> path

        headers = [
          {"OpenAI-Organization", get_organization()},
          {"Authorization", "Bearer #{api_key()}"},
          {"Content-Type", "application/json"}
        ]

        Finch.build(method, full_url, headers, body, params)
      end

      defp get_organization do
        case Application.get_env(:openai, :organization_key) do
          nil -> raise "OpenAI Organization key is not set"
          organization_key -> organization_key
        end
      end

      defp api_key do
        case Application.get_env(:openai, :api_key) do
          nil -> raise "OpenAI API key is not set"
          api_key -> api_key
        end
      end

      defp api_url, do: "https://api.openai.com"

      import(OpenAi.Core.Client, only: [scope: 1, get: 3, post: 3, stream: 6])
    end
  end

  @doc false
  defmacro scope(path) do
    quote do
      def api_path, do: unquote(path)
    end
  end

  defmacro get(path, body, params) do
    quote do
      request_builder(:get, unquote(path), unquote(body), unquote(params))
      |> Finch.request(OpenAiFinch)
    end
  end

  defmacro post(path, body, params) do
    quote do
      request_builder(:post, unquote(path), unquote(body), unquote(params))
      |> Finch.request(OpenAiFinch)
    end
  end

  defmacro stream(method, path, body, params, acc, callback) do
    quote do
      request_builder(unquote(method), unquote(path), unquote(body), unquote(params))
      |> Finch.stream(OpenAiFinch, unquote(acc), unquote(callback))
    end
  end
end
