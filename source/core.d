module scone.core;

import scone.utility;
public import scone.layer;
public import scone.window;

enum SconeModule
{
    None = 0,
    Window = 1,
    Keyboard = 2,
    Audio = 4 /* audio is unused/unimplemented */,
    All = Window | Keyboard | Audio
}

auto sconeInit(SconeModule cm = SconeModule.All)
{
    if(hasFlag(cm, SconeModule.Window))
    {
        windowInit();
    }
    if(hasFlag(cm, SconeModule.Keyboard))
    {
       //keyboardInit();
    }
    if(hasFlag(cm, SconeModule.Audio))
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

    if(hasFlag(cm, SconeModule.None))
    {
        return !(moduleWindow || moduleKeyboard || moduleAudio);
    }
    if(hasFlag(cm, SconeModule.Window))
    {
        r &= moduleWindow;
    }
    if(hasFlag(cm, SconeModule.Keyboard))
    {
        r &= moduleKeyboard;
    }
    if(hasFlag(cm, SconeModule.Audio))
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
    return !getModuleState(SconeModule.None);
}

private:
bool hasFlag(SconeModule check, SconeModule type)
{
    return ((check & type) == type);
}


bool hasFlag2(Enum)(Enum check, Enum type) if (is(typeof(Enum) == enum))
{
    return ((check & type) == type);
}
