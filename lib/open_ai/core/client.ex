defmodule OpenAi.Core.Client do
  defmacro __using__(_opts) do
    quote do
      @doc false
      def request_builder(method, path, body, headers, params) do
        full_url = api_url() <> api_path() <> path

        base = %{
          "OpenAI-Organization" => get_organization(),
          "Authorization" => api_key(),
          "Content-Type" => "application/json"
        }

        headers = Map.merge(base, headers) |> Map.to_list()

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
          api_key -> "Bearer #{api_key}"
        end
      end

      defp api_url, do: "https://api.openai.com"

      import OpenAi.Core.Client
    end
  end

  @doc false
  defmacro scope(path) do
    quote do
      def api_path, do: unquote(path)
    end
  end

  defmacro get(path, body, headers, params) do
    quote do
      request_builder(:get, unquote(path), unquote(body), unquote(headers), unquote(params))
      |> Finch.request(OpenAiFinch)
    end
  end

  defmacro post(path, body, headers, params) do
    quote do
      request_builder(:post, unquote(path), unquote(body), unquote(headers), unquote(params))
      |> Finch.request(OpenAiFinch)
    end
  end

  defmacro delete(path, body, headers, params) do
    quote do
      request_builder(:delete, unquote(path), unquote(body), unquote(headers), unquote(params))
      |> Finch.request(OpenAiFinch)
    end
  end

  defmacro stream(method, path, body, params, acc, callback) do
    quote do
      request_builder(unquote(method), unquote(path), unquote(body), %{}, unquote(params))
      |> Finch.stream(OpenAiFinch, unquote(acc), unquote(callback))
    end
  end
end
