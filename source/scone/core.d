module scone.core;

import scone.window;
import scone.os;
import scone.logger;
import std.stdio : File, writefln;
import std.datetime;

shared static this()
{
    //init the logfile
    logfile = File("scone.log", "w+");
    logfile.writefln("scone: %s", Clock.currTime().toISOExtString());
    
    //init the console/terminal
    OS.init();

    //get current width and height
    auto w = OS.size[0];
    auto h = OS.size[1];

    //init window
    window = Window(w,h);
}

shared static ~this()
{
    OS.deinit();
}

///global window (aka console/terminal)
static Window window;