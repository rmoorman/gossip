defmodule Web.Socket.Module do
  @moduledoc """
  A Module is tied to a support flag

  Similar to a Phoenix controller
  """

  defmacro __using__(_) do
    quote do
      import Web.Socket.Module

      alias Web.Socket.Module.Token

      def token() do
        %Token{assigns: %{}, view: __MODULE__.View}
      end

      def event(token, name) do
        event = token.view.event(name, token.assigns)
        %{token | payload: event}
      end

      def payload(token, name) do
        payload = token.view.payload(name, token.assigns)
        %{token | payload: payload}
      end
    end
  end

  defmodule Token do
    @moduledoc """
    Token struct for broadcasting an event
    """

    defstruct [:assigns, :payload, :view]
  end

  def assign(token, field, value) do
    assigns = Map.put(token.assigns, field, value)
    %{token | assigns: assigns}
  end

  @doc """
  Relay an event to the socket
  """
  def relay(token) do
    send(self(), {:broadcast, token.payload})
  end

  @doc """
  Broadcast over the internal phoenix channel
  """
  def broadcast(token, topic, event) do
    Web.Endpoint.broadcast(topic, event, token.payload)
  end
end
