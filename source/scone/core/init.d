module scone.core.init;

import scone.frame.frame : Frame;
import scone.input.input : Input;
import scone.os.window : Window;
import std.experimental.logger;

//todo: scone settings
// - use default scone exit handler on ctrl+c
// - automatically resize window buffer
// - default cell colors

Frame frame;
Input input;
private Window window;
private shared initialized = false;

static this()
{
    if (initialized)
    {
        return;
    }

    initialized = true;

    sharedLog = new FileLogger("scone.log");

    window = createApplicationWindow();

    frame = new Frame(window);
    input = new Input(window);
}

private Window createApplicationWindow()
{
    version (unittest)
    {
        import scone.misc.dummy_window : DummyWindow;

        // use dummy when unittesting. (previously could cause hanging when starting to poll input with travis-ci)
        return new DummyWindow();
    }
    else version (Posix)
    {
        import scone.os.posix.posix_terminal : PosixTerminal;

        return new PosixTerminal();
    }
    else version (Windows)
    {
        import scone.os.windows.windows_console : WindowsConsole;

        return new WindowsConsole();
    }
}
