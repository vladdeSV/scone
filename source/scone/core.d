module scone.core;

import scone.window;
import scone.os;
import scone.logger;
import std.stdio : File, writefln;
import std.datetime;

static this()
{
    if(inited) { return; }
    inited = true;

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
    if(!inited) { return; }
    inited = false;

    OS.deinit();
}

private __gshared static bool inited = false;

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