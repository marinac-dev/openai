# Changelog

## 0.2.0

### Breaking

- Requires Elixir `~> 1.17`. Dependencies updated: Finch 0.24 (Mint 1.11, fixing
  EEF-CVE-2026-82728), multipart 0.6. `idna` and `nx` are no longer dependencies.
- Top-level `OpenAi.*` helpers (`chat_completion/2`, `text_completion/2`,
  `embed_text/2`, `moderation/3`, file helpers) now delegate to the resource
  modules and return `{:ok, body} | {:error, %OpenAi.Error{}}`. They no longer
  take a streaming callback; use `OpenAi.Chat.Completions.stream/4` or
  `OpenAi.Completions.stream/4`.
- Removed `OpenAi.edit_text/2` (the Edits endpoint no longer exists) and the
  legacy modules `OpenAi.ChatCompletion`, `OpenAi.TextCompletion`, `OpenAi.Edit`,
  `OpenAi.Embedding`, `OpenAi.Moderation`, `OpenAi.Core.*`, `OpenAi.Utils.SseParser`.
- `OpenAi.moderation/3` defaults to `omni-moderation-latest`.
- List query values are encoded with brackets: `include: ["a"]` → `include[]=a`.
- `{:multipart, fields}` request bodies take a map or keyword list of fields
  instead of a prebuilt `Multipart` struct.

### Fixed

- Legacy chat parsing crashed on API error bodies, dropped `tool_calls` streams,
  and returned 5xx error bodies as `{:ok, _}`.

### Added

- Resource modules for every operation in `docs/openai-openapi.yaml`: Batches,
  Uploads, Vector Stores, Containers, Fine-tuning, Graders, Evals, Skills, Videos,
  Realtime (REST), ChatKit, Assistants/Threads, Audio voices and voice consents,
  content provenance checks, and the Admin API (`OpenAi.Admin.*`).
- `OpenAi.Responses.input_tokens/3`, `compact/3`, `stream_retrieve/5`, and a
  `:beta` option for the beta Responses endpoints.
- `OpenAi.Chat.Completions.accumulate/1` folds streamed chunks into a
  `chat.completion` object, including tool calls and usage.
- `OpenAi.Webhooks.verify/4` and `unwrap/4` for webhook signature verification.
- `OpenAI-Beta` headers are sent automatically for Assistants/Threads and ChatKit.
- Multipart fields accept `{:file, path}` and `{:file_content, binary, filename}`.
