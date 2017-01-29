module scone.core;

import scone.window;
import scone.os;

shared static this()
{
    //init the console/terminal
    OS.init();

    //get current width and height
    auto w = OS.size[0];
    auto h = OS.size[1];

    //init window
    window = Window(w,h);
}

/*
///get a reference to the window (aka console/terminal)
ref Window window() @property
{
    return _window;
}
*/

///global window (aka console/terminal)
static Window window;