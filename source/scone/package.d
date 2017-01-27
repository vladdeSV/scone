module scone;

public import scone.window;
public import scone.color;

ref Window window() @property
{
    return _window;
}

import scone.os.independent;
shared static this()
{
    OS.init();

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
