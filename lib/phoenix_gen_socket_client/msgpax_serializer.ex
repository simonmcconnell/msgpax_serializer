if Code.ensure_loaded?(Phoenix.Channels.GenSocketClient.Serializer) do
  defmodule Phoenix.Channels.GenSocketClient.Serializer.Msgpax do
    @moduledoc "MessagePack serializer for the [phoenix_gen_socket_client](https://hexdocs.pm/phoenix_gen_socket_client)."
    @behaviour Phoenix.Channels.GenSocketClient.Serializer

    @doc false
    def decode_message(encoded_message, _opts) do
      Msgpax.unpack!(encoded_message)
    end

    @doc false
    def encode_message(message) do
      with {:ok, encoded} <- Msgpax.pack(message) do
        {:ok, {:text, encoded}}
      end
    end
  end
end
