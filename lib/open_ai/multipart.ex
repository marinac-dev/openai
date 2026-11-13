defmodule OpenAi.Multipart do
  @moduledoc """
  Builds `multipart/form-data` bodies for `OpenAi.Client.request/4`.

  Pass `body: {:multipart, fields}` where `fields` is a map or keyword list.
  Field values may be:

    * `{:file, path}` — streams the file from disk
    * `{:file_content, binary, filename}` — uploads in-memory content as a file
    * a map — encoded as `name[key]` fields
    * a list — encoded as repeated `name[]` fields
    * any other value — sent as text via `to_string/1`; `nil` fields are omitted
  """

  alias Multipart, as: MultipartBody
  alias Multipart.Part

  @type file :: {:file, Path.t()} | {:file_content, binary(), String.t()}

  @doc false
  @spec build(map() | keyword()) :: MultipartBody.t()
  def build(fields) when is_map(fields) or is_list(fields) do
    fields
    |> flatten_fields()
    |> Enum.reduce(MultipartBody.new(), fn
      {name, {:file, path}}, multipart ->
        MultipartBody.add_part(multipart, Part.file_field(path, name))

      {name, {:file_content, content, filename}}, multipart ->
        MultipartBody.add_part(multipart, Part.file_content_field(filename, content, name))

      {name, value}, multipart ->
        MultipartBody.add_part(multipart, Part.text_field(to_string(value), name))
    end)
  end

  @doc """
  Marks the given `keys` (atom or string) as file fields.

  Plain path strings become `{:file, path}`; values that are already file tuples
  are kept. Lists are marked element-wise.
  """
  @spec put_files(map(), [atom() | String.t()]) :: map()
  def put_files(params, keys) when is_map(params) do
    Enum.reduce(keys, params, fn key, params ->
      params
      |> mark(key)
      |> mark(to_string(key))
    end)
  end

  defp mark(params, key) do
    case Map.fetch(params, key) do
      {:ok, values} when is_list(values) -> Map.put(params, key, Enum.map(values, &file/1))
      {:ok, value} -> Map.put(params, key, file(value))
      :error -> params
    end
  end

  defp file({:file, _path} = file), do: file
  defp file({:file_content, _content, _filename} = file), do: file
  defp file(path) when is_binary(path), do: {:file, path}

  defp flatten_fields(fields) when is_map(fields) do
    fields
    |> Enum.sort_by(fn {key, _value} -> to_string(key) end)
    |> Enum.flat_map(fn {key, value} -> flatten_value(to_string(key), value) end)
  end

  defp flatten_fields(fields) when is_list(fields) do
    Enum.flat_map(fields, fn {key, value} -> flatten_value(to_string(key), value) end)
  end

  defp flatten_value(_name, nil), do: []
  defp flatten_value(name, {:file, _path} = file), do: [{name, file}]
  defp flatten_value(name, {:file_content, _content, _filename} = file), do: [{name, file}]

  defp flatten_value(name, value) when is_map(value) do
    value
    |> Enum.sort_by(fn {key, _value} -> to_string(key) end)
    |> Enum.flat_map(fn {key, nested} -> flatten_value("#{name}[#{key}]", nested) end)
  end

  defp flatten_value(name, value) when is_list(value) do
    name = if String.ends_with?(name, "[]"), do: name, else: name <> "[]"
    Enum.flat_map(value, &flatten_value(name, &1))
  end

  defp flatten_value(name, value), do: [{name, value}]
end
