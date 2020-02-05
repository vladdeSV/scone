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

    class PosixTerminal : Window
    {
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

        void clear()
        {
            writef("\033[2J");
            stdout.flush();
        }

        void title(in string title)
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

        void initializeOutput()
        {
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
            tcsetattr(STDOUT_FILENO, TCSADRAIN, &originalTerminalState);
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

        // unsure when to use this.
        private void setInputEcho(in bool echo)
        {
            termios termInfo;
            tcgetattr(STDOUT_FILENO, &termInfo);

            if(echo)
            {
                termInfo.c_lflag |= ECHO;
            }
            else
            {
                termInfo.c_lflag &= ~ECHO;
            }

            tcsetattr(STDOUT_FILENO, TCSADRAIN, &termInfo);
        }

        private void startPollingInput()
        {
            // begin polling
            spawn(&pollInputEvent);
        }

        InputEvent[] latestInputEvents()
        {
            auto sequence = this.retreiveInputSequence();

            //todo: returns null here. should this logic be here or in `inputMap.inputEventsFromSequence(sequence)` instead?
            if(sequence.length == 0)
            {
                return null;
            }

            return inputMap.inputEventsFromSequence(sequence);
        }

        uint[] retreiveInputSequence()
        {
            uint[] sequence;

            while (receiveTimeout(5.msecs, (uint code) { sequence ~= code; }))
            {
            }

            return sequence;
        }

        static void pollInputEvent()
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
                    // error :(
                    // logf("(POSIX) ERROR: polling input returned -1");
                }
                else if (bytesRead == 0)
                {
                    // If no key was pressed within `timeout`
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

        private InputMap inputMap;
        private termios originalTerminalState;
    }
}
