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
    //todo this isn't really thread safe. but it works. wait i'm not actually sure if it's unsafe or not.
    if(window !is null)
    {
        return;
    }

    window = createApplicationWindow();

    frame = new Frame(window);
    input = new Input(window);
}

private Window createApplicationWindow()
{
    version(unittest)
    {
        import scone.misc.dummy_window : DummyWindow;

        // use dummy when unittesting. (previously could cause haning when starting to poll input with travis-ci)
        return new DummyWindow();
    }
    else version(Posix)
    {
        import scone.os.posix.posix_terminal : PosixTerminal;

        return new PosixTerminal();
    }
    else version(Windows)
    {
        import scone.os.windows.windows_console : WindowsConsole;

        return new WindowsConsole();
    }
}
