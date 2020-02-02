module scone.core;

import scone.frame.frame : Frame;
import scone.input.input : Input;
import scone.os.window : Window;

Frame frame;
Input input;

static this()
{
    Window window;

    version(Posix)
    {
        import scone.os.posix.posix_terminal : PosixTerminal;

        window = new PosixTerminal();
    }

    version(Windows)
    {
        import scone.os.windows.windows_console : WindowsConsole;

        window = new WindowsConsole();
    }

    frame = new Frame(window);
    input = new Input(window);
}
