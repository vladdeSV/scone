module scone.core;

import scone.window;
import scone.os;

/**
 * Gateway to the console/terminal
 * All methods are called via this
 *
 *
 *  .M"""bgd
 * ,MI    "Y
 * `MMb.      ,p6"bo   ,pW"Wq.`7MMpMMMb.  .gP"Ya
 *   `YMMNq. 6M'  OO  6W'   `Wb MM    MM ,M'   Yb
 * .     `MM 8M       8M     M8 MM    MM 8M""""""
 * Mb     dM YM.    , YA.   ,A9 MM    MM YM.    ,
 * P"Ybmmd"   YMbmd'   `Ybmd9'.JMML  JMML.`Mbmmd'
 *
 *        -- Cross-Platform CLI Library --
 *
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
