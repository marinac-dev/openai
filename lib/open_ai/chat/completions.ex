defmodule OpenAi.Chat.Completions do
  @moduledoc "Client functions for the Chat Completions API."

  alias OpenAi.Client

  @meta_keys ["id", "created", "model", "system_fingerprint", "service_tier"]

  @doc "Creates a chat completion. `POST /chat/completions`"
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def create(%Client{} = client, body, options \\ []) when is_map(body) do
    Client.request(client, :post, "/chat/completions", Keyword.put(options, :body, body))
  end

  @doc """
  Creates a streamed chat completion, invoking `on_event` with each decoded `chat.completion.chunk`.

  Forces `stream: true` in the request body. To obtain a full completion, collect the chunks
  (for example by sending them to the calling process) and pass them to `accumulate/1`:

      owner = self()
      {:ok, _response} = OpenAi.Chat.Completions.stream(client, body, &send(owner, {:chunk, &1}))
  """
  @spec stream(Client.t(), map(), (map() -> term()), keyword()) ::
          {:ok, OpenAi.Response.t()} | {:error, OpenAi.Error.t()}
  def stream(%Client{} = client, body, on_event, options \\ []) when is_map(body) do
    Client.stream(
      client,
      :post,
      "/chat/completions",
      on_event,
      Keyword.put(options, :body, put_stream(body))
    )
  end

  @doc "Lists stored chat completions. `GET /chat/completions`"
  @spec list(Client.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def list(%Client{} = client, query \\ [], options \\ []) do
    Client.request(client, :get, "/chat/completions", Keyword.put(options, :query, query))
  end

  @doc "Retrieves a stored chat completion. `GET /chat/completions/{completion_id}`"
  @spec retrieve(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def retrieve(%Client{} = client, completion_id, options \\ []) do
    Client.request(client, :get, path(completion_id), options)
  end

  @doc "Updates a stored chat completion. `POST /chat/completions/{completion_id}`"
  @spec update(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def update(%Client{} = client, completion_id, body, options \\ []) when is_map(body) do
    Client.request(client, :post, path(completion_id), Keyword.put(options, :body, body))
  end

  @doc "Deletes a stored chat completion. `DELETE /chat/completions/{completion_id}`"
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, OpenAi.Error.t()}
  def delete(%Client{} = client, completion_id, options \\ []) do
    Client.request(client, :delete, path(completion_id), options)
  end

  @doc "Lists messages of a stored chat completion. `GET /chat/completions/{completion_id}/messages`"
  @spec list_messages(Client.t(), String.t(), map() | keyword(), keyword()) ::
          {:ok, map()} | {:error, OpenAi.Error.t()}
  def list_messages(%Client{} = client, completion_id, query \\ [], options \\ []) do
    Client.request(
      client,
      :get,
      path(completion_id) <> "/messages",
      Keyword.put(options, :query, query)
    )
  end

  @doc """
  Merges decoded `chat.completion.chunk` maps (string keys) into a `chat.completion`-shaped map.

  Content and refusal deltas are concatenated per choice, `tool_calls` deltas are merged by
  their `index`, and the usage-only final chunk (empty `choices`) populates `"usage"`. Choices
  are sorted by `index`. `"content"` and `"refusal"` are `nil` when never streamed, and the
  `"tool_calls"` key is omitted from a message without tool calls.
  """
  @spec accumulate(Enumerable.t()) :: map()
  def accumulate(chunks) do
    %{meta: meta, usage: usage, choices: choices} =
      Enum.reduce(chunks, %{meta: %{}, usage: nil, choices: %{}}, &accumulate_chunk/2)

    completion =
      Map.merge(%{"object" => "chat.completion", "choices" => build_choices(choices)}, meta)

    if usage, do: Map.put(completion, "usage", usage), else: completion
  end

  defp accumulate_chunk(chunk, acc) do
    %{
      acc
      | meta: Enum.reduce(@meta_keys, acc.meta, &put_meta(&2, &1, chunk)),
        usage: chunk["usage"] || acc.usage,
        choices: Enum.reduce(chunk["choices"] || [], acc.choices, &accumulate_choice/2)
    }
  end

  defp put_meta(meta, key, chunk) do
    case chunk[key] do
      nil -> meta
      value -> Map.put_new(meta, key, value)
    end
  end

  defp accumulate_choice(choice, choices) do
    index = choice["index"] || 0
    delta = choice["delta"] || %{}
    state = Map.get(choices, index, new_choice(index))

    state = %{
      state
      | role: delta["role"] || state.role,
        content: append(state.content, delta["content"]),
        refusal: append(state.refusal, delta["refusal"]),
        finish_reason: choice["finish_reason"] || state.finish_reason,
        logprobs: merge_logprobs(state.logprobs, choice["logprobs"]),
        tool_calls: Enum.reduce(delta["tool_calls"] || [], state.tool_calls, &merge_tool_call/2)
    }

    Map.put(choices, index, state)
  end

  defp new_choice(index) do
    %{
      index: index,
      role: nil,
      content: nil,
      refusal: nil,
      finish_reason: nil,
      logprobs: nil,
      tool_calls: %{}
    }
  end

  defp append(current, nil), do: current
  defp append(nil, text), do: text
  defp append(current, text), do: current <> text

  defp merge_logprobs(current, nil), do: current

  defp merge_logprobs(current, logprobs) do
    current = current || %{"content" => nil, "refusal" => nil}

    %{
      "content" => append_list(current["content"], logprobs["content"]),
      "refusal" => append_list(current["refusal"], logprobs["refusal"])
    }
  end

  defp append_list(current, nil), do: current
  defp append_list(nil, list), do: list
  defp append_list(current, list), do: current ++ list

  defp merge_tool_call(delta, tool_calls) do
    index = delta["index"] || 0
    function = delta["function"] || %{}
    current = Map.get(tool_calls, index, %{"id" => nil, "type" => "function", "function" => %{}})
    current_function = current["function"]

    merged = %{
      "id" => delta["id"] || current["id"],
      "type" => delta["type"] || current["type"],
      "function" => %{
        "name" => function["name"] || current_function["name"],
        "arguments" => append(current_function["arguments"], function["arguments"])
      }
    }

    Map.put(tool_calls, index, merged)
  end

  defp build_choices(choices) do
    choices
    |> Enum.sort_by(fn {index, _state} -> index end)
    |> Enum.map(fn {_index, state} -> build_choice(state) end)
  end

  defp build_choice(state) do
    message = %{
      "role" => state.role || "assistant",
      "content" => state.content,
      "refusal" => state.refusal
    }

    %{
      "index" => state.index,
      "finish_reason" => state.finish_reason,
      "logprobs" => state.logprobs,
      "message" => put_tool_calls(message, state.tool_calls)
    }
  end

  defp put_tool_calls(message, tool_calls) when map_size(tool_calls) == 0, do: message

  defp put_tool_calls(message, tool_calls) do
    calls =
      tool_calls
      |> Enum.sort_by(fn {index, _call} -> index end)
      |> Enum.map(fn {_index, call} -> call end)

    Map.put(message, "tool_calls", calls)
  end

  defp path(completion_id), do: "/chat/completions/" <> Client.path_segment(completion_id)

  defp put_stream(body) do
    if Map.has_key?(body, "stream") do
      Map.put(body, "stream", true)
    else
      Map.put(body, :stream, true)
    end
  end
end
