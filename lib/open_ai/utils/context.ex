defmodule OpenAi.Utils.Context do
  @moduledoc """
  Documentation for `OpenAi.Utils.Context` module.

  This module contains functions for working with OpenAI chat completion contexts
  """
  alias OpenAi.Utils.Message

  @enforce_keys [:last_response, :history]
  defstruct [:last_response, :history]

  @type t :: %__MODULE__{
          last_response: Message.t(),
          history: list(Message.t())
        }

  @doc """
  Initializes a new context.
  """
  def init() do
    %__MODULE__{
      last_response: "",
      history: []
    }
  end

  @doc """
  Adds a system response to the conversation history, returns the updated conversation context.\n
  """
  @spec add_system_response(t(), String.t()) :: {:ok, t()} | {:error, String.t()}
  def add_system_response(context, content) do
    add(context, %Message{role: "system", content: content})
  end

  @doc """
  Adds a system response to the conversation history, returns the updated conversation context.\n
  """
  @spec add_system_response!(t(), String.t()) :: t()
  def add_system_response!(context, content) do
    add!(context, %Message{role: "system", content: content})
  end

  @doc """
  Adds an assistant response to the conversation history, returns the updated conversation context.\n
  """
  @spec add_assistant_response(t(), String.t()) :: {:ok, t()} | {:error, String.t()}
  def add_assistant_response(context, content) do
    add(context, %Message{role: "assistant", content: content})
  end

  @doc """
  Adds an assistant response to the conversation history, returns the updated conversation context.\n
  """
  @spec add_assistant_response!(t(), String.t()) :: t()
  def add_assistant_response!(context, content) do
    add!(context, %Message{role: "assistant", content: content})
  end

  @doc """
  Adds a user response to the conversation history, returns the updated conversation context.\n
  """
  @spec add_user_response(t(), String.t()) :: {:ok, t()} | {:error, String.t()}
  def add_user_response(context, content) do
    add(context, %Message{role: "user", content: content})
  end

  @doc """
  Adds a user response to the conversation history, returns the updated conversation context.\n
  """
  @spec add_user_response!(t(), String.t()) :: t()
  def add_user_response!(context, content) do
    add!(context, %Message{role: "user", content: content})
  end

  @doc """
  Returns the last response from the assistant.
  """
  @spec last_assistant_response(t()) :: %Message{} | nil
  def last_assistant_response(context) do
    context.history
    |> Enum.find(fn %Message{role: role} -> role == "assistant" end)
  end

  @doc """
  Returns the last response from the user.
  """
  @spec last_user_response(t()) :: %Message{} | nil
  def last_user_response(context) do
    context.history
    |> Enum.find(fn %Message{role: role} -> role == "user" end)
  end

  @doc """
  Returns the last response from the system.
  """
  @spec last_system_response(t()) :: %Message{} | nil
  def last_system_response(context) do
    context.history
    |> Enum.find(fn %Message{role: role} -> role == "system" end)
  end

  @doc """
  Adds an item to the conversation history and last response, returns the updated conversation context.\n
  Item must have the following fields: `role`, `content`.\n
  Role can be either `system`, `assistant` or `user`.\n

  Example:

      iex> add(context, %{role: "user", content: "Hello"})
  """
  @spec add(t(), Message.t()) :: {:ok, t()} | {:error, String.t()}
  def add(context, %Message{role: role, content: _} = item) when role in ["system", "assistant", "user"] do
    new_context = Map.put(context, :history, [item | context.history])
    new_context = Map.put(new_context, :last_response, item)
    {:ok, new_context}
  end

  def add(_context, %{role: _}) do
    {:error, "Invalid role. Role must be one of the following: system, assistant, or user."}
  end

  @doc """
  Adds an item to the conversation history, returns the updated conversation context.\n
  """
  @spec add!(t(), Message.t()) :: t()
  def add!(context, %Message{role: role, content: _} = item) when role in ["system", "assistant", "user"] do
    new_context = Map.put(context, :history, [item | context.history])
    new_context = Map.put(new_context, :last_response, item)
    new_context
  end

  def add!(_context, %{role: _}) do
    raise "Invalid role. Role must be one of the following: system, assistant, or user."
  end
end
