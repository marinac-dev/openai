# Reads OPENAI_API_KEY from the environment unless configured otherwise.
client = OpenAi.client()

alias OpenAi.{Chat, Responses}

# Responses.create(client, %{model: "gpt-5.4", input: "Hello!"})
# Chat.Completions.create(client, %{model: "gpt-5.4", messages: [%{role: "user", content: "Hello!"}]})
