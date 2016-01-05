module scone.core;

public import scone.utility;
public import scone.layer;
public import scone.window;
public import scone.keyboard;

enum SconeModule
{
    NONE = 0,
    WINDOW = 1,
    KEYBOARD = 2,
    AUDIO = 4 /* audio is unused/unimplemented */,
    ALL = WINDOW | KEYBOARD | AUDIO
}

auto sconeInit(SconeModule cm = SconeModule.ALL)
{
    if(hasFlag(cm, SconeModule.WINDOW))
    {
        windowInit();
    }
    if(hasFlag(cm, SconeModule.KEYBOARD))
    {
       keyboardInit();
    }
    if(hasFlag(cm, SconeModule.AUDIO))
    {
    //   audioInit();
    }
}

auto sconeClose()
{
    windowClose();
    keyboardClose();
    //audioClose();
}

/*
* Returns: bool, true if all modules entered are active.
*/
auto getModuleState(SconeModule cm)
{
    bool r = true;

    if(hasFlag(cm, SconeModule.NONE))
    {
        return !(moduleWindow || moduleKeyboard || moduleAudio);
    }
    if(hasFlag(cm, SconeModule.WINDOW))
    {
        r &= moduleWindow;
    }
    if(hasFlag(cm, SconeModule.KEYBOARD))
    {
        r &= moduleKeyboard;
    }
    if(hasFlag(cm, SconeModule.AUDIO))
    {
        r &= moduleAudio;
    }

    return r;
}

/**
* Returns: bool, true if any module is running
*/
auto sconeRunning()
{
    return !getModuleState(SconeModule.NONE);
}
