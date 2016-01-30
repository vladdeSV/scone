module scone.core;

import scone.utility;
import scone.frame;
import scone.window;
import scone.keyboard;

enum SconeModule
{
    NONE = 0,
    WINDOW = 1,
    KEYBOARD = 2,
    AUDIO = 4 /* audio is unused/unimplemented */,
    ALL = WINDOW | KEYBOARD | AUDIO
}

/**
 * Initializes in SDL style
 *
 * Examples:
 * --------------------
 * sconeInit(SconeModule.WINDOW); //Initializes scone, where only drawing to the console screen will work
 * --------------------
 * Examples:
 * --------------------
 * sconeInit(SconeModule.ALL); //Initializes scone, where you can use all modules (drawing to the screen, getting key inputs)
 * --------------------
 * Examples:
 * --------------------
 * sconeInit(SconeModule.WINDOW | SconeModule.KEYBOARD); //Initializes scone, where you can draw to the screen and get key inputs.
 * --------------------
 */
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
    //if(hasFlag(cm, SconeModule.AUDIO))
    //{
    //   audioInit();
    //}
}

///Closes scone
auto sconeClose()
{
    windowClose();
    keyboardClose();
    //audioClose();
}

/+
/**
 * Returns: bool, true if any module is running
 */
auto sconeRunning()
{
    return !getModuleState(SconeModule.NONE);
}
+/

/**
 * Returns: bool, true if all modules entered are active.
 * Examples:
 * --------------------
 * sconeInit(SconeModule.WINDOW | SconeModule.KEYBOARD);
 *
 * assert( getModuleState(SconeModule.WINDOW));
 * assert( getModuleState(SconeModule.WINDOW | SconeModule.KEYBOARD));
 * assert(!getModuleState(SconeModule.NONE));
 *
 * sconeClose();
 * assert( getModuleState(SconeModule.NONE));
 * --------------------
 * Note: Does not work?
 */
@disable auto getModuleState(SconeModule cm)
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
    //if(hasFlag(cm, SconeModule.AUDIO))
    //{
    //    r &= moduleAudio;
    //}

    return r;
}

package(scone)
{
    auto moduleWindow   = false;
    auto moduleKeyboard = false;
    auto moduleAudio    = false;
}
