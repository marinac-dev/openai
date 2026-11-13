defmodule OpenAi.FineTuning.Graders do
  @moduledoc "Client functions for fine-tuning grader utilities."

  alias OpenAi.Client

  @type result :: {:ok, map()} | {:error, OpenAi.Error.t()}

  @doc "Runs a grader. `POST /fine_tuning/alpha/graders/run`"
  @spec run(Client.t(), map(), keyword()) :: result()
  def run(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/fine_tuning/alpha/graders/run", Keyword.put(options, :body, body))
  end

  @doc "Validates a grader. `POST /fine_tuning/alpha/graders/validate`"
  @spec validate(Client.t(), map(), keyword()) :: result()
  def validate(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/fine_tuning/alpha/graders/validate", Keyword.put(options, :body, body))
  end
end
