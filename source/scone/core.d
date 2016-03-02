module scone.core;

import scone.utility;
import scone.frame;
import scone.window;
import scone.keyboard;
import std.experimental.logger;

/**
 * Modules that can be loaded by Scone
 */
enum sconeModule
{
    None = 0,
    Window = 1,
    Keyboard = 2,
    Audio = 4 /* audio is unused/unimplemented */,
    All = Window | Keyboard | Audio
}

/**
 * Initializes in SDL style
 *
 * Examples:
 * --------------------
 * sconeInit(sconeModule.Window); //Initializes scone, where only drawing to the console screen will work
 *
 * sconeInit(sconeModule.All); //Initializes scone, where you can use all modules (drawing to the screen, getting key inputs)
 *
 * sconeInit(sconeModule.Window | sconeModule.Keyboard); //Initializes scone, where you can draw to the screen and get key inputs.
 * --------------------
 */
auto sconeInit(sconeModule cm = sconeModule.All)
{
    if(hasFlag(cm, sconeModule.Window))
    {
        windowInit();
    }
    if(hasFlag(cm, sconeModule.Keyboard))
    {
       keyboardInit();
    }
    //if(hasFlag(cm, sconeModule.Audio))
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
    return !getModuleState(sconeModule.None);
}

/**
 * Returns: bool, true if all modules entered are active.
 * Examples:
 * --------------------
 * sconeInit(sconeModule.Window | sconeModule.Keyboard);
 *
 * assert( getModuleState(sconeModule.Window));
 * assert( getModuleState(sconeModule.Window | sconeModule.Keyboard));
 * assert(!getModuleState(sconeModule.None));
 *
 * sconeClose();
 * assert( getModuleState(sconeModule.None));
 * --------------------
 * Note: Does not work?
 */
auto getModuleState(sconeModule cm)
{
    bool r = true;

    if(hasFlag(cm, sconeModule.None))
    {
        return !(moduleWindow || moduleKeyboard || moduleAudio);
    }
    if(hasFlag(cm, sconeModule.Window))
    {
        r &= moduleWindow;
    }
    if(hasFlag(cm, sconeModule.Keyboard))
    {
        r &= moduleKeyboard;
    }
    //if(hasFlag(cm, sconeModule.Audio))
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
