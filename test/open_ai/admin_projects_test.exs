defmodule OpenAi.AdminProjectsTest do
  use ExUnit.Case, async: true

  alias OpenAi.Admin.Projects
  alias OpenAi.Client

  setup do
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

    {:ok, client: client}
  end

  test "every project admin function hits its path", %{client: client} do
    cases = [
      {fn -> Projects.list(client, %{limit: 2}) end, "GET", "/v1/organization/projects", :q},
      {fn -> Projects.create(client, %{"k" => "v"}) end, "POST", "/v1/organization/projects", :b},
      {fn -> Projects.retrieve(client, "project 1") end, "GET", "/v1/organization/projects/project%201", :g},
      {fn -> Projects.update(client, "project 1", %{"k" => "v"}) end, "POST", "/v1/organization/projects/project%201",
       :b},
      {fn -> Projects.archive(client, "project 1") end, "POST", "/v1/organization/projects/project%201/archive", :n},
      {fn -> Projects.ApiKeys.list(client, "project 1", %{limit: 2}) end, "GET",
       "/v1/organization/projects/project%201/api_keys", :q},
      {fn -> Projects.ApiKeys.retrieve(client, "project 1", "api 1") end, "GET",
       "/v1/organization/projects/project%201/api_keys/api%201", :g},
      {fn -> Projects.ApiKeys.delete(client, "project 1", "api 1") end, "DELETE",
       "/v1/organization/projects/project%201/api_keys/api%201", :n},
      {fn -> Projects.Certificates.list(client, "project 1", %{limit: 2}) end, "GET",
       "/v1/organization/projects/project%201/certificates", :q},
      {fn -> Projects.Certificates.activate(client, "project 1", %{"k" => "v"}) end, "POST",
       "/v1/organization/projects/project%201/certificates/activate", :b},
      {fn -> Projects.Certificates.deactivate(client, "project 1", %{"k" => "v"}) end, "POST",
       "/v1/organization/projects/project%201/certificates/deactivate", :b},
      {fn -> Projects.DataRetention.retrieve(client, "project 1") end, "GET",
       "/v1/organization/projects/project%201/data_retention", :g},
      {fn -> Projects.DataRetention.update(client, "project 1", %{"k" => "v"}) end, "POST",
       "/v1/organization/projects/project%201/data_retention", :b},
      {fn -> Projects.Groups.list(client, "project 1", %{limit: 2}) end, "GET",
       "/v1/organization/projects/project%201/groups", :q},
      {fn -> Projects.Groups.add(client, "project 1", %{"k" => "v"}) end, "POST",
       "/v1/organization/projects/project%201/groups", :b},
      {fn -> Projects.Groups.retrieve(client, "project 1", "group 1", %{limit: 2}) end, "GET",
       "/v1/organization/projects/project%201/groups/group%201", :q},
      {fn -> Projects.Groups.remove(client, "project 1", "group 1") end, "DELETE",
       "/v1/organization/projects/project%201/groups/group%201", :n},
      {fn -> Projects.HostedToolPermissions.retrieve(client, "project 1") end, "GET",
       "/v1/organization/projects/project%201/hosted_tool_permissions", :g},
      {fn -> Projects.HostedToolPermissions.update(client, "project 1", %{"k" => "v"}) end, "POST",
       "/v1/organization/projects/project%201/hosted_tool_permissions", :b},
      {fn -> Projects.ModelPermissions.retrieve(client, "project 1") end, "GET",
       "/v1/organization/projects/project%201/model_permissions", :g},
      {fn -> Projects.ModelPermissions.update(client, "project 1", %{"k" => "v"}) end, "POST",
       "/v1/organization/projects/project%201/model_permissions", :b},
      {fn -> Projects.ModelPermissions.delete(client, "project 1") end, "DELETE",
       "/v1/organization/projects/project%201/model_permissions", :n},
      {fn -> Projects.RateLimits.list(client, "project 1", %{limit: 2}) end, "GET",
       "/v1/organization/projects/project%201/rate_limits", :q},
      {fn -> Projects.RateLimits.update(client, "project 1", "rate 1", %{"k" => "v"}) end, "POST",
       "/v1/organization/projects/project%201/rate_limits/rate%201", :b},
      {fn -> Projects.ServiceAccounts.list(client, "project 1", %{limit: 2}) end, "GET",
       "/v1/organization/projects/project%201/service_accounts", :q},
      {fn -> Projects.ServiceAccounts.create(client, "project 1", %{"k" => "v"}) end, "POST",
       "/v1/organization/projects/project%201/service_accounts", :b},
      {fn -> Projects.ServiceAccounts.retrieve(client, "project 1", "service 1") end, "GET",
       "/v1/organization/projects/project%201/service_accounts/service%201", :g},
      {fn -> Projects.ServiceAccounts.update(client, "project 1", "service 1", %{"k" => "v"}) end, "POST",
       "/v1/organization/projects/project%201/service_accounts/service%201", :b},
      {fn -> Projects.ServiceAccounts.delete(client, "project 1", "service 1") end, "DELETE",
       "/v1/organization/projects/project%201/service_accounts/service%201", :n},
      {fn -> Projects.ServiceAccounts.create_api_key(client, "project 1", "service 1", %{"k" => "v"}) end, "POST",
       "/v1/organization/projects/project%201/service_accounts/service%201/api_keys", :o},
      {fn -> Projects.SpendAlerts.list(client, "project 1", %{limit: 2}) end, "GET",
       "/v1/organization/projects/project%201/spend_alerts", :q},
      {fn -> Projects.SpendAlerts.create(client, "project 1", %{"k" => "v"}) end, "POST",
       "/v1/organization/projects/project%201/spend_alerts", :b},
      {fn -> Projects.SpendAlerts.retrieve(client, "project 1", "alert 1") end, "GET",
       "/v1/organization/projects/project%201/spend_alerts/alert%201", :g},
      {fn -> Projects.SpendAlerts.update(client, "project 1", "alert 1", %{"k" => "v"}) end, "POST",
       "/v1/organization/projects/project%201/spend_alerts/alert%201", :b},
      {fn -> Projects.SpendAlerts.delete(client, "project 1", "alert 1") end, "DELETE",
       "/v1/organization/projects/project%201/spend_alerts/alert%201", :n},
      {fn -> Projects.SpendLimit.retrieve(client, "project 1") end, "GET",
       "/v1/organization/projects/project%201/spend_limit", :g},
      {fn -> Projects.SpendLimit.update(client, "project 1", %{"k" => "v"}) end, "POST",
       "/v1/organization/projects/project%201/spend_limit", :b},
      {fn -> Projects.SpendLimit.delete(client, "project 1") end, "DELETE",
       "/v1/organization/projects/project%201/spend_limit", :n},
      {fn -> Projects.Users.list(client, "project 1", %{limit: 2}) end, "GET",
       "/v1/organization/projects/project%201/users", :q},
      {fn -> Projects.Users.create(client, "project 1", %{"k" => "v"}) end, "POST",
       "/v1/organization/projects/project%201/users", :b},
      {fn -> Projects.Users.retrieve(client, "project 1", "user 1") end, "GET",
       "/v1/organization/projects/project%201/users/user%201", :g},
      {fn -> Projects.Users.update(client, "project 1", "user 1", %{"k" => "v"}) end, "POST",
       "/v1/organization/projects/project%201/users/user%201", :b},
      {fn -> Projects.Users.delete(client, "project 1", "user 1") end, "DELETE",
       "/v1/organization/projects/project%201/users/user%201", :n},
      {fn -> Projects.Roles.list(client, "project 1", %{limit: 2}) end, "GET", "/v1/projects/project%201/roles", :q},
      {fn -> Projects.Roles.create(client, "project 1", %{"k" => "v"}) end, "POST", "/v1/projects/project%201/roles",
       :b},
      {fn -> Projects.Roles.retrieve(client, "project 1", "role 1") end, "GET",
       "/v1/projects/project%201/roles/role%201", :g},
      {fn -> Projects.Roles.update(client, "project 1", "role 1", %{"k" => "v"}) end, "POST",
       "/v1/projects/project%201/roles/role%201", :b},
      {fn -> Projects.Roles.delete(client, "project 1", "role 1") end, "DELETE",
       "/v1/projects/project%201/roles/role%201", :n},
      {fn -> Projects.Groups.Roles.list(client, "project 1", "group 1", %{limit: 2}) end, "GET",
       "/v1/projects/project%201/groups/group%201/roles", :q},
      {fn -> Projects.Groups.Roles.assign(client, "project 1", "group 1", %{"k" => "v"}) end, "POST",
       "/v1/projects/project%201/groups/group%201/roles", :b},
      {fn -> Projects.Groups.Roles.retrieve(client, "project 1", "group 1", "role 1") end, "GET",
       "/v1/projects/project%201/groups/group%201/roles/role%201", :g},
      {fn -> Projects.Groups.Roles.unassign(client, "project 1", "group 1", "role 1") end, "DELETE",
       "/v1/projects/project%201/groups/group%201/roles/role%201", :n},
      {fn -> Projects.Users.Roles.list(client, "project 1", "user 1", %{limit: 2}) end, "GET",
       "/v1/projects/project%201/users/user%201/roles", :q},
      {fn -> Projects.Users.Roles.assign(client, "project 1", "user 1", %{"k" => "v"}) end, "POST",
       "/v1/projects/project%201/users/user%201/roles", :b},
      {fn -> Projects.Users.Roles.retrieve(client, "project 1", "user 1", "role 1") end, "GET",
       "/v1/projects/project%201/users/user%201/roles/role%201", :g},
      {fn -> Projects.Users.Roles.unassign(client, "project 1", "user 1", "role 1") end, "DELETE",
       "/v1/projects/project%201/users/user%201/roles/role%201", :n}
    ]

    for {fun, method, path, kind} <- cases do
      assert {:ok, %{}} = fun.()
      assert_received {:request, request}
      assert request.method == method
      assert request.path == path
      assert_kind(kind, request)
    end
  end

  defp assert_kind(kind, request) when kind in [:b, :o], do: assert(request.body =~ ~s("k":"v"))
  defp assert_kind(:q, request), do: assert(request.query == "limit=2")
  defp assert_kind(_kind, _request), do: :ok
end
