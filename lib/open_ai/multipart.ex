defmodule OpenAi.Multipart do
  @moduledoc false

  alias Multipart, as: MultipartBody
  alias Multipart.Part

  @spec build(map() | keyword()) :: struct()
  def build(fields) when is_map(fields) or is_list(fields) do
    fields
    |> flatten_fields()
    |> Enum.reduce(MultipartBody.new(), fn
      {name, {:file, path}}, multipart ->
        MultipartBody.add_part(multipart, Part.file_field(path, name))

      {name, value}, multipart ->
        MultipartBody.add_part(multipart, Part.text_field(to_string(value), name))
    end)
  end

  defp flatten_fields(fields) when is_map(fields) do
    fields
    |> Enum.sort_by(fn {key, _value} -> to_string(key) end)
    |> Enum.flat_map(fn {key, value} -> flatten_value(to_string(key), value) end)
  end

  defp flatten_fields(fields) when is_list(fields) do
    Enum.flat_map(fields, fn {key, value} -> flatten_value(to_string(key), value) end)
  end

  defp flatten_value(_name, nil), do: []
  defp flatten_value(name, {:file, path}), do: [{name, {:file, path}}]

  defp flatten_value(name, value) when is_map(value) do
    value
    |> Enum.sort_by(fn {key, _value} -> to_string(key) end)
    |> Enum.flat_map(fn {key, nested} -> flatten_value("#{name}[#{key}]", nested) end)
  end

  defp flatten_value(name, value) when is_list(value) do
    Enum.flat_map(value, &flatten_value(name <> "[]", &1))
  end

  defp flatten_value(name, value), do: [{name, value}]
end
