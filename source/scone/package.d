module scone;

public import scone.window;
public import scone.color;

ref Window window() @property
{
    return _window;
}

import scone.os;
shared static this()
{
    OS.init();

    //TEMP,
    version(Windows)
    {
        _window = Window(80,24);
    }

    version(Posix)
    {
        _window = Window(80,24);
    }
}

private Window _window;
