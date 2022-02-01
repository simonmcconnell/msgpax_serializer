defmodule Phoenix.Socket.V2.MsgpaxSerializerTest do
  use ExUnit.Case, async: true
  alias Phoenix.Socket.{Broadcast, Message, Reply}

  @serializer Phoenix.Socket.V2.MsgpaxSerializer

  @v2_fastlane_messagepack <<149, 192, 192, 161, "t", 161, "e", 129, 161, "m", 1>>
  @v2_reply_messagepack <<149, 192, 192, 161, "t", 169, "phx_reply", 130, 166, "status", 192, 168,
                          "response", 129, 161, "m", 1>>

  @v2_msg_messagepack <<149, 192, 192, 161, "t", 161, "e", 129, 161, "m", 1>>

  @client_push <<149, 162, "12", 163, "123", 165, "topic", 165, "event", 163, 101, 102, 103>>
  @reply <<149, 162, "12", 163, "123", 165, "topic", 162, "ok", 163, 101, 102, 103>>
  @broadcast <<149, 192, 192, 165, "topic", 165, "event", 163, 101, 102, 103>>

  def encode!(serializer, msg) do
    case serializer.encode!(msg) do
      {:socket_push, :text, encoded} ->
        assert is_list(encoded)
        IO.iodata_to_binary(encoded)

      {:socket_push, :binary, encoded} ->
        assert is_binary(encoded)
        encoded
    end
  end

  def decode!(serializer, msg, opts \\ []) do
    serializer.decode!(msg, opts)
  end

  def fastlane!(serializer, msg) do
    case serializer.fastlane!(msg) do
      {:socket_push, :text, encoded} ->
        assert is_list(encoded)
        IO.iodata_to_binary(encoded)

      {:socket_push, :binary, encoded} ->
        assert is_binary(encoded)
        encoded
    end
  end

  test "encode!/1 encodes `Phoenix.Socket.Message` as MessagePack" do
    msg = %Message{topic: "t", event: "e", payload: %{m: 1}}
    assert encode!(@serializer, msg) == @v2_msg_messagepack
  end

  test "encode!/1 raises when payload is not a map" do
    msg = %Message{topic: "t", event: "e", payload: "invalid"}
    assert_raise ArgumentError, fn -> encode!(@serializer, msg) end
  end

  test "encode!/1 encodes `Phoenix.Socket.Reply` as MessagePack" do
    msg = %Reply{topic: "t", payload: %{m: 1}}
    assert encode!(@serializer, msg) == @v2_reply_messagepack
  end

  test "decode!/2 decodes `Phoenix.Socket.Message` from MessagePack" do
    assert %Message{topic: "t", event: "e", payload: %{"m" => 1}} ==
             decode!(@serializer, @v2_msg_messagepack, opcode: :text)
  end

  test "fastlane!/1 encodes a broadcast into a message as MessagePack" do
    msg = %Broadcast{topic: "t", event: "e", payload: %{m: 1}}
    assert fastlane!(@serializer, msg) == @v2_fastlane_messagepack
  end

  test "fastlane!/1 raises when payload is not a map" do
    msg = %Broadcast{topic: "t", event: "e", payload: "invalid"}
    assert_raise ArgumentError, fn -> fastlane!(@serializer, msg) end
  end

  describe "binary encode" do
    test "general pushed message" do
      push = <<149, 162, "12", 192, 165, "topic", 165, "event", 163, 101, 102, 103>>

      assert encode!(@serializer, %Phoenix.Socket.Message{
               join_ref: "12",
               ref: nil,
               topic: "topic",
               event: "event",
               payload: {:binary, <<101, 102, 103>>}
             }) == push
    end

    # test "encode with oversized headers" do
    #   assert_raise ArgumentError, ~r/unable to convert topic to binary/, fn ->
    #     encode!(@serializer, %Phoenix.Socket.Message{
    #       join_ref: "12",
    #       ref: nil,
    #       topic: String.duplicate("t", 256),
    #       event: "event",
    #       payload: {:binary, <<101, 102, 103>>}
    #     })
    #   end

    #   assert_raise ArgumentError, ~r/unable to convert event to binary/, fn ->
    #     encode!(@serializer, %Phoenix.Socket.Message{
    #       join_ref: "12",
    #       ref: nil,
    #       topic: "topic",
    #       event: String.duplicate("e", 256),
    #       payload: {:binary, <<101, 102, 103>>}
    #     })
    #   end

    #   assert_raise ArgumentError, ~r/unable to convert join_ref to binary/, fn ->
    #     encode!(@serializer, %Phoenix.Socket.Message{
    #       join_ref: String.duplicate("j", 256),
    #       ref: nil,
    #       topic: "topic",
    #       event: "event",
    #       payload: {:binary, <<101, 102, 103>>}
    #     })
    #   end
    # end

    test "reply" do
      assert encode!(@serializer, %Phoenix.Socket.Reply{
               join_ref: "12",
               ref: "123",
               topic: "topic",
               status: :ok,
               payload: {:binary, <<101, 102, 103>>}
             }) == @reply
    end

    # test "reply with oversized headers" do
    #   assert_raise ArgumentError, ~r/unable to convert ref to binary/, fn ->
    #     encode!(@serializer, %Phoenix.Socket.Reply{
    #       join_ref: "12",
    #       ref: String.duplicate("r", 256),
    #       topic: "topic",
    #       status: :ok,
    #       payload: {:binary, <<101, 102, 103>>}
    #     })
    #   end
    # end

    test "fastlane" do
      assert fastlane!(@serializer, %Phoenix.Socket.Broadcast{
               topic: "topic",
               event: "event",
               payload: {:binary, <<101, 102, 103>>}
             }) == @broadcast
    end

    # test "fastlane with oversized headers" do
    #   assert_raise ArgumentError, ~r/unable to convert topic to binary/, fn ->
    #     fastlane!(@serializer, %Phoenix.Socket.Broadcast{
    #       topic: String.duplicate("t", 256),
    #       event: "event",
    #       payload: {:binary, <<101, 102, 103>>}
    #     })
    #   end

    #   assert_raise ArgumentError, ~r/unable to convert event to binary/, fn ->
    #     fastlane!(@serializer, %Phoenix.Socket.Broadcast{
    #       topic: "topic",
    #       event: String.duplicate("e", 256),
    #       payload: {:binary, <<101, 102, 103>>}
    #     })
    #   end
    # end
  end

  describe "binary decode" do
    test "pushed message" do
      assert decode!(@serializer, @client_push, opcode: :binary) == %Phoenix.Socket.Message{
               join_ref: "12",
               ref: "123",
               topic: "topic",
               event: "event",
               payload: {:binary, <<101, 102, 103>>}
             }
    end
  end
end
