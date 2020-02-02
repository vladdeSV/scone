module scone.os.posix.posix_terminal;

version (Posix)
{
    import core.sys.posix.sys.ioctl : ioctl, winsize, TIOCGWINSZ;
    import core.sys.posix.unistd : STDOUT_FILENO;
    import scone.input.input_event : InputEvent;
    import scone.input.scone_control_key : SCK;
    import scone.input.scone_key : SK;
    import scone.os.window : Window;
    import scone.os.posix.foo : Foos, PartialRowOutput;
    import scone.frame.buffer : Buffer;
    import scone.frame.cell : Cell;
    import scone.frame.color;
    import scone.frame.coordinate : Coordinate;
    import scone.frame.size : Size;
    import std.conv : text;
    import std.stdio : writef, stdout;

    class PosixTerminal : Window
    {
        this()
        {
            /+
            termios termInfo;
            tcgetattr(STDOUT_FILENO, &termInfo);
            termInfo.c_lflag &= ~ECHO;
            tcsetattr(STDOUT_FILENO, TCSADRAIN, &termInfo);
            +/
        }

        Size size()
        {
            winsize w;
            ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
            return Size(w.ws_col, w.ws_row);
        }

        void size(Size size)
        {
            writef("\033[8;%s;%st", size.height, size.width);
            stdout.flush();
        }

        void clear() {
            writef("\033[2J");
            stdout.flush();
        }

        void title(dstring title)
        {
            writef("\033]0;%s\007", title);
            stdout.flush();
        }

        void renderBuffer(Buffer buffer)
        {
            auto foos = new Foos(buffer);

            foreach (PartialRowOutput data; foos.partialRows())
            {
                this.cursorPosition(data.coordinate);
                .writef(data.output);
            }

            .writef("\033[0m");

            stdout.flush();
        }

        InputEvent[] latestInputEvents()
        {
            return [];
        }

        private void cursorPosition(in Coordinate coordinate)
        {
            writef("\033[%d;%dH", coordinate.y + 1, coordinate.x + 1);
            stdout.flush();
        }
    }
}
