module scone.audio.audio;

import std.algorithm: canFind;

interface StandardAudio
{

}

class DummyAudio : StandardAudio
{

}

alias AudioId = size_t;
alias AudioHandle = size_t;

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
        this.tempAudioHandleCounter++;
        return tempAudioHandleCounter;
    }

    void stop(ref AudioHandle handle)
    {
        
    }

    bool isValidHandle(AudioHandle handle)
    {
        return true; //fixme check some sort of array for
    }

    private uint tempAudioIdCounter, tempAudioHandleCounter;
}

unittest
{
    auto standardAudio = new DummyAudio();
    auto audio = new Audio(standardAudio);

    auto audioId1 = audio.register("audio/snd1");
    auto audioId2 = audio.register("audio/snd1");
    auto audioId3 = audio.register("audio/snd2");

    assert(audioId1 != audioId2);
    assert(audioId1 != audioId3);

    auto audioHandle1 = audio.play(audioId1);
    assert(audio.isValidHandle(audioHandle1));

    audio.stop(audioHandle1);
    //assert(!audio.isValidHandle(audioHandle1));
}