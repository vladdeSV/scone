module scone.core;

import scone.window;
import scone.os;

/**
 * Gateway to the console/terminal
 * All methods are called via this
 *
 * Example:
 * ---
 * void main()
 * {
 *     bool running = true;
 *     window.title = "i am happy";
 *     while(running)
 *     {
 *         foreach(input; window.getInputs)
 *         {
 *             if(input.key == SK.escape)
 *             {
 *                 running = false;
 *             }
 *         }
 *
 *         window.clear();
 *         window.write(0,0, "hello world", Color.red.fg, '!', Color.white.bg, 42);
 *         window.print();
 *     }
 * }
 * ---
 */
__gshared Window window;

/**
 * Initializes scone
 */
shared static this()
{
    //get current width and height
    OS.init();
    auto w = OS.size[0];
    auto h = OS.size[1];

    //init window
    window = Window(w,h);
}

/**
 * Deinitializes scone
 */
shared static ~this()
{
    OS.deinit();
}
