module scone.input.os.posix.input.posix_input;

version (Posix)
{
    import core.sys.posix.termios;
    import core.sys.posix.unistd : STDOUT_FILENO;
    import scone.input.keyboard_event : KeyboardEvent;
    import scone.input.scone_control_key : SCK;
    import scone.input.scone_key : SK;
    import scone.input.os.standard_input : StandardInput;
    import scone.input.os.posix.background_thread;
    import scone.input.os.posix.keypress_tree : Keypress;
    import scone.input.os.posix.locale.input_map : InputMap;
    import scone.input.os.posix.locale.locale : Locale;
    import scone.output.os.posix.output.foos : Foos, PartialRowOutput;
    import std.concurrency : spawn, Tid, thisTid, send, receiveTimeout, ownerTid;
    import std.conv : text;
    import std.datetime : msecs;

    extern (C)
    {
        void cfmakeraw(termios* termios_p);
    }

    class PosixInput : StandardInput
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

        KeyboardEvent[] latestKeyboardEvents()
        {
            auto sequence = this.retreiveInputSequence();

            //todo: returns null here. should this logic be here or in `inputMap.keyboardEventsFromSequence(sequence)` instead?
            if (sequence.length == 0)
            {
                return null;
            }

            // conversion to input events. refactor whole (winodws+posix) code to use keypresses instead of input events?
            KeyboardEvent[] keyboardEvents = [];
            foreach (Keypress keypress; inputMap.keyboardEventsFromSequence(sequence))
            {
                keyboardEvents ~= KeyboardEvent(keypress.key, keypress.controlKey, true);
            }

            return keyboardEvents;
        }

        private void startPollingInput()
        {
            // begin polling
            spawn(&pollKeyboardEvent);
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
