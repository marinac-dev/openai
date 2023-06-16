text_prompt = %{model: "text-davinci-003", prompt: "Hello, my name is", max_tokens: 500, stream: true}
instruction_prompt = %{
  model: "text-davinci-edit-001",
  input: "What day of the wek is it?",
  instruction: "Fix the spelling mistakes"
}

chat_prompt = %{
  model: "gpt-3.5-turbo",
  messages: [
    %{role: "user", content: "Hello!"},
    %{role: "assistant", content: "Hello there, how may I assist you today?"},
    %{role: "user", content: "I'd like to book a flight to New York City."}
  ],
  stream: true
}

function_prompt = %{
  model: "gpt-4-0613",
  stream: true,
  messages: [
    %{role: "user", content: "Hello!"},
    %{role: "assistant", content: "Hello there, how may I assist you today?"},
    %{role: "user", content: "I'd like to book a flight to New York City."},
    %{role: "assistant", content: "Sure, I can assist you with that. Could you please tell me when you're planning to fly?"},
    %{role: "user", content: "I'd like to fly on the 23rd of June."}
  ],
  functions: [
    %{
      name: "book_flight",
      description: "Book a flight to a destination",
      parameters: %{
        type: "object",
        properties: %{
          destination: %{
            type: "string",
            description: "The destination of the flight"
          },
          date: %{
            type: "string",
            description: "The date of the flight"
          }
        },
        required: ["destination", "date"]
      }
    }
  ]
}
