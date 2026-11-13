defmodule OpenAi.URLConfigTest do
  use ExUnit.Case, async: false

  alias OpenAi.Client

  setup do
    original_environment = System.get_env("OPENAI_BASE_URL")
    original_config = Application.get_env(:openai, :base_url)
    Application.delete_env(:openai, :base_url)

    on_exit(fn ->
      restore_environment("OPENAI_BASE_URL", original_environment)
      restore_config(:base_url, original_config)
    end)

    :ok
  end

  test "uses OPENAI_BASE_URL and trims its trailing slash" do
    System.put_env("OPENAI_BASE_URL", "https://gateway.example/openai/v1/")

    client = Client.new(api_key: "test-key")
    assert client.base_url == "https://gateway.example/openai/v1"

    assert {:ok, request} = Client.build_request(client, :get, "/models")
    assert request.host == "gateway.example"
    assert request.path == "/openai/v1/models"
  end

  test "an explicit base URL takes precedence over the environment" do
    System.put_env("OPENAI_BASE_URL", "https://environment.example/v1")
    client = Client.new(api_key: "test-key", base_url: "https://explicit.example/api/")

    assert client.base_url == "https://explicit.example/api"
  end

  defp restore_environment(name, nil), do: System.delete_env(name)
  defp restore_environment(name, value), do: System.put_env(name, value)

  defp restore_config(key, nil), do: Application.delete_env(:openai, key)
  defp restore_config(key, value), do: Application.put_env(:openai, key, value)
end
