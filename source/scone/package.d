module scone;

public import scone.window;
public import scone.color;
public import scone.os;

shared static this()
{
    OS.init();

    auto w = OS.size[0];
    auto h = OS.size[1];

    //TEMP,
    version(Windows)
    {
        _window = Window(w,h);
    }

    version(Posix)
    {
        _window = Window(w,h);
    }
}

private Window _window;
ref Window window() @property
{
    return _window;
}
