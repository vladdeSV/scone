module scone.audio.audio;

interface StandardAudio
{

}

class DummyAudio : StandardAudio
{

}

alias AudioId = size_t;

class Audio
{
    this(StandardAudio standardAudio)
    {

    }

    AudioId register(string path)
    {
        this.tempAudioIdCounter++;
        return tempAudioIdCounter;
    }

    AudioHandle play(AudioId id)
    {
        return new AudioHandle(id);
    }

    void stop(ref AudioHandle handle)
    {
        handle = null;
    }

    private uint tempAudioIdCounter;
}

class AudioHandle
{
    this(AudioId id)
    {
        this.id = id;
    }

    private AudioId id;
}

unittest
{
    auto standardAudio = new DummyAudio();
    auto audio = new Audio(standardAudio);

    auto audioId1 = audio.register("audio/snd1");
    auto audioId2 = audio.register("audio/snd1");

    assert(audioId1 != audioId2);

    auto audioHandle1 = audio.play(audioId1);
    assert(audioHandle1 !is null);

    audio.stop(audioHandle1);
    assert(audioHandle1 is null);
}