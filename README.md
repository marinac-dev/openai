# OpenAi

Elixir OpenAi client library for with full support for streaming or SSE (Server Side Events).

## Installation

Not available in Hex, but the package can be installed from git
by adding `openai` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:openai, git: "git@github.com:marinac-dev/openai.git", branch: "master"},
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc) by running `mix docs`.

## Configuration

```elixir
config :openai,
  api_key: System.get_env("OPENAI_API_KEY"),
  organization_key: System.get_env("OPENAI_ORGANIZATION_KEY")
```

If you want to use retry mechanism, you can configure it like this:

```elixir
config :openai,
  api_key: System.get_env("OPENAI_API_KEY"),
  organization_key: System.get_env("OPENAI_ORGANIZATION_KEY"),
  retry_config: %{
    retries: 5,
    delay: 200
  }
```

## Usage

Once configured in your `config.ex` file, you can use the client to call the OpenAi API instantly.

```elixir
prompt = %{model: "gpt-3.5-turbo", messages: [%{role: "user", content: "Hello!"}], stream: true}
OpenAi.chat_completion(prompt)
{:ok, "Hello! How may I assist you today?"}
```
