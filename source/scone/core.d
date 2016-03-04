module scone.core;

import scone.utility;
import scone.frame;
import scone.window;
import scone.keyboard;
import std.experimental.logger;

/**
 * Modules that can be loaded by Scone
 */
enum SconeModule
{
    none = 0,
    window = 1,
    keyboard = 2,
    audio = 4 /* audio is unused/unimplemented */,
    all = window | keyboard | audio,
}

/**
 * Initializes in SDL style
 *
 * Examples:
 * --------------------
 * sconeInit(SconeModule.window); //Initializes scone, where only drawing to the console screen will work
 *
 * sconeInit(SconeModule.all); //Initializes scone, where you can use all modules (drawing to the screen, getting key inputs)
 *
 * sconeInit(SconeModule.window | SconeModule.keyboard); //Initializes scone, where you can draw to the screen and get key inputs.
 * --------------------
 */
auto sconeInit(SconeModule cm = SconeModule.all)
{
    if(hasFlag(cm, SconeModule.window))
    {
        windowInit();
    }
    if(hasFlag(cm, SconeModule.keyboard))
    {
       keyboardInit();
    }
    //if(hasFlag(cm, SconeModule.audio))
    //{
    //   audioInit();
    //}

    if(!isLogFile)
    {
        log = new FileLogger("scone.log");
        isLogFile = true;
    }
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
    return !getModuleState(SconeModule.none);
}

/**
 * Returns: bool, true if all modules entered are active.
 * Examples:
 * --------------------
 * sconeInit(SconeModule.window | SconeModule.keyboard);
 *
 * assert( getModuleState(SconeModule.window));
 * assert( getModuleState(SconeModule.window | SconeModule.keyboard));
 * assert(!getModuleState(SconeModule.none));
 *
 * sconeClose();
 * assert( getModuleState(SconeModule.none));
 * --------------------
 * Note: Does not work?
 */
auto getModuleState(SconeModule cm)
{
    bool r = true;

    if(hasFlag(cm, SconeModule.none))
    {
        return !(moduleWindow || moduleKeyboard || moduleAudio);
    }
    if(hasFlag(cm, SconeModule.window))
    {
        r &= moduleWindow;
    }
    if(hasFlag(cm, SconeModule.keyboard))
    {
        r &= moduleKeyboard;
    }
    //if(hasFlag(cm, SconeModule.audio))
    //{
    //    r &= moduleAudio;
    //}

    return r;
}
+/

package(scone)
{
    auto moduleWindow   = false;
    auto moduleKeyboard = false;
    auto moduleAudio    = false;

    auto isLogFile = false;
    static FileLogger log;
}
