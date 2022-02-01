# Msgpax Serializer

[![Hex Version](https://img.shields.io/hexpm/v/msgpax_serializer.svg)][hex]

Use [MessagePack][messagepack] via [Msgpax][msgpax] to serialize data sent over a [Phoenix Socket][phoenix-socket].

## Usage

### Phoenix Socket

Add `Phoenix.Socket.V2.MsgpaxSerializer` as the serializer for the websocket in `endpoint.ex`.

```elixir
socket "/triple-cream-brie-socket", CheeseFactoryWeb.TripleCreamBrieSocket,
  websocket: [serializer: [{Phoenix.Socket.V2.MsgpaxSerializer, "~> 2.0.0"}]],
  longpoll: false
```

### [PhoenixGenSocketClient][phoenix-gen-socket-client]

The fourth arg to `GenSocketClient.start_link` is the `socket_opts`, where you set `serialzer: Phoenix.Channels.GenSocketClient.Serializer.Msgpax`.

```elixir
GenSocketClient.start_link(
  __MODULE__,
  Phoenix.Channels.GenSocketClient.Transport.WebSocketClient,
  Keyword.put(opts, :url, "ws://cheese.factory/triple-cream-brie-socket/websocket"),
  [serializer: Phoenix.Channels.GenSocketClient.Serializer.Msgpax],
  name: __MODULE__
)
```

[docs]: https://hexdocs.pm/msgpax_serializer
[hex]: https://hexdocs.pm/packages/msgpax_serializer
[messagepack]: https://msgpack.org/
[msgpax]: https://hexdocs.pm/msgpax/Msgpax.html
[phoenix-socket]: https://hexdocs.pm/phoenix/Phoenix.Socket.html
[phoenix-gen-socket-client]: https://hexdocs.pm/phoenix_gen_socket_client