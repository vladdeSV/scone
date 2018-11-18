module scone.input.input_event;

import scone.input.keys;
import scone.misc.utility : hasFlag;

/**
Key event structure
Contains general information about a key press
*/
struct InputEvent
{
    /**
     * Initialize an InputEvent
     */
    this(SK key, SCK controlKey, bool pressed)
    {
        _key = key;
        _controlKey = controlKey;
        _pressed = pressed;
    }

    /**
     * Get the key
     * Returns: SK (enum) of the key being pressed
     */
    auto key() @property
    {
        return _key;
    }

    /**
     * Check if the button is pressed or released.
     * Returns: bool, true if pressed, false if not
     */
    auto pressed() @property
    {
        return _pressed;
    }

    /**
     * Check if the InputEvent has a "control key" pressed
     * Returns: bool, true if all control keys entered are pressed
     *
     * Example:
     * --------------------
     * foreach(input; getInputs())
     * {
     *     if(input.hasControlKey(ControlKey.CTRL | ControlKey.ALT |
     *        ControlKey.SHIFT))
     *     {
     *         // do something if CTRL, ALT and SHIFT are held down...
     *     }
     * }
     * --------------------
     */
    auto hasControlKey(SCK ck)
    {
        return hasFlag(controlKey, ck);
    }

    /**
     * Get control all keys. Used to check if ONLY specific control keys are
     * activated
     * Returns: SCK (enum)
     * Example:
     * ---
     * foreach(input; getInputs())
     * {
     *     if(input.controlKey == ControlKey.CTRL | ControlKey.SHIFT)
     *     {
     *         // do something if only CTRL and SHIFT are held down...
     *     }
     * }
     * ---
     */
    auto controlKey() @property
    {
        return _controlKey;
    }

    private SK _key;
    private SCK _controlKey;
    private bool _pressed;

    version(Posix)
    {
        /**
         * Get the ASCII-code sequence returned from the keypress on POSIX
         * systems
         * Returns: uint[]
         */
        auto keySequences() @property
        {
            return _keySequences;
        }

        package(scone) uint[] _keySequences;
    }

    version(Windows)
    {
        import core.sys.windows.wincon : INPUT_RECORD;

        /**
         * Get the Windows input record representing the keypress
         * Returns: INPUT_RECORD
         */
        auto inputRecord() @property
        {
            return _inputRecord;
        }

        package(scone) INPUT_RECORD _inputRecord;
    }
}

/// when on posix, a list of keypresses is loaded and used
version(Posix)
{
    import std.array : split;
    import std.conv : to, parse;
    import std.file : exists, readText;
    import std.string : chomp;

    /**
     * Wrapper for an input sequence sent by the POSIX terminal.
     *
     * An input from the terminal is given by numbers in a sequence.
     *
     * For example, the right arrow key might send the sequence "27 91 67",
     * and will be stored as [27, 91, 67]
     */
    struct InputSequence
    {
        this(uint[] t)
        {
            value = t;
        }

        uint[] value;
        alias value this;
    }

    /// Globally map a sequence to an input event
    void createInputSequence(InputEvent ie, InputSequence iseq)
    {
        _inputEvents[iseq] = ie;
    }

    /// Load and use the file 'input_sequences.scone' as default keymap
    void loadInputSequneces()
    {
        enum file_name = "input_sequences.scone";

        string[] ies = _inputSequencesList.split('\n');

        // If file `input_sequence.scone` exists, load keymap, which overrides
        // existing keybinds.
        if(exists(file_name))
        {
            ies ~= file_name.readText.split('\n');
        }

        // Loop all input sequences, and store them
        foreach(s; ies)
        {
            s = s.chomp;
            // if line is empty or begins with #
            if(s == "" || s[0] == '#')
            {
                // log(debug, "input sequence of incorrect. exprected 3 arguments, got ", arguments.length);
                continue;
            }

            string[] arguments = split(s, '\t');
            if(arguments.length != 3)
            {
                // log(warning, "input sequence of incorrect. exprected 3 arguments, got %i", arguments.length);
                continue;
            }

            auto key = parse!(SK)(arguments[0]);
            auto sck = parse!(SCK)(arguments[1]);
            auto seq = arguments[2];
            // if sequence is not defined, skip
            if(seq == "-")
            {
                // log(notice, "ignoring sequence ", key);
                continue;
            }

            auto ie = InputEvent(key, sck, true);
            auto iseq = InputSequence(sequenceFromString(seq));
            ie._keySequences = iseq;

            if((iseq in _inputEvents) !is null)
            {
                auto storedInputEvent = _inputEvents[iseq];

                if(ie.key != storedInputEvent.key || ie.controlKey != storedInputEvent.controlKey)
                {
                    // log(notice, "Replacing ", storedInputEvent, " with ", ie);
                }
            }

            _inputEvents[iseq] = ie;
        }
    }

    /// Get InputEvent from sequence
    /+ todo: remove the comment signs | package(scone)+/ InputEvent eventFromSequence(InputSequence sequence)
    {
        // check for input sequence in map
        if((sequence in _inputEvents) !is null)
        {
            return _inputEvents[sequence];
        }

        // if not found, return unknown input
        auto unknownInputEvent = InputEvent(SK.unknown, SCK.none, false);
        unknownInputEvent._keySequences = sequence;
        return unknownInputEvent;
    }

    /// TODO: this should check for multiple keypresses, according to Github issue #13
    /+ todo: remove the comment signs |package(scone)+/ InputEvent[] eventsFromSequence(uint[] sequence)
    {
        // todo: here should code go to check if an input exists. this fix is of version type PATCH
        auto inputEvents = [eventFromSequence(InputSequence(sequence))];

        return inputEvents;
    }

    /// Get uint[], from string in the format of "num1,num2,...,numX"
    private uint[] sequenceFromString(string input) pure
    {
        string[] numbers = split(input, ",");
        uint[] sequence;
        foreach(number_as_string; numbers)
        {
            sequence ~= parse!uint(number_as_string);
        }

        return sequence;
    }

    /// Table holding all input sequences and their respective input
    private InputEvent[InputSequence] _inputEvents;

    /// Default keybindings.
    version(OSX)
    {
        import scone.input.keybinds.mac;
        alias _inputSequencesList = macInputSequences;
    }
    else version(Posix)
    {
        import scone.input.keybinds.posix;
        alias _inputSequencesList = posixInputSequences;
    }
}
