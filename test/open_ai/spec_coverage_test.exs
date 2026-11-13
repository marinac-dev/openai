defmodule OpenAi.SpecCoverageTest do
  use ExUnit.Case, async: true

  # Every endpoint function documents its operation as `METHOD /path` using the
  # spec's path template, so the docs double as the operation → function map.
  @spec_path Path.expand("../../docs/openai-openapi.yaml", __DIR__)
  @external_resource @spec_path
  @operation ~r/`(GET|POST|PUT|PATCH|DELETE) (\/[^`\s]*)`/

  test "every OpenAPI operation maps to exactly one library function" do
    documented = documented_operations()
    expected = spec_operations()

    duplicates =
      documented
      |> Enum.group_by(fn {operation, _function} -> operation end, fn {_operation, function} -> function end)
      |> Enum.filter(fn {_operation, functions} -> length(functions) > 1 end)
      |> Map.new()

    implemented = MapSet.new(documented, fn {operation, _function} -> operation end)

    assert MapSet.difference(expected, implemented) |> Enum.sort() == [], "operations without a function"
    assert MapSet.difference(implemented, expected) |> Enum.sort() == [], "documented operations missing from the spec"
    assert duplicates == %{}, "operations documented by more than one function"
  end

  # Beta Responses variants (`/responses?beta=true`) are served by the `:beta`
  # option of `OpenAi.Responses`, so they collapse onto their base paths.
  defp spec_operations do
    @spec_path
    |> File.stream!()
    |> Enum.reduce_while({nil, MapSet.new()}, fn
      "webhooks:" <> _rest, {_path, operations} ->
        {:halt, {nil, operations}}

      "  /" <> rest, {_path, operations} ->
        path = "/" <> (rest |> String.trim_trailing() |> String.trim_trailing(":"))
        {:cont, {String.replace_suffix(path, "?beta=true", ""), operations}}

      "    " <> rest, {path, operations} when is_binary(path) ->
        case Regex.run(~r/^(get|post|put|patch|delete):\s*$/, rest) do
          [_line, method] -> {:cont, {path, MapSet.put(operations, String.upcase(method) <> " " <> path)}}
          nil -> {:cont, {path, operations}}
        end

      _line, acc ->
        {:cont, acc}
    end)
    |> elem(1)
  end

  defp documented_operations do
    {:ok, modules} = :application.get_key(:openai, :modules)

    for module <- modules,
        {:docs_v1, _anno, _language, _format, _moduledoc, _metadata, docs} <- [Code.fetch_docs(module)],
        {{:function, name, arity}, _anno, _signature, %{"en" => doc}, _meta} <- docs,
        [_match, method, path] <- Regex.scan(@operation, doc) do
      {method <> " " <> path, "#{inspect(module)}.#{name}/#{arity}"}
    end
  end
end
