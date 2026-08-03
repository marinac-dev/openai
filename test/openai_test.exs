defmodule OpenAiTest do
  use ExUnit.Case, async: true

  test "builds an explicit client" do
    client = OpenAi.client(api_key: "test-key", organization: "org_123", project: "proj_123")

    assert client.api_key == "test-key"
    assert client.organization == "org_123"
    assert client.project == "proj_123"
    refute inspect(client) =~ "test-key"
  end
end
