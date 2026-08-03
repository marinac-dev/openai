defmodule OpenAi.Images do
  @moduledoc "Client functions for image generation, edits, and variations."

  alias OpenAi.{Client, Multipart}

  @spec generate(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def generate(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/images/generations", Keyword.put(options, :body, body))
  end

  @spec stream_generation(Client.t(), map(), (map() -> term()), keyword()) ::
          {:ok, OpenAi.Response.t()} | {:error, OpenAi.Error.t()}
  def stream_generation(%Client{} = client, body, on_event, options \\ []) when is_map(body) do
    body = put_stream(body)

    Client.stream(
      client,
      :post,
      "/images/generations",
      on_event,
      Keyword.put(options, :body, body)
    )
  end

  @spec edit(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def edit(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/images/edits", Keyword.put(options, :body, body))
  end

  @spec edit_upload(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def edit_upload(%Client{} = client, params, options \\ []) when is_map(params) do
    multipart_request(client, "/images/edits", params, [:image, "image", :mask, "mask"], options)
  end

  @spec variation(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def variation(%Client{} = client, params, options \\ []) when is_map(params) do
    multipart_request(client, "/images/variations", params, [:image, "image"], options)
  end

  defp multipart_request(client, path, params, file_keys, options) do
    multipart =
      file_keys
      |> Enum.reduce(params, &mark_files/2)
      |> Multipart.build()

    Client.request(client, :post, path, Keyword.put(options, :body, {:multipart, multipart}))
  end

  defp mark_files(key, params) do
    case Map.fetch(params, key) do
      {:ok, values} when is_list(values) -> Map.put(params, key, Enum.map(values, &mark_file/1))
      {:ok, value} -> Map.put(params, key, mark_file(value))
      :error -> params
    end
  end

  defp mark_file({:file, _path} = file), do: file
  defp mark_file(path), do: {:file, path}

  defp put_stream(body) do
    if Map.has_key?(body, "stream") do
      Map.put(body, "stream", true)
    else
      Map.put(body, :stream, true)
    end
  end
end
