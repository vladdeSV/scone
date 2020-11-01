module scone.output.os.posix.posix_output;

version (Posix)
{
    import scone.output.os.standard_output : StandardOutput;
    import scone.output.types.size : Size;
    import scone.output.types.coordinate : Coordinate;
    import scone.output.buffer : Buffer;
    import scone.output.os.posix.partial_row_output_handler : PartialRowOutputHandler, PartialRowOutput;

    import core.sys.posix.sys.ioctl : ioctl, winsize, TIOCGWINSZ;
    import std.stdio : writef, stdout;
    import core.sys.posix.unistd : STDOUT_FILENO;

    class PosixOutput : StandardOutput
    {
        void initialize()
        {
            this.cursorVisible(false);
            this.clear();
            this.lastSize = this.size();
        }

        void deinitialize()
        {
            this.cursorVisible(true);
            this.clear();
            this.cursorPosition(Coordinate(0, 0));
        }

        void renderBuffer(Buffer buffer)
        {
            auto currentSize = this.size();
            if (currentSize != lastSize)
            {
                this.clear();
                buffer.redraw();
                lastSize = currentSize;
            }

            auto foos = PartialRowOutputHandler(buffer);

            foreach (PartialRowOutput data; foos.partialRows())
            {
                this.cursorPosition(data.coordinate);
                .writef(data.output);
            }

            .writef("\033[0m");

            stdout.flush();
        }

        Size size()
        {
            winsize w;
            ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
            return Size(w.ws_col, w.ws_row);
        }

        void size(in Size size)
        {
            writef("\033[8;%s;%st", size.height, size.width);
            stdout.flush();
        }

        void title(in string title)
        {
            writef("\033]0;%s\007", title);
            stdout.flush();
        }

        void cursorVisible(in bool visible)
        {
            writef("\033[?25%s", visible ? "h" : "l");
            stdout.flush();
        }

        private void cursorPosition(in Coordinate coordinate)
        {
            writef("\033[%d;%dH", coordinate.y + 1, coordinate.x + 1);
            stdout.flush();
        }

        private void clear()
        {
            writef("\033[2J");
            stdout.flush();
        }

        private Size lastSize;
    }
}
