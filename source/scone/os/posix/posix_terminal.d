module scone.os.posix.posix_terminal;

version (Posix)
{
    import core.sys.posix.fcntl;
    import core.sys.posix.poll;
    import core.sys.posix.sys.ioctl : ioctl, winsize, TIOCGWINSZ;
    import core.sys.posix.termios;
    import core.sys.posix.unistd : read, STDOUT_FILENO;
    import core.thread : Thread;
    import scone.frame.buffer : Buffer;
    import scone.frame.cell : Cell;
    import scone.frame.color;
    import scone.frame.coordinate : Coordinate;
    import scone.frame.size : Size;
    import scone.input.input_event : InputEvent;
    import scone.input.scone_control_key : SCK;
    import scone.input.scone_key : SK;
    import scone.os.posix.foo : Foos, PartialRowOutput;
    import scone.os.posix.locale.input_map : InputMap;
    import scone.os.posix.locale.locale : Locale;
    import scone.os.window : Window;
    import std.concurrency : spawn, Tid, thisTid, send, receiveTimeout, ownerTid;
    import std.conv : text;
    import std.datetime : Duration, msecs;
    import std.stdio : writef, stdout;

    extern (C)
    {
        void cfmakeraw(termios* termios_p);
    }

    struct ResizeEvent
    {
        Size newSize;
    }

    class PosixTerminal : Window
    {
        void initializeOutput()
        {
            spawn(&pollTerminalResize, size);
            this.cursorVisible(false);
        }

        void deinitializeOutput()
        {
            this.cursorVisible(true);
        }

        void initializeInput()
        {
            this.setInputMapping();
            this.enableRawInput();
            this.startPollingInput();
        }

        void deinitializeInput()
        {
            this.resetTerminalState();
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

        uint[] retreiveInputSequence()
        {
            uint[] sequence;

            while (receiveTimeout(5.msecs, (uint code) { sequence ~= code; }))
            {
            }

            return sequence;
        }

        InputEvent[] latestInputEvents()
        {
            auto sequence = this.retreiveInputSequence();

            //todo: returns null here. should this logic be here or in `inputMap.inputEventsFromSequence(sequence)` instead?
            if (sequence.length == 0)
            {
                return null;
            }

            return inputMap.inputEventsFromSequence(sequence);
        }

        private static void pollTerminalResize(Size initialSize)
        {
            Thread.getThis.isDaemon = true;

            Size previousSize = initialSize;

            while (true)
            {
                Thread.sleep(250.msecs);

                winsize w;
                ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
                Size currentSize = Size(w.ws_col, w.ws_row);

                if (currentSize != previousSize)
                {
                    previousSize = currentSize;
                    send(ownerTid, ResizeEvent(currentSize));
                }
            }
        }

        private void startPollingInput()
        {
            // begin polling
            spawn(&pollInputEvent);
        }

        private static void pollInputEvent()
        {
            Thread.getThis.isDaemon = true;

            while (true)
            {
                pollfd ufds;
                ufds.fd = STDOUT_FILENO;
                ufds.events = POLLIN;

                uint input;
                auto bytesRead = poll(&ufds, 1, -1);

                if (bytesRead == -1)
                {
                    // error
                }
                else if (bytesRead == 0)
                {
                    // no key was pressed within `timeout`. this is normal
                }
                else if (ufds.revents & POLLIN)
                {
                    // Read input from keyboard
                    read(STDOUT_FILENO, &input, 1);

                    // Send key code to main thread (where it will be handled).
                    send(ownerTid, input);
                }
            }
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

        // unsure when to use this.
        // om mac this shows a small key icon, used when entering passwords
        private void setInputEcho(in bool echo)
        {
            termios termInfo;
            tcgetattr(STDOUT_FILENO, &termInfo);

            if (echo)
            {
                termInfo.c_lflag |= ECHO;
            }
            else
            {
                termInfo.c_lflag &= ~ECHO;
            }

            tcsetattr(STDOUT_FILENO, TCSADRAIN, &termInfo);
        }

        private void setInputMapping()
        {
            Locale locale = new Locale();
            this.inputMap = new InputMap(locale.systemLocaleSequences);
        }

        private void enableRawInput()
        {
            // store the state of the terminal
            tcgetattr(1, &originalTerminalState);

            // enable raw input
            termios newTerminalState = originalTerminalState;
            cfmakeraw(&newTerminalState);
            tcsetattr(STDOUT_FILENO, TCSADRAIN, &newTerminalState);
        }

        private void resetTerminalState()
        {
            tcsetattr(STDOUT_FILENO, TCSADRAIN, &originalTerminalState);
        }

        private InputMap inputMap;
        private termios originalTerminalState;
    }
}
