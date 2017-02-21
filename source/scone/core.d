module scone.core;

import scone.window;
import scone.os;
import scone.logger;
import std.stdio : File, writefln;
import std.datetime;

version(Windows)
{
    static this()
    {
        initialize();
    }
}
else
{
    shared static this()
    {
        initialize();
    }
}

//init funciton, called by either `static this()` on Windows, or `shared static this()` on POSIX
static private void initialize()
{
    //init the logfile
    logfile = File("scone.log", "w+");
    logfile.writefln("scone: %s", Clock.currTime().toISOExtString());

    //get current width and height
    OS.init();
    auto w = OS.size[0];
    auto h = OS.size[1];

    //init window
    window = Window(w,h);
}

static ~this()
{
    OS.deinit();
}

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