defmodule OpenAi.Files do
  @moduledoc """
  Files are used to upload documents that can be used with features like Fine-tuning.
  """

  use OpenAi.Core.Client

  alias Multipart.Part

  @doc false
  scope "/v1/files"

  @doc """
  Returns a list of files that belong to the user's organization.
  """
  @spec list_files() :: {:ok, map()} | {:error, map()}
  def list_files() do
    get("", "", %{}, [])
  end

  @doc """
  Upload a file that contains document(s) to be used across various endpoints/features.
  Currently, the size of all the files uploaded by one organization can be up to 1 GB.
  """
  @spec upload_file({String.t(), String.t()}, keyword()) :: {:ok, map()} | {:error, map()}
  def upload_file({file_path, purpose}, params) do
    multipart =
      Multipart.new()
      |> Multipart.add_part(Part.text_field(purpose, :purpose))
      |> Multipart.add_part(Part.file_field(file_path, :file))

    body_stream = Multipart.body_stream(multipart)
    content_length = Multipart.content_length(multipart)
    content_type = Multipart.content_type(multipart, "multipart/form-data")

    headers = %{
      "Content-Type" => content_type,
      "Content-Length" => to_string(content_length)
    }

    post("", {:stream, body_stream}, headers, params)
  end

  @doc """
  Delete a file.
  """
  @spec delete_file(String.t()) :: {:ok, map()} | {:error, map()}
  def delete_file(file_id) do
    delete("/#{file_id}", "", %{}, [])
  end

  @doc """
  Returns information about a specific file.
  """
  @spec retrieve_file(String.t()) :: {:ok, map()} | {:error, map()}
  def retrieve_file(file_id) do
    get("/#{file_id}", "", %{}, [])
  end

  @doc """
  Returns the contents of the specified file
  """
  @spec retrieve_file_content(String.t()) :: {:ok, map()} | {:error, map()}
  def retrieve_file_content(file_id) do
    get("/#{file_id}/content", "", %{}, [])
  end
end
