# OpenAi

An Elixir client for the OpenAI REST API, including JSON requests, streamed
server-sent events, multipart uploads, binary responses, retries, and normalized
API errors.

The client follows `docs/openai-openapi.yaml`. Request and response bodies stay
as maps so new API fields can be used without waiting for a library release.

## Installation

Add the Git dependency to `mix.exs`:

```elixir
def deps do
  [
    {:openai, git: "https://github.com/marinac-dev/openai.git", branch: "master"}
  ]
end
```

## Configuration

Create a client explicitly:

```elixir
client = OpenAi.Client.new(api_key: System.fetch_env!("OPENAI_API_KEY"))
```

Or configure defaults for `OpenAi.client/0`:

```elixir
config :openai,
  api_key: System.get_env("OPENAI_API_KEY"),
  base_url: System.get_env("OPENAI_BASE_URL", "https://api.openai.com/v1"),
  organization: System.get_env("OPENAI_ORG_ID"),
  project: System.get_env("OPENAI_PROJECT_ID"),
  max_retries: 2,
  receive_timeout: 60_000
```

Only the API key is required. `organization` and `project` are optional. The API
root defaults to `https://api.openai.com/v1` and can be changed with the
`:base_url` client option, `:openai` application config, or `OPENAI_BASE_URL`.

## Responses

```elixir
client = OpenAi.client()

{:ok, response} =
  OpenAi.Responses.create(client, %{
    model: "gpt-5.4",
    input: "Write one sentence about Elixir."
  })

OpenAi.Responses.output_text(response)
```

Streaming emits each decoded SSE event as it arrives:

```elixir
{:ok, _response} =
  OpenAi.Responses.stream(
    client,
    %{model: "gpt-5.4", input: "Count to three."},
    fn
      %{"type" => "response.output_text.delta", "delta" => delta} -> IO.write(delta)
      _event -> :ok
    end
  )
```

## Other Resources

```elixir
OpenAi.Chat.Completions.create(client, %{
  model: "gpt-5.4",
  messages: [%{role: "user", content: "Hello"}]
})

OpenAi.Embeddings.create(client, %{
  model: "text-embedding-3-small",
  input: "Hello"
})

OpenAi.Files.create(client, %{
  file: "/tmp/training.jsonl",
  purpose: "fine-tune"
})

OpenAi.Audio.speech(client, %{
  model: "gpt-4o-mini-tts",
  voice: "alloy",
  input: "Hello"
})
```

Chat Completions streams can be folded back into a `chat.completion` object,
including tool calls and usage:

```elixir
{:ok, chunks} = Agent.start_link(fn -> [] end)
body = %{model: "gpt-5.4", messages: [%{role: "user", content: "Hello"}]}

{:ok, _response} =
  OpenAi.Chat.Completions.stream(client, body, fn chunk -> Agent.update(chunks, &[chunk | &1]) end)

completion = chunks |> Agent.get(&Enum.reverse/1) |> OpenAi.Chat.Completions.accumulate()
```

Every operation in `docs/openai-openapi.yaml` has a resource function; each
function's docs name the operation it calls (for example
`` `GET /vector_stores/{vector_store_id}/files` ``):

| Area | Modules |
|---|---|
| Responses | `OpenAi.Responses`, `OpenAi.Conversations` |
| Chat and text | `OpenAi.Chat.Completions`, `OpenAi.Completions`, `OpenAi.Embeddings`, `OpenAi.Moderations`, `OpenAi.Models` |
| Files | `OpenAi.Files`, `OpenAi.Uploads`, `OpenAi.Batches`, `OpenAi.VectorStores` (+ `.Files`, `.FileBatches`), `OpenAi.Containers` (+ `.Files`) |
| Media | `OpenAi.Audio` (+ `.VoiceConsents`), `OpenAi.Images`, `OpenAi.Videos` (+ `.Characters`), `OpenAi.ContentProvenance` |
| Training and evals | `OpenAi.FineTuning.Jobs`, `.Checkpoints.Permissions`, `.Graders`, `OpenAi.Evals` (+ `.Runs`, `.Runs.OutputItems`) |
| Agents | `OpenAi.Skills` (+ `.Versions`), `OpenAi.ChatKit.Sessions`, `.Threads`, `OpenAi.Realtime.*` (REST) |
| Assistants (deprecated) | `OpenAi.Assistants`, `OpenAi.Threads` (+ `.Messages`, `.Runs`, `.Runs.Steps`) |
| Admin API | `OpenAi.Admin.*`, `OpenAi.Admin.Projects.*` — use a client built with an admin API key |

The `OpenAI-Beta` header is added automatically for Assistants/Threads and
ChatKit. Beta Responses endpoints are selected with the `:beta` option:

```elixir
OpenAi.Responses.create(client, body, beta: ["feature-name"])
```

## Uploads

Multipart fields take `{:file, path}` for files on disk or
`{:file_content, binary, filename}` for in-memory content. Resource functions
mark their file fields, so a plain path also works there:

```elixir
OpenAi.Uploads.add_part(client, upload_id, %{data: {:file_content, chunk, "part.bin"}})
```

## Webhooks

Verify and decode a delivery from the raw request body and headers. The secret
defaults to `config :openai, :webhook_secret` or `OPENAI_WEBHOOK_SECRET`:

```elixir
{:ok, %{"type" => "response.completed"} = event} =
  OpenAi.Webhooks.unwrap(raw_body, conn.req_headers)
```

## Any Endpoint

`OpenAi.Client.request/4` calls any path directly. List query values are sent
as `name[]=value`; multipart bodies use `body: {:multipart, fields}`:

```elixir
OpenAi.Client.request(client, :get, "/vector_stores", query: [limit: 20])
```

Use `request_raw/4` to retain status, headers, and `x-request-id`:

```elixir
{:ok, %OpenAi.Response{body: body, request_id: request_id}} =
  OpenAi.Client.request_raw(client, :get, "/models")
```

Failures return `{:error, %OpenAi.Error{}}`. Network errors and HTTP 408, 409,
429, and 5xx responses are retried up to `max_retries`; streamed and multipart
bodies are not replayed automatically.

## Integration Tests

Live integration tests are excluded from the default test run. They list models
and make two small Responses API requests:

```shell
OPENAI_API_KEY=sk-... mix test --only integration
```

Set `OPENAI_INTEGRATION_MODEL` to override the default `gpt-4o-mini` model. Set
`OPENAI_BASE_URL` to run the same tests against an OpenAI-compatible gateway or
local test server.
