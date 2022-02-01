if Code.ensure_loaded?(Phoenix.Socket.Serializer) do
  defmodule Phoenix.Socket.V2.MsgpaxSerializer do
    @moduledoc "MessagePack serializer for a [Phoenix Socket](https://hexdocs.pm/phoenix/Phoenix.Socket.html)."
    @behaviour Phoenix.Socket.Serializer
    alias Phoenix.Socket.{Broadcast, Message, Reply}

    @impl true
    def fastlane!(%Broadcast{payload: {:binary, data}} = msg) do
      bin = Msgpax.pack!([nil, nil, msg.topic, msg.event, data], iodata: false)
      {:socket_push, :binary, bin}
    end

    def fastlane!(%Broadcast{payload: %{}} = msg) do
      bin = Msgpax.pack!([nil, nil, msg.topic, msg.event, msg.payload])
      {:socket_push, :text, bin}
    end

    def fastlane!(%Broadcast{payload: invalid}) do
      raise ArgumentError, "expected broadcasted payload to be a map, got: #{inspect(invalid)}"
    end

    @impl true
    def encode!(%Reply{payload: {:binary, data}} = reply) do
      bin = Msgpax.pack!([reply.join_ref, reply.ref, reply.topic, reply.status, data], iodata: false)
      {:socket_push, :binary, bin}
    end

    def encode!(%Reply{} = reply) do
      bin =
        Msgpax.pack!([
          reply.join_ref,
          reply.ref,
          reply.topic,
          "phx_reply",
          %{status: reply.status, response: reply.payload}
        ])

      {:socket_push, :text, bin}
    end

    def encode!(%Message{payload: {:binary, data}} = msg) do
      bin = Msgpax.pack!([msg.join_ref, msg.ref, msg.topic, msg.event, data], iodata: false)
      {:socket_push, :binary, bin}
    end

    def encode!(%Message{payload: %{}} = msg) do
      bin = Msgpax.pack!([msg.join_ref, msg.ref, msg.topic, msg.event, msg.payload])
      {:socket_push, :text, bin}
    end

    def encode!(%Message{payload: invalid}) do
      raise ArgumentError, "expected payload to be a map, got: #{inspect(invalid)}"
    end

    @impl true
    def decode!(raw_message, opts) do
      [join_ref, ref, topic, event, payload | _] = Msgpax.unpack!(raw_message)

      payload =
        case Keyword.fetch(opts, :opcode) do
          {:ok, :text} -> payload
          {:ok, :binary} -> {:binary, payload}
        end

      %Message{
        topic: topic,
        event: event,
        payload: payload,
        ref: ref,
        join_ref: join_ref
      }
    end
  end
end
