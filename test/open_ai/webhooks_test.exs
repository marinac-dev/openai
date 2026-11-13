defmodule OpenAi.WebhooksTest do
  use ExUnit.Case, async: true

  alias OpenAi.Error
  alias OpenAi.Webhooks

  @key "super-secret-key-bytes"
  @secret "whsec_" <> Base.encode64(@key)
  @payload ~s({"id":"evt_1","type":"response.completed"})
  @now 1_700_000_000

  defp sign(key, id, ts, payload) do
    "v1," <> Base.encode64(:crypto.mac(:hmac, :sha256, key, "#{id}.#{ts}.#{payload}"))
  end

  defp headers(signature, ts \\ @now) do
    [{"Webhook-Id", "msg_1"}, {"Webhook-Timestamp", "#{ts}"}, {"Webhook-Signature", signature}]
  end

  defp verify(payload, headers, secret \\ @secret) do
    Webhooks.verify(payload, headers, secret, now: @now)
  end

  test "accepts a valid signature, with list or map headers" do
    sig = sign(@key, "msg_1", @now, @payload)
    assert :ok = verify(@payload, headers(sig))
    assert :ok = verify(@payload, Map.new(headers(sig)))
  end

  test "accepts when any of several signatures matches" do
    sig = "v1,bm9wZQ== v2,ignored " <> sign(@key, "msg_1", @now, @payload)
    assert :ok = verify(@payload, headers(sig))
  end

  test "rejects a tampered body" do
    sig = sign(@key, "msg_1", @now, @payload)
    assert {:error, %Error{kind: :webhook}} = verify(@payload <> " ", headers(sig))
  end

  test "rejects stale and future timestamps" do
    old = @now - 301
    future = @now + 301

    assert {:error, %Error{kind: :webhook, message: "Webhook timestamp is too old"}} =
             verify(@payload, headers(sign(@key, "msg_1", old, @payload), old))

    assert {:error, %Error{kind: :webhook, message: "Webhook timestamp is too new"}} =
             verify(@payload, headers(sign(@key, "msg_1", future, @payload), future))
  end

  test "rejects missing headers" do
    assert {:error, %Error{kind: :webhook, message: "Missing required webhook header: webhook-id"}} =
             verify(@payload, [{"webhook-timestamp", "1"}])
  end

  test "supports a raw secret without the whsec_ prefix" do
    sig = sign("plain", "msg_1", @now, @payload)
    assert :ok = verify(@payload, headers(sig), "plain")
  end

  test "unwrap decodes the verified event" do
    sig = sign(@key, "msg_1", @now, @payload)

    assert {:ok, %{"id" => "evt_1", "type" => "response.completed"}} =
             Webhooks.unwrap(@payload, headers(sig), @secret, now: @now)

    assert {:error, %Error{kind: :webhook}} = Webhooks.unwrap("{}", headers(sig), @secret, now: @now)
  end
end
