module scone.core;

public import scone.utility;
public import scone.layer;
public import scone.window;

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
        return !(moduleWINDOW || moduleKEYBOARD || moduleAUDIO);
    }
    if(hasFlag(cm, SconeModule.WINDOW))
    {
        r &= moduleWINDOW;
    }
    if(hasFlag(cm, SconeModule.KEYBOARD))
    {
        r &= moduleKEYBOARD;
    }
    if(hasFlag(cm, SconeModule.AUDIO))
    {
        r &= moduleAUDIO;
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

private:
bool hasFlag(SconeModule check, SconeModule type)
{
    return ((check & type) == type);
}
