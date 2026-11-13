defmodule OpenAi.AdminOrgTest do
  use ExUnit.Case, async: true

  alias OpenAi.Client

  @cases [
    {OpenAi.Admin.AdminApiKeys, :list, [], :q, :get, "/v1/organization/admin_api_keys"},
    {OpenAi.Admin.AdminApiKeys, :create, [], :b, :post, "/v1/organization/admin_api_keys"},
    {OpenAi.Admin.AdminApiKeys, :retrieve, ["a b"], :n, :get, "/v1/organization/admin_api_keys/a%20b"},
    {OpenAi.Admin.AdminApiKeys, :delete, ["a b"], :n, :delete, "/v1/organization/admin_api_keys/a%20b"},
    {OpenAi.Admin.AuditLogs, :list, [], :q, :get, "/v1/organization/audit_logs"},
    {OpenAi.Admin.Certificates, :list, [], :q, :get, "/v1/organization/certificates"},
    {OpenAi.Admin.Certificates, :create, [], :b, :post, "/v1/organization/certificates"},
    {OpenAi.Admin.Certificates, :activate, [], :b, :post, "/v1/organization/certificates/activate"},
    {OpenAi.Admin.Certificates, :deactivate, [], :b, :post, "/v1/organization/certificates/deactivate"},
    {OpenAi.Admin.Certificates, :retrieve, ["a b"], :q, :get, "/v1/organization/certificates/a%20b"},
    {OpenAi.Admin.Certificates, :update, ["a b"], :b, :post, "/v1/organization/certificates/a%20b"},
    {OpenAi.Admin.Certificates, :delete, ["a b"], :n, :delete, "/v1/organization/certificates/a%20b"},
    {OpenAi.Admin.Costs, :retrieve, [], :q, :get, "/v1/organization/costs"},
    {OpenAi.Admin.DataRetention, :retrieve, [], :n, :get, "/v1/organization/data_retention"},
    {OpenAi.Admin.DataRetention, :update, [], :b, :post, "/v1/organization/data_retention"},
    {OpenAi.Admin.Groups, :list, [], :q, :get, "/v1/organization/groups"},
    {OpenAi.Admin.Groups, :create, [], :b, :post, "/v1/organization/groups"},
    {OpenAi.Admin.Groups, :retrieve, ["a b"], :n, :get, "/v1/organization/groups/a%20b"},
    {OpenAi.Admin.Groups, :update, ["a b"], :b, :post, "/v1/organization/groups/a%20b"},
    {OpenAi.Admin.Groups, :delete, ["a b"], :n, :delete, "/v1/organization/groups/a%20b"},
    {OpenAi.Admin.Groups.Roles, :list, ["a b"], :q, :get, "/v1/organization/groups/a%20b/roles"},
    {OpenAi.Admin.Groups.Roles, :create, ["a b"], :b, :post, "/v1/organization/groups/a%20b/roles"},
    {OpenAi.Admin.Groups.Roles, :retrieve, ["a b", "a b"], :n, :get, "/v1/organization/groups/a%20b/roles/a%20b"},
    {OpenAi.Admin.Groups.Roles, :delete, ["a b", "a b"], :n, :delete, "/v1/organization/groups/a%20b/roles/a%20b"},
    {OpenAi.Admin.Groups.Users, :list, ["a b"], :q, :get, "/v1/organization/groups/a%20b/users"},
    {OpenAi.Admin.Groups.Users, :create, ["a b"], :b, :post, "/v1/organization/groups/a%20b/users"},
    {OpenAi.Admin.Groups.Users, :retrieve, ["a b", "a b"], :n, :get, "/v1/organization/groups/a%20b/users/a%20b"},
    {OpenAi.Admin.Groups.Users, :delete, ["a b", "a b"], :n, :delete, "/v1/organization/groups/a%20b/users/a%20b"},
    {OpenAi.Admin.Invites, :list, [], :q, :get, "/v1/organization/invites"},
    {OpenAi.Admin.Invites, :create, [], :b, :post, "/v1/organization/invites"},
    {OpenAi.Admin.Invites, :retrieve, ["a b"], :n, :get, "/v1/organization/invites/a%20b"},
    {OpenAi.Admin.Invites, :delete, ["a b"], :n, :delete, "/v1/organization/invites/a%20b"},
    {OpenAi.Admin.Roles, :list, [], :q, :get, "/v1/organization/roles"},
    {OpenAi.Admin.Roles, :create, [], :b, :post, "/v1/organization/roles"},
    {OpenAi.Admin.Roles, :retrieve, ["a b"], :n, :get, "/v1/organization/roles/a%20b"},
    {OpenAi.Admin.Roles, :update, ["a b"], :b, :post, "/v1/organization/roles/a%20b"},
    {OpenAi.Admin.Roles, :delete, ["a b"], :n, :delete, "/v1/organization/roles/a%20b"},
    {OpenAi.Admin.SpendAlerts, :list, [], :q, :get, "/v1/organization/spend_alerts"},
    {OpenAi.Admin.SpendAlerts, :create, [], :b, :post, "/v1/organization/spend_alerts"},
    {OpenAi.Admin.SpendAlerts, :retrieve, ["a b"], :n, :get, "/v1/organization/spend_alerts/a%20b"},
    {OpenAi.Admin.SpendAlerts, :update, ["a b"], :b, :post, "/v1/organization/spend_alerts/a%20b"},
    {OpenAi.Admin.SpendAlerts, :delete, ["a b"], :n, :delete, "/v1/organization/spend_alerts/a%20b"},
    {OpenAi.Admin.SpendLimit, :retrieve, [], :n, :get, "/v1/organization/spend_limit"},
    {OpenAi.Admin.SpendLimit, :update, [], :b, :post, "/v1/organization/spend_limit"},
    {OpenAi.Admin.SpendLimit, :delete, [], :n, :delete, "/v1/organization/spend_limit"},
    {OpenAi.Admin.Usage, :audio_speeches, [], :q, :get, "/v1/organization/usage/audio_speeches"},
    {OpenAi.Admin.Usage, :audio_transcriptions, [], :q, :get, "/v1/organization/usage/audio_transcriptions"},
    {OpenAi.Admin.Usage, :code_interpreter_sessions, [], :q, :get, "/v1/organization/usage/code_interpreter_sessions"},
    {OpenAi.Admin.Usage, :completions, [], :q, :get, "/v1/organization/usage/completions"},
    {OpenAi.Admin.Usage, :embeddings, [], :q, :get, "/v1/organization/usage/embeddings"},
    {OpenAi.Admin.Usage, :file_search_calls, [], :q, :get, "/v1/organization/usage/file_search_calls"},
    {OpenAi.Admin.Usage, :images, [], :q, :get, "/v1/organization/usage/images"},
    {OpenAi.Admin.Usage, :moderations, [], :q, :get, "/v1/organization/usage/moderations"},
    {OpenAi.Admin.Usage, :vector_stores, [], :q, :get, "/v1/organization/usage/vector_stores"},
    {OpenAi.Admin.Usage, :web_search_calls, [], :q, :get, "/v1/organization/usage/web_search_calls"},
    {OpenAi.Admin.Users, :list, [], :q, :get, "/v1/organization/users"},
    {OpenAi.Admin.Users, :retrieve, ["a b"], :n, :get, "/v1/organization/users/a%20b"},
    {OpenAi.Admin.Users, :update, ["a b"], :b, :post, "/v1/organization/users/a%20b"},
    {OpenAi.Admin.Users, :delete, ["a b"], :n, :delete, "/v1/organization/users/a%20b"},
    {OpenAi.Admin.Users.Roles, :list, ["a b"], :q, :get, "/v1/organization/users/a%20b/roles"},
    {OpenAi.Admin.Users.Roles, :create, ["a b"], :b, :post, "/v1/organization/users/a%20b/roles"},
    {OpenAi.Admin.Users.Roles, :retrieve, ["a b", "a b"], :n, :get, "/v1/organization/users/a%20b/roles/a%20b"},
    {OpenAi.Admin.Users.Roles, :delete, ["a b", "a b"], :n, :delete, "/v1/organization/users/a%20b/roles/a%20b"}
  ]

  test "every organization admin function sends the expected request" do
    owner = self()

    client =
      Client.new(
        api_key: "test-key",
        base_url: "https://example.test/v1",
        max_retries: 0,
        requester: fn request, _finch, _opts ->
          send(owner, {:request, request})

          {:ok, %Finch.Response{status: 200, headers: [{"content-type", "application/json"}], body: "{}"}}
        end
      )

    for {module, fun, ids, kind, method, path} <- @cases do
      extra =
        case kind do
          :q -> [%{limit: 5}]
          :b -> [%{"x" => 1}]
          :n -> []
        end

      assert {:ok, %{}} = apply(module, fun, [client] ++ ids ++ extra)
      assert_receive {:request, request}
      assert request.method == String.upcase(to_string(method))
      assert request.path == path, "#{inspect(module)}.#{fun}"

      case kind do
        :q -> assert request.query == "limit=5"
        :b -> assert Jason.decode!(request.body) == %{"x" => 1}
        :n -> :ok
      end
    end
  end
end
