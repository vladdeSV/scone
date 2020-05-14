module scone.os.posix.input.posix_input;

version (Posix)
{
    import core.sys.posix.termios;
    import core.sys.posix.unistd : STDOUT_FILENO;
    import scone.core.types.buffer : Buffer;
    import scone.core.types.cell : Cell;
    import scone.core.types.color;
    import scone.core.types.coordinate : Coordinate;
    import scone.core.types.size : Size;
    import scone.input.input_event : InputEvent;
    import scone.input.scone_control_key : SCK;
    import scone.input.scone_key : SK;
    import scone.os.input : Input;
    import scone.os.posix.input.background_thread;
    import scone.os.posix.input.locale.input_map : InputMap;
    import scone.os.posix.input.locale.locale : Locale;
    import scone.os.posix.output.foos : Foos, PartialRowOutput;
    import std.concurrency : spawn, Tid, thisTid, send, receiveTimeout, ownerTid;
    import std.conv : text;
    import std.datetime : msecs;

    extern (C)
    {
        void cfmakeraw(termios* termios_p);
    }

    class PosixInput : Input
    {
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

        uint[] retreiveInputSequence()
        {
            uint[] sequence;

            while (receiveTimeout(5.msecs, (uint code) { sequence ~= code; }))
            {
                // continiously repeat until no code is recieved within 5 milliseconds
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

        private void startPollingInput()
        {
            // begin polling
            spawn(&pollInputEvent);
        }

        // unsure when to use this.
        // on mac this shows a small key icon, used when entering passwords
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
