defmodule OpenAi.FineTuning.Jobs do
  @moduledoc "Client functions for fine-tuning jobs, their checkpoints and events."

  alias OpenAi.Client

  @type result :: {:ok, map()} | {:error, OpenAi.Error.t()}

  @doc "Creates a fine-tuning job. `POST /fine_tuning/jobs`"
  @spec create(Client.t(), map(), keyword()) :: result()
  def create(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/fine_tuning/jobs", Keyword.put(options, :body, body))
  end

  @doc "Lists fine-tuning jobs. `GET /fine_tuning/jobs`"
  @spec list(Client.t(), map() | keyword(), keyword()) :: result()
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/fine_tuning/jobs", Keyword.put(options, :query, query))
  end

  @doc "Retrieves a fine-tuning job. `GET /fine_tuning/jobs/{fine_tuning_job_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: result()
  def retrieve(%Client{} = client, job_id, options \\ []) do
    Client.request(client, :get, path(job_id), options)
  end

  @doc "Cancels a fine-tuning job. `POST /fine_tuning/jobs/{fine_tuning_job_id}/cancel`"
  @spec cancel(Client.t(), String.t(), keyword()) :: result()
  def cancel(%Client{} = client, job_id, options \\ []) do
    Client.request(client, :post, path(job_id) <> "/cancel", options)
  end

  @doc "Pauses a fine-tuning job. `POST /fine_tuning/jobs/{fine_tuning_job_id}/pause`"
  @spec pause(Client.t(), String.t(), keyword()) :: result()
  def pause(%Client{} = client, job_id, options \\ []) do
    Client.request(client, :post, path(job_id) <> "/pause", options)
  end

  @doc "Resumes a fine-tuning job. `POST /fine_tuning/jobs/{fine_tuning_job_id}/resume`"
  @spec resume(Client.t(), String.t(), keyword()) :: result()
  def resume(%Client{} = client, job_id, options \\ []) do
    Client.request(client, :post, path(job_id) <> "/resume", options)
  end

  @doc "Lists fine-tuning job checkpoints. `GET /fine_tuning/jobs/{fine_tuning_job_id}/checkpoints`"
  @spec list_checkpoints(Client.t(), String.t(), map() | keyword(), keyword()) :: result()
  def list_checkpoints(%Client{} = client, job_id, query \\ [], options \\ []) do
    Client.request(client, :get, path(job_id) <> "/checkpoints", Keyword.put(options, :query, query))
  end

  @doc "Lists fine-tuning job events. `GET /fine_tuning/jobs/{fine_tuning_job_id}/events`"
  @spec list_events(Client.t(), String.t(), map() | keyword(), keyword()) :: result()
  def list_events(%Client{} = client, job_id, query \\ [], options \\ []) do
    Client.request(client, :get, path(job_id) <> "/events", Keyword.put(options, :query, query))
  end

  defp path(job_id), do: "/fine_tuning/jobs/" <> Client.path_segment(job_id)
end
