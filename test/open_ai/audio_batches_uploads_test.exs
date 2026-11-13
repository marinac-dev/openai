defmodule OpenAi.AudioBatchesUploadsTest do
  use ExUnit.Case, async: true

  alias OpenAi.{Audio, Batches, Client, ContentProvenance, Images, Uploads}
  alias OpenAi.Audio.VoiceConsents

  @file_part {:file_content, "bytes", "f.bin"}

  defp client do
    owner = self()

    Client.new(
      api_key: "test-key",
      base_url: "https://example.test/v1",
      max_retries: 0,
      requester: fn request, _finch, _opts ->
        send(owner, {:request, request})
        {:ok, %Finch.Response{status: 200, headers: [{"content-type", "application/json"}], body: "{}"}}
      end
    )
  end

  test "endpoints use the expected method, path, query, and JSON body" do
    c = client()

    cases = [
      {fn -> Audio.speech(c, %{input: "hi"}) end, "POST", "/v1/audio/speech"},
      {fn -> Images.generate(c, %{prompt: "p"}) end, "POST", "/v1/images/generations"},
      {fn -> Images.edit(c, %{prompt: "p"}) end, "POST", "/v1/images/edits"},
      {fn -> VoiceConsents.list(c, limit: 2) end, "GET", "/v1/audio/voice_consents"},
      {fn -> VoiceConsents.retrieve(c, "c 1") end, "GET", "/v1/audio/voice_consents/c%201"},
      {fn -> VoiceConsents.update(c, "c 1", %{name: "n"}) end, "POST", "/v1/audio/voice_consents/c%201"},
      {fn -> VoiceConsents.delete(c, "c 1") end, "DELETE", "/v1/audio/voice_consents/c%201"},
      {fn -> Batches.create(c, %{endpoint: "/v1/x"}) end, "POST", "/v1/batches"},
      {fn -> Batches.list(c, limit: 2) end, "GET", "/v1/batches"},
      {fn -> Batches.retrieve(c, "b 1") end, "GET", "/v1/batches/b%201"},
      {fn -> Batches.cancel(c, "b 1") end, "POST", "/v1/batches/b%201/cancel"},
      {fn -> Uploads.create(c, %{purpose: "batch"}) end, "POST", "/v1/uploads"},
      {fn -> Uploads.complete(c, "u 1", %{part_ids: []}) end, "POST", "/v1/uploads/u%201/complete"},
      {fn -> Uploads.cancel(c, "u 1") end, "POST", "/v1/uploads/u%201/cancel"}
    ]

    for {call, method, path} <- cases do
      assert {:ok, _} = call.()
      assert_receive {:request, request}
      assert request.method == method
      assert request.path == path
    end
  end

  test "multipart endpoints send file fields" do
    c = client()

    cases = [
      {fn -> Audio.transcribe(c, %{file: @file_part, model: "m"}) end, "/v1/audio/transcriptions", "file"},
      {fn -> Audio.translate(c, %{file: @file_part, model: "m"}) end, "/v1/audio/translations", "file"},
      {fn -> Audio.create_voice(c, %{audio_sample: @file_part}) end, "/v1/audio/voices", "audio_sample"},
      {fn -> VoiceConsents.create(c, %{recording: @file_part}) end, "/v1/audio/voice_consents", "recording"},
      {fn -> Images.edit_upload(c, %{image: @file_part}) end, "/v1/images/edits", "image"},
      {fn -> Images.variation(c, %{image: @file_part}) end, "/v1/images/variations", "image"},
      {fn -> Uploads.add_part(c, "u 1", %{data: @file_part}) end, "/v1/uploads/u%201/parts", "data"},
      {fn -> ContentProvenance.check(c, %{file: @file_part}) end, "/v1/content_provenance_checks", "file"}
    ]

    for {call, path, field} <- cases do
      assert {:ok, _} = call.()
      assert_receive {:request, request}
      assert request.method == "POST"
      assert request.path == path
      {:stream, stream} = request.body
      body = stream |> Enum.to_list() |> IO.iodata_to_binary()
      assert body =~ ~s(name="#{field}"; filename="f.bin")
    end
  end

  test "speech returns raw bytes" do
    owner = self()

    c =
      Client.new(
        api_key: "k",
        base_url: "https://example.test/v1",
        max_retries: 0,
        requester: fn request, _finch, _opts ->
          send(owner, {:request, request})
          {:ok, %Finch.Response{status: 200, headers: [{"content-type", "audio/mpeg"}], body: <<1, 2, 3>>}}
        end
      )

    assert {:ok, <<1, 2, 3>>} = Audio.speech(c, %{input: "hi"})
  end
end
