module scone.core;

import scone.window;
import scone.os;

/**
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
 * Gateway to the console/terminal
 * All methods are called from here
 * Example:
 * ---
 * void main()
 * {
 *     window.title = "i am happy";
 *     while(true)
 *     {
 *         window.clear();
 *         window.write(0,0, "hello world", fg(red), '!', bg(white), 42);
 *         window.print();
 *     }
 * }
 * ---
 */
static Window window;

/**
 * Initializes scone
 */
static this()
{
    if(inited) { return; }

    //get current width and height
    OS.init();
    auto w = OS.size[0];
    auto h = OS.size[1];

    //init window
    window = Window(w,h);

    inited = true;
}

/**
 * Deinitializes scone
 */
static ~this()
{
    if(!inited) { return; }

    OS.deinit();

    inited = false;
}

//ugh, i need this for checking if program has exited in other thread
package(scone) __gshared static bool inited = false;
