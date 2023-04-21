defmodule OpenAi.Models do
  @moduledoc """
  List and describe the various models available in the API.
  You can refer to the [Models](https://platform.openai.com/docs/models) documentation to understand what models are available and the differences between them.
  """

  use OpenAi.Core.Client
  @doc false
  scope "/v1/models"

  @doc """
  Lists the currently available models, and provides basic information about each one such as the owner and availability.
  """
  @spec list_models() :: {:ok, map()} | {:error, map()}
  def list_models() do
    get("", "", %{}, [])
  end

  @doc """
  Retrieves a model instance, providing basic information about the model such as the owner and permissioning.
  """
  @spec retrieve_model(String.t()) :: {:ok, map()} | {:error, map()}
  def retrieve_model(model_id) do
    get("/#{model_id}", "", %{}, [])
  end
end
