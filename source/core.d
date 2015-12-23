module scone.core;

import scone.window;

enum SconeModule
{
    NONE = 0,
    WINDOW = 1,
    KEYBOARD = 2,
    AUDIO = 4 /* audio is unused/unimplemented */,
    ALL = WINDOW | KEYBOARD | AUDIO
}

auto sconeInit(SconeModule cm)
{
    if(hasFlag(cm, SconeModule.WINDOW))
    {
        windowInit();
    }
    if(hasFlag(cm, SconeModule.KEYBOARD))
    {
       //keyboardInit();
    }
    if(hasFlag(cm, SconeModule.AUDIO))
    {
       //audioInit();
    }
}

auto sconeClose()
{
    windowClose();
    //keyboardClose();
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

protected:
__gshared bool moduleWindow   = false;
__gshared bool moduleKeyboard = false;
__gshared bool moduleAudio    = false;

private:
bool hasFlag(SconeModule check, SconeModule type) {
    return ((check & type) == type);
}
