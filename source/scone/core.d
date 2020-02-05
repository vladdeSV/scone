module scone.core;

import scone.frame.frame : Frame;
import scone.input.input : Input;
import scone.os.window : Window;

Frame frame;
Input input;

//todo: scone settings
// - use default scone exit handler on ctrl+c
// - automatically resize window buffer
// - default cell colors

private __gshared Window window;

static this()
{
    if(!(window is null))
    {
        return;
    }

    import std.stdio : writeln;

    version(unittest)
    {
        import scone.misc.dummy_window : DummyWindow;

        window = new DummyWindow();
        writeln("dummy");
    }
    else version(Posix)
    {
        import scone.os.posix.posix_terminal : PosixTerminal;

        window = new PosixTerminal();
        writeln("posix");
    }
    else version(Windows)
    {
        import scone.os.windows.windows_console : WindowsConsole;

        window = new WindowsConsole();
        writeln("windows");
    }

    frame = new Frame(window);
    input = new Input(window);
}
