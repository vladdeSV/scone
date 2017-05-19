module scone.core;

import scone.window;
import scone.os;
import std.stdio : File, writefln;

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

static ~this()
{
    if(!inited) { return; }
    inited = false;

    OS.deinit();
}

//ugh, i need this for checking if program has exited in other thread
package(scone) __gshared static bool inited = false;

/**
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