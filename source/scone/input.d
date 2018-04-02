module scone.input;

import scone.misc.utility : hasFlag;
import scone.os;

/**
 * Key event structure
 * Contains general information about a key press
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
     *         //do something if CTRL, ALT and SHIFT are held down...
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
     *         //do something if only CTRL and SHIFT are held down...
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

///All keys which scone can handle
///Note: Limited support for POSIX
enum SK
{
    ///Unknown key (Should never appear. If it does, please report bug)
    unknown,

    ///Control-break processing
    cancel,

    ///BACKSPACE key
    backspace,

    ///DEL key
    del,

    ///TAB key
    tab,

    ///ENTER key
    enter,

    ///ESC key
    escape,

    ///SPACEBAR
    space,

    ///PAGE UP key
    page_up,

    ///PAGE DOWN key
    page_down,

    ///END key
    end,

    ///HOME key
    home,

    ///LEFT ARROW key
    left,

    ///UP ARROW key
    up,

    ///RIGHT ARROW key
    right,

    ///DOWN ARROW key
    down,

    ///0 key
    key_0,

    ///1 key
    key_1,

    ///2 key
    key_2,

    ///3 key
    key_3,

    ///4 key
    key_4,

    ///5 key
    key_5,

    ///6 key
    key_6,

    ///7 key
    key_7,

    ///8 key
    key_8,

    ///9 key
    key_9,

    ///A key
    a,

    ///B key
    b,

    ///C key
    c,

    ///D key
    d,

    ///E key
    e,

    ///F key
    f,

    ///G key
    g,

    ///H key
    h,

    ///I key
    i,

    ///J key
    j,

    ///K key
    k,

    ///L key
    l,

    ///M key
    m,

    ///N key
    n,

    ///O key
    o,

    ///P key
    p,

    ///Q key
    q,

    ///R key
    r,

    ///S key
    s,

    ///T key
    t,

    ///U key
    u,

    ///V key
    v,

    ///W key
    w,

    ///X key
    x,

    ///Y key
    y,

    ///Z key
    z,

    ///Numeric keypad 0 key
    numpad_0,

    ///Numeric keypad 1 key
    numpad_1,

    ///Numeric keypad 2 key
    numpad_2,

    ///Numeric keypad 3 key
    numpad_3,

    ///Numeric keypad 4 key
    numpad_4,

    ///Numeric keypad 5 key
    numpad_5,

    ///Numeric keypad 6 key
    numpad_6,

    ///Numeric keypad 7 key
    numpad_7,

    ///Numeric keypad 8 key
    numpad_8,

    ///Numeric keypad 9 key
    numpad_9,

    ///For any country/region, the '+' key
    plus,

    ///For any country/region, the '-' key
    minus,

    ///For any country/region, the '.' key
    period,

    ///For any country/region, the ',' key
    comma,

    ///Asterisk key
    asterisk,

    ///Divide key
    divide,

    ///F1 key
    f1,

    ///F2 key
    f2,

    ///F3 key
    f3,

    ///F4 key
    f4,

    ///F5 key
    f5,

    ///F6 key
    f6,

    ///F7 key
    f7,

    ///F8 key
    f8,

    ///F9 key
    f9,

    ///F10 key
    f10,

    ///F11 key
    f11,

    ///F12 key
    f12,

    ///F13 key
    f13,

    ///F14 key
    f14,

    ///F15 key
    f15,

    ///F16 key
    f16,

    ///F17 key
    f17,

    ///F18 key
    f18,

    ///F19 key
    f19,

    ///F20 key
    f20,

    ///F21 key
    f21,

    ///F22 key
    f22,

    ///F23 key
    f23,

    ///F24 key
    f24,

    ///Used for miscellaneous characters; it can vary by keyboard.
    oem_1,

    ///ditto
    oem_2,

    ///ditto
    oem_3,

    ///ditto
    oem_4,

    ///ditto
    oem_5,

    ///ditto
    oem_6,

    ///ditto
    oem_7,

    ///ditto
    oem_8,

    ///Either the angle bracket key or the backslash key on the RT 102-key keyboard
    oem_102,
}

/**
 * Control keys
 */
enum SCK
{
    ///No control key is being pressed
    none = 0,

    ///CAPS LOCK light is activated
    capslock = 1,

    ///NUM LOCK is activated
    numlock = 2,

    ///SCROLL LOCK is activated
    scrolllock = 4,

    ///SHIFT key is pressed
    shift = 8,

    ///The key is enhanced (?)
    enhanced = 16,

    ///Left or right ALT key is pressed
    alt = 32,

    ///Left or right CTRL key is pressed
    ctrl = 64,
}

///when on posix, a list of keypresses is loaded and used
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
        _inputSequences[iseq] = ie;
    }

    /// Load and use the file 'input_sequences.scone' as default keymap
    void loadInputSequneces()
    {
        enum file_name = "input_sequences.scone";

        string[] ies = _inputSequencesList.split('\n');

        // If file `input_sequence` exists, load keymap, which overrides
        // existing keybinds.
        if(exists(file_name))
        {
            ies ~= file_name.readText.split('\n');
        }

        // Loop all input sequences, and store them
        foreach(s; ies)
        {
            s = s.chomp;
            //if line begins with #
            if(s == "" || s[0] == '#') continue;

            string[] arguments = split(s, '\t');
            if(arguments.length != 3) continue; //something isn't right

            auto key = parse!(SK)(arguments[0]);
            auto sck = parse!(SCK)(arguments[1]);
            auto seq = arguments[2];
            //if sequence is not defined, skip
            if(seq == "-") continue;

            auto ie = InputEvent(key, sck, true);
            auto iseq = InputSequence(sequenceFromString(seq));

            if((iseq in _inputSequences) !is null)
            {
                auto storedInputEvent = _inputSequences[iseq];

                if(ie.key != storedInputEvent.key || ie.controlKey != storedInputEvent.controlKey)
                {
                    //log(text("Replacing ", storedInputEvent, " with ", ie));
                }
            }

            _inputSequences[iseq] = ie;
        }
    }

    /// Get InputEvent from sequence
    package(scone) InputEvent eventFromSequence(InputSequence iseq)
    {
        //check for input sequence in map
        if((iseq in _inputSequences) !is null)
        {
            return _inputSequences[iseq];
        }

        //if not found, return unknown input
        return InputEvent(SK.unknown, SCK.none, false);
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
    private InputEvent[InputSequence] _inputSequences;
}

///Default keybindings.
version(OSX)
{
    private enum _inputSequencesList =
    "# tested on macOS Sierra v10.12.5, MacBook Pro (15-inch, Mid 2012)" ~ "\n" ~
    "a	none	97" ~ "\n" ~
    "b	none	98" ~ "\n" ~
    "c	none	99" ~ "\n" ~
    "d	none	100" ~ "\n" ~
    "e	none	101" ~ "\n" ~
    "f	none	102" ~ "\n" ~
    "g	none	103" ~ "\n" ~
    "h	none	104" ~ "\n" ~
    "i	none	105" ~ "\n" ~
    "j	none	106" ~ "\n" ~
    "k	none	107" ~ "\n" ~
    "l	none	108" ~ "\n" ~
    "m	none	109" ~ "\n" ~
    "n	none	110" ~ "\n" ~
    "o	none	111" ~ "\n" ~
    "p	none	112" ~ "\n" ~
    "q	none	113" ~ "\n" ~
    "r	none	114" ~ "\n" ~
    "s	none	115" ~ "\n" ~
    "t	none	116" ~ "\n" ~
    "u	none	117" ~ "\n" ~
    "v	none	118" ~ "\n" ~
    "w	none	119" ~ "\n" ~
    "x	none	120" ~ "\n" ~
    "y	none	121" ~ "\n" ~
    "z	none	122" ~ "\n" ~
    "tab	none	9" ~ "\n" ~
    "page_up	none	-" ~ "\n" ~
    "page_down	none	-" ~ "\n" ~
    "end	none	-" ~ "\n" ~
    "home	none	-" ~ "\n" ~
    "left	none	27,91,68" ~ "\n" ~
    "up	none	27,91,65" ~ "\n" ~
    "right	none	27,91,67" ~ "\n" ~
    "down	none	27,91,66" ~ "\n" ~
    "key_0	none	48" ~ "\n" ~
    "key_1	none	49" ~ "\n" ~
    "key_2	none	50" ~ "\n" ~
    "key_3	none	51" ~ "\n" ~
    "key_4	none	52" ~ "\n" ~
    "key_5	none	53" ~ "\n" ~
    "key_6	none	54" ~ "\n" ~
    "key_7	none	55" ~ "\n" ~
    "key_8	none	56" ~ "\n" ~
    "key_9	none	57" ~ "\n" ~
    "numpad_0	none	-" ~ "\n" ~
    "numpad_1	none	-" ~ "\n" ~
    "numpad_2	none	-" ~ "\n" ~
    "numpad_3	none	-" ~ "\n" ~
    "numpad_4	none	-" ~ "\n" ~
    "numpad_5	none	-" ~ "\n" ~
    "numpad_6	none	-" ~ "\n" ~
    "numpad_7	none	-" ~ "\n" ~
    "numpad_8	none	-" ~ "\n" ~
    "numpad_9	none	-" ~ "\n" ~
    "plus	none	43" ~ "\n" ~
    "minus	none	45" ~ "\n" ~
    "period	none	46" ~ "\n" ~
    "comma	none	44" ~ "\n" ~
    "asterisk	none	42" ~ "\n" ~
    "divide	none	47" ~ "\n" ~
    "f1	none	27,79,80" ~ "\n" ~
    "f2	none	27,79,81" ~ "\n" ~
    "f3	none	27,79,82" ~ "\n" ~
    "f4	none	27,79,83" ~ "\n" ~
    "f5	none	27,91,49,53,126" ~ "\n" ~
    "f6	none	27,91,49,55,126" ~ "\n" ~
    "f7	none	27,91,49,56,126" ~ "\n" ~
    "f8	none	27,91,49,57,126" ~ "\n" ~
    "f9	none	27,91,50,48,126" ~ "\n" ~
    "f10	none	27,91,50,49,126" ~ "\n" ~
    "f11	none	27,91,50,51,126" ~ "\n" ~
    "f12	none	27,91,50,52,126" ~ "\n" ~
    "f13	none	-" ~ "\n" ~
    "f14	none	-" ~ "\n" ~
    "f15	none	-" ~ "\n" ~
    "f16	none	-" ~ "\n" ~
    "f17	none	-" ~ "\n" ~
    "f18	none	-" ~ "\n" ~
    "f19	none	-" ~ "\n" ~
    "f20	none	-" ~ "\n" ~
    "f21	none	-" ~ "\n" ~
    "f22	none	-" ~ "\n" ~
    "f23	none	-" ~ "\n" ~
    "f24	none	-" ~ "\n" ~
    "oem_1	none	195,165" ~ "\n" ~
    "oem_2	none	-" ~ "\n" ~
    "oem_3	none	-" ~ "\n" ~
    "oem_4	none	-" ~ "\n" ~
    "oem_5	none	-" ~ "\n" ~
    "oem_6	none	-" ~ "\n" ~
    "oem_7	none	-" ~ "\n" ~
    "oem_8	none	-" ~ "\n" ~
    "oem_102	none	-" ~ "\n" ~
    "a	shift	65" ~ "\n" ~
    "b	shift	66" ~ "\n" ~
    "c	shift	67" ~ "\n" ~
    "d	shift	68" ~ "\n" ~
    "e	shift	69" ~ "\n" ~
    "f	shift	70" ~ "\n" ~
    "g	shift	71" ~ "\n" ~
    "h	shift	72" ~ "\n" ~
    "i	shift	73" ~ "\n" ~
    "j	shift	74" ~ "\n" ~
    "k	shift	75" ~ "\n" ~
    "l	shift	76" ~ "\n" ~
    "m	shift	77" ~ "\n" ~
    "n	shift	78" ~ "\n" ~
    "o	shift	79" ~ "\n" ~
    "p	shift	80" ~ "\n" ~
    "q	shift	81" ~ "\n" ~
    "r	shift	82" ~ "\n" ~
    "s	shift	83" ~ "\n" ~
    "t	shift	84" ~ "\n" ~
    "u	shift	85" ~ "\n" ~
    "v	shift	86" ~ "\n" ~
    "w	shift	87" ~ "\n" ~
    "x	shift	88" ~ "\n" ~
    "y	shift	89" ~ "\n" ~
    "z	shift	90" ~ "\n" ~
    "tab	shift	27,91,90" ~ "\n" ~
    "page_up	shift	27,91,53,126" ~ "\n" ~
    "page_down	shift	27,91,54,126" ~ "\n" ~
    "end	shift	27,91,70" ~ "\n" ~
    "home	shift	27,91,72" ~ "\n" ~
    "left	shift	27,91,49,59,50,68" ~ "\n" ~
    "up	shift	-" ~ "\n" ~
    "right	shift	27,91,49,59,50,67" ~ "\n" ~
    "down	shift	-" ~ "\n" ~
    "key_0	shift	61" ~ "\n" ~
    "key_1	shift	33" ~ "\n" ~
    "key_2	shift	34" ~ "\n" ~
    "key_3	shift	35" ~ "\n" ~
    "key_4	shift	36" ~ "\n" ~
    "key_4	shift	226,130,172" ~ "\n" ~
    "key_5	shift	37" ~ "\n" ~
    "key_6	shift	38" ~ "\n" ~
    "key_7	shift	47" ~ "\n" ~
    "key_8	shift	40" ~ "\n" ~
    "key_9	shift	41" ~ "\n" ~
    "numpad_0	shift	-" ~ "\n" ~
    "numpad_1	shift	-" ~ "\n" ~
    "numpad_2	shift	-" ~ "\n" ~
    "numpad_3	shift	-" ~ "\n" ~
    "numpad_4	shift	-" ~ "\n" ~
    "numpad_5	shift	-" ~ "\n" ~
    "numpad_6	shift	-" ~ "\n" ~
    "numpad_7	shift	-" ~ "\n" ~
    "numpad_8	shift	-" ~ "\n" ~
    "numpad_9	shift	-" ~ "\n" ~
    "plus	shift	-" ~ "\n" ~
    "minus	shift	-" ~ "\n" ~
    "period	shift	58" ~ "\n" ~
    "comma	shift	59" ~ "\n" ~
    "asterisk	shift	-" ~ "\n" ~
    "divide	shift	-" ~ "\n" ~
    "f1	shift	-" ~ "\n" ~
    "f2	shift	-" ~ "\n" ~
    "f3	shift	-" ~ "\n" ~
    "f4	shift	-" ~ "\n" ~
    "f5	shift	-" ~ "\n" ~
    "f6	shift	-" ~ "\n" ~
    "f7	shift	-" ~ "\n" ~
    "f8	shift	-" ~ "\n" ~
    "f9	shift	-" ~ "\n" ~
    "f10	shift	-" ~ "\n" ~
    "f11	shift	-" ~ "\n" ~
    "f12	shift	27,91,51,52,126" ~ "\n" ~
    "f13	shift	-" ~ "\n" ~
    "f14	shift	-" ~ "\n" ~
    "f15	shift	-" ~ "\n" ~
    "f16	shift	-" ~ "\n" ~
    "f17	shift	-" ~ "\n" ~
    "f18	shift	-" ~ "\n" ~
    "f19	shift	-" ~ "\n" ~
    "f20	shift	-" ~ "\n" ~
    "f21	shift	-" ~ "\n" ~
    "f22	shift	-" ~ "\n" ~
    "f23	shift	-" ~ "\n" ~
    "f24	shift	-" ~ "\n" ~
    "oem_1	shift	-" ~ "\n" ~
    "oem_2	shift	-" ~ "\n" ~
    "oem_3	shift	-" ~ "\n" ~
    "oem_4	shift	-" ~ "\n" ~
    "oem_5	shift	-" ~ "\n" ~
    "oem_6	shift	-" ~ "\n" ~
    "oem_7	shift	-" ~ "\n" ~
    "oem_8	shift	-" ~ "\n" ~
    "oem_102	shift	-" ~ "\n" ~
    "a	ctrl	1" ~ "\n" ~
    "b	ctrl	2" ~ "\n" ~
    "c	ctrl	3" ~ "\n" ~
    "d	ctrl	4" ~ "\n" ~
    "e	ctrl	5" ~ "\n" ~
    "f	ctrl	6" ~ "\n" ~
    "g	ctrl	7" ~ "\n" ~
    "h	ctrl	8" ~ "\n" ~
    "i	ctrl	9" ~ "\n" ~
    "j	ctrl	10" ~ "\n" ~
    "k	ctrl	11" ~ "\n" ~
    "l	ctrl	12" ~ "\n" ~
    "m	ctrl	-" ~ "\n" ~
    "n	ctrl	14" ~ "\n" ~
    "o	ctrl	15" ~ "\n" ~
    "p	ctrl	16" ~ "\n" ~
    "q	ctrl	17" ~ "\n" ~
    "r	ctrl	18" ~ "\n" ~
    "s	ctrl	19" ~ "\n" ~
    "t	ctrl	20" ~ "\n" ~
    "u	ctrl	21" ~ "\n" ~
    "v	ctrl	22" ~ "\n" ~
    "w	ctrl	23" ~ "\n" ~
    "x	ctrl	24" ~ "\n" ~
    "y	ctrl	25" ~ "\n" ~
    "z	ctrl	26" ~ "\n" ~
    "tab	ctrl	-" ~ "\n" ~
    "page_up	ctrl	-" ~ "\n" ~
    "page_down	ctrl	-" ~ "\n" ~
    "end	ctrl	-" ~ "\n" ~
    "home	ctrl	-" ~ "\n" ~
    "left	ctrl	-" ~ "\n" ~
    "up	ctrl	-" ~ "\n" ~
    "right	ctrl	-" ~ "\n" ~
    "down	ctrl	-" ~ "\n" ~
    "key_0	ctrl	-" ~ "\n" ~
    "key_1	ctrl	-" ~ "\n" ~
    "key_2	ctrl	-" ~ "\n" ~
    "key_3	ctrl	-" ~ "\n" ~
    "key_4	ctrl	-" ~ "\n" ~
    "key_5	ctrl	-" ~ "\n" ~
    "key_6	ctrl	-" ~ "\n" ~
    "key_7	ctrl	-" ~ "\n" ~
    "key_8	ctrl	-" ~ "\n" ~
    "key_9	ctrl	-" ~ "\n" ~
    "numpad_0	ctrl	-" ~ "\n" ~
    "numpad_1	ctrl	-" ~ "\n" ~
    "numpad_2	ctrl	-" ~ "\n" ~
    "numpad_3	ctrl	-" ~ "\n" ~
    "numpad_4	ctrl	-" ~ "\n" ~
    "numpad_5	ctrl	-" ~ "\n" ~
    "numpad_6	ctrl	-" ~ "\n" ~
    "numpad_7	ctrl	-" ~ "\n" ~
    "numpad_8	ctrl	-" ~ "\n" ~
    "numpad_9	ctrl	-" ~ "\n" ~
    "plus	ctrl	-" ~ "\n" ~
    "minus	ctrl	-" ~ "\n" ~
    "period	ctrl	-" ~ "\n" ~
    "comma	ctrl	-" ~ "\n" ~
    "asterisk	ctrl	-" ~ "\n" ~
    "divide	ctrl	-" ~ "\n" ~
    "f1	ctrl	-" ~ "\n" ~
    "f2	ctrl	-" ~ "\n" ~
    "f3	ctrl	-" ~ "\n" ~
    "f4	ctrl	-" ~ "\n" ~
    "f5	ctrl	-" ~ "\n" ~
    "f6	ctrl	-" ~ "\n" ~
    "f7	ctrl	-" ~ "\n" ~
    "f8	ctrl	-" ~ "\n" ~
    "f9	ctrl	-" ~ "\n" ~
    "f10	ctrl	-" ~ "\n" ~
    "f11	ctrl	-" ~ "\n" ~
    "f12	ctrl	-" ~ "\n" ~
    "f13	ctrl	-" ~ "\n" ~
    "f14	ctrl	-" ~ "\n" ~
    "f15	ctrl	-" ~ "\n" ~
    "f16	ctrl	-" ~ "\n" ~
    "f17	ctrl	-" ~ "\n" ~
    "f18	ctrl	-" ~ "\n" ~
    "f19	ctrl	-" ~ "\n" ~
    "f20	ctrl	-" ~ "\n" ~
    "f21	ctrl	-" ~ "\n" ~
    "f22	ctrl	-" ~ "\n" ~
    "f23	ctrl	-" ~ "\n" ~
    "f24	ctrl	-" ~ "\n" ~
    "oem_1	ctrl	-" ~ "\n" ~
    "oem_2	ctrl	-" ~ "\n" ~
    "oem_3	ctrl	-" ~ "\n" ~
    "oem_4	ctrl	-" ~ "\n" ~
    "oem_5	ctrl	-" ~ "\n" ~
    "oem_6	ctrl	-" ~ "\n" ~
    "oem_7	ctrl	-" ~ "\n" ~
    "oem_8	ctrl	-" ~ "\n" ~
    "oem_102	ctrl	-" ~ "\n" ~
    "a	alt	239,163,191" ~ "\n" ~
    "b	alt	226,128,186" ~ "\n" ~
    "c	alt	195,167" ~ "\n" ~
    "d	alt	226,136,130" ~ "\n" ~
    "e	alt	195,169" ~ "\n" ~
    "f	alt	198,146" ~ "\n" ~
    "g	alt	194,184" ~ "\n" ~
    "h	alt	203,155" ~ "\n" ~
    "i	alt	196,177" ~ "\n" ~
    "j	alt	226,136,154" ~ "\n" ~
    "k	alt	194,170" ~ "\n" ~
    "l	alt	239,172,129" ~ "\n" ~
    "m	alt	226,128,153" ~ "\n" ~
    "n	alt	226,128,152" ~ "\n" ~
    "o	alt	197,147" ~ "\n" ~
    "p	alt	207,128" ~ "\n" ~
    "q	alt	226,128,162" ~ "\n" ~
    "r	alt	194,174" ~ "\n" ~
    "s	alt	195,159" ~ "\n" ~
    "t	alt	226,128,160" ~ "\n" ~
    "u	alt	195,188" ~ "\n" ~
    "v	alt	226,128,185" ~ "\n" ~
    "w	alt	206,169" ~ "\n" ~
    "x	alt	226,137,136" ~ "\n" ~
    "y	alt	194,181" ~ "\n" ~
    "z	alt	195,183" ~ "\n" ~
    "tab	alt	-" ~ "\n" ~
    "page_up	alt	-" ~ "\n" ~
    "page_down	alt	-" ~ "\n" ~
    "end	alt	-" ~ "\n" ~
    "home	alt	-" ~ "\n" ~
    "left	alt	27,98" ~ "\n" ~
    "up	alt	-" ~ "\n" ~
    "right	alt	27,102" ~ "\n" ~
    "down	alt	-" ~ "\n" ~
    "key_0	alt	226,137,136" ~ "\n" ~
    "key_1	alt	194,169" ~ "\n" ~
    "key_2	alt	64" ~ "\n" ~
    "key_3	alt	194,163" ~ "\n" ~
    "key_4	alt	36" ~ "\n" ~
    "key_5	alt	226,136,158" ~ "\n" ~
    "key_6	alt	194,167" ~ "\n" ~
    "key_7	alt	124" ~ "\n" ~
    "key_8	alt	91" ~ "\n" ~
    "key_9	alt	93" ~ "\n" ~
    "numpad_0	alt	-" ~ "\n" ~
    "numpad_1	alt	-" ~ "\n" ~
    "numpad_2	alt	-" ~ "\n" ~
    "numpad_3	alt	-" ~ "\n" ~
    "numpad_4	alt	-" ~ "\n" ~
    "numpad_5	alt	-" ~ "\n" ~
    "numpad_6	alt	-" ~ "\n" ~
    "numpad_7	alt	-" ~ "\n" ~
    "numpad_8	alt	-" ~ "\n" ~
    "numpad_9	alt	-" ~ "\n" ~
    "plus	alt	-" ~ "\n" ~
    "minus	alt	-" ~ "\n" ~
    "period	alt	226,128,166" ~ "\n" ~
    "comma	alt	226,128,154" ~ "\n" ~
    "asterisk	alt	-" ~ "\n" ~
    "divide	alt	-" ~ "\n" ~
    "f1	alt	27,91,49,55,126" ~ "\n" ~
    "f2	alt	27,91,49,56,126" ~ "\n" ~
    "f3	alt	27,91,49,57,126" ~ "\n" ~
    "f4	alt	27,91,50,48,126" ~ "\n" ~
    "f5	alt	27,91,50,49,126" ~ "\n" ~
    "f6	alt	27,91,50,51,126" ~ "\n" ~
    "f7	alt	27,91,50,52,126" ~ "\n" ~
    "f8	alt	27,91,50,53,126" ~ "\n" ~
    "f9	alt	27,91,50,54,126" ~ "\n" ~
    "f10	alt	27,91,50,56,126" ~ "\n" ~
    "f11	alt	27,91,50,57,126" ~ "\n" ~
    "f12	alt	27,91,51,49,126" ~ "\n" ~
    "f13	alt	-" ~ "\n" ~
    "f14	alt	-" ~ "\n" ~
    "f15	alt	-" ~ "\n" ~
    "f16	alt	-" ~ "\n" ~
    "f17	alt	-" ~ "\n" ~
    "f18	alt	-" ~ "\n" ~
    "f19	alt	-" ~ "\n" ~
    "f20	alt	-" ~ "\n" ~
    "f21	alt	-" ~ "\n" ~
    "f22	alt	-" ~ "\n" ~
    "f23	alt	-" ~ "\n" ~
    "f24	alt	-" ~ "\n" ~
    "oem_1	alt	203,153" ~ "\n" ~
    "oem_2	alt	-" ~ "\n" ~
    "oem_3	alt	-" ~ "\n" ~
    "oem_4	alt	-" ~ "\n" ~
    "oem_5	alt	-" ~ "\n" ~
    "oem_6	alt	-" ~ "\n" ~
    "oem_7	alt	-" ~ "\n" ~
    "oem_8	alt	-" ~ "\n" ~
    "oem_102	alt	-" ~ "\n" ~
    "escape	none	27" ~ "\n" ~
    "del	none	127" ~ "\n" ~
    "enter	none	13";
}
else version(Posix)
{
    private enum _inputSequencesList =
    "# tested on Ubuntu 16.10 sv_SE" ~ "\n" ~
    "a	none	97" ~ "\n" ~
    "b	none	98" ~ "\n" ~
    "c	none	99" ~ "\n" ~
    "d	none	100" ~ "\n" ~
    "e	none	101" ~ "\n" ~
    "f	none	102" ~ "\n" ~
    "g	none	103" ~ "\n" ~
    "h	none	104" ~ "\n" ~
    "i	none	105" ~ "\n" ~
    "j	none	106" ~ "\n" ~
    "k	none	107" ~ "\n" ~
    "l	none	108" ~ "\n" ~
    "m	none	109" ~ "\n" ~
    "n	none	110" ~ "\n" ~
    "o	none	111" ~ "\n" ~
    "p	none	112" ~ "\n" ~
    "q	none	113" ~ "\n" ~
    "r	none	114" ~ "\n" ~
    "s	none	115" ~ "\n" ~
    "t	none	116" ~ "\n" ~
    "u	none	117" ~ "\n" ~
    "v	none	118" ~ "\n" ~
    "w	none	119" ~ "\n" ~
    "x	none	120" ~ "\n" ~
    "y	none	121" ~ "\n" ~
    "z	none	122" ~ "\n" ~
    "tab	none	9" ~ "\n" ~
    "page_up	none	27,91,53,126" ~ "\n" ~
    "page_down	none	27,91,54,126" ~ "\n" ~
    "end	none	27,91,70" ~ "\n" ~
    "home	none	27,91,72" ~ "\n" ~
    "left	none	27,91,68" ~ "\n" ~
    "up	none	27,91,65" ~ "\n" ~
    "right	none	27,91,67" ~ "\n" ~
    "down	none	27,91,66" ~ "\n" ~
    "key_0	none	48" ~ "\n" ~
    "key_1	none	49" ~ "\n" ~
    "key_2	none	50" ~ "\n" ~
    "key_3	none	51" ~ "\n" ~
    "key_4	none	52" ~ "\n" ~
    "key_5	none	53" ~ "\n" ~
    "key_6	none	54" ~ "\n" ~
    "key_7	none	55" ~ "\n" ~
    "key_8	none	56" ~ "\n" ~
    "key_9	none	57" ~ "\n" ~
    "numpad_0	none	-" ~ "\n" ~
    "numpad_1	none	-" ~ "\n" ~
    "numpad_2	none	-" ~ "\n" ~
    "numpad_3	none	-" ~ "\n" ~
    "numpad_4	none	-" ~ "\n" ~
    "numpad_5	none	-" ~ "\n" ~
    "numpad_6	none	-" ~ "\n" ~
    "numpad_7	none	-" ~ "\n" ~
    "numpad_8	none	-" ~ "\n" ~
    "numpad_9	none	-" ~ "\n" ~
    "plus	none	43" ~ "\n" ~
    "minus	none	45" ~ "\n" ~
    "period	none	46" ~ "\n" ~
    "comma	none	44" ~ "\n" ~
    "asterisk	none	42" ~ "\n" ~
    "divide	none	47" ~ "\n" ~
    "f1	none	-" ~ "\n" ~
    "f2	none	27,79,81" ~ "\n" ~
    "f3	none	27,79,82" ~ "\n" ~
    "f4	none	27,79,83" ~ "\n" ~
    "f5	none	27,91,49,53,126" ~ "\n" ~
    "f6	none	27,91,49,55,126" ~ "\n" ~
    "f7	none	27,91,49,56,126" ~ "\n" ~
    "f8	none	27,91,49,57,126" ~ "\n" ~
    "f9	none	27,91,50,48,126" ~ "\n" ~
    "f10	none	27,91,50,49,126" ~ "\n" ~
    "f11	none	-" ~ "\n" ~
    "f12	none	27,91,50,52,126" ~ "\n" ~
    "f13	none	-" ~ "\n" ~
    "f14	none	-" ~ "\n" ~
    "f15	none	-" ~ "\n" ~
    "f16	none	-" ~ "\n" ~
    "f17	none	-" ~ "\n" ~
    "f18	none	-" ~ "\n" ~
    "f19	none	-" ~ "\n" ~
    "f20	none	-" ~ "\n" ~
    "f21	none	-" ~ "\n" ~
    "f22	none	-" ~ "\n" ~
    "f23	none	-" ~ "\n" ~
    "f24	none	-" ~ "\n" ~
    "oem_1	none	195,165" ~ "\n" ~
    "oem_2	none	195,164" ~ "\n" ~
    "oem_3	none	195,182" ~ "\n" ~
    "oem_4	none	-" ~ "\n" ~
    "oem_5	none	-" ~ "\n" ~
    "oem_6	none	-" ~ "\n" ~
    "oem_7	none	-" ~ "\n" ~
    "oem_8	none	-" ~ "\n" ~
    "oem_102	none	-" ~ "\n" ~
    "a	shift	65" ~ "\n" ~
    "b	shift	66" ~ "\n" ~
    "c	shift	67" ~ "\n" ~
    "d	shift	68" ~ "\n" ~
    "e	shift	69" ~ "\n" ~
    "f	shift	70" ~ "\n" ~
    "g	shift	71" ~ "\n" ~
    "h	shift	72" ~ "\n" ~
    "i	shift	73" ~ "\n" ~
    "j	shift	74" ~ "\n" ~
    "k	shift	75" ~ "\n" ~
    "l	shift	76" ~ "\n" ~
    "m	shift	77" ~ "\n" ~
    "n	shift	78" ~ "\n" ~
    "o	shift	79" ~ "\n" ~
    "p	shift	80" ~ "\n" ~
    "q	shift	81" ~ "\n" ~
    "r	shift	82" ~ "\n" ~
    "s	shift	83" ~ "\n" ~
    "t	shift	84" ~ "\n" ~
    "u	shift	85" ~ "\n" ~
    "v	shift	86" ~ "\n" ~
    "w	shift	87" ~ "\n" ~
    "x	shift	88" ~ "\n" ~
    "y	shift	89" ~ "\n" ~
    "z	shift	90" ~ "\n" ~
    "tab	shift	27,91,90" ~ "\n" ~
    "page_up	shift	-" ~ "\n" ~
    "page_down	shift	-" ~ "\n" ~
    "end	shift	-" ~ "\n" ~
    "home	shift	-" ~ "\n" ~
    "left	shift	27,91,49,59,50,68" ~ "\n" ~
    "up	shift	27,91,49,59,50,65" ~ "\n" ~
    "right	shift	27,91,49,59,50,67" ~ "\n" ~
    "down	shift	27,91,49,59,50,66" ~ "\n" ~
    "key_0	shift	61" ~ "\n" ~
    "key_1	shift	33" ~ "\n" ~
    "key_2	shift	34" ~ "\n" ~
    "key_3	shift	35" ~ "\n" ~
    "key_4	shift	194,164" ~ "\n" ~
    "key_5	shift	37" ~ "\n" ~
    "key_6	shift	38" ~ "\n" ~
    "key_7	shift	47" ~ "\n" ~
    "key_8	shift	40" ~ "\n" ~
    "key_9	shift	41" ~ "\n" ~
    "numpad_0	shift	-" ~ "\n" ~
    "numpad_1	shift	-" ~ "\n" ~
    "numpad_2	shift	-" ~ "\n" ~
    "numpad_3	shift	-" ~ "\n" ~
    "numpad_4	shift	-" ~ "\n" ~
    "numpad_5	shift	-" ~ "\n" ~
    "numpad_6	shift	-" ~ "\n" ~
    "numpad_7	shift	-" ~ "\n" ~
    "numpad_8	shift	-" ~ "\n" ~
    "numpad_9	shift	-" ~ "\n" ~
    "plus	shift	-" ~ "\n" ~
    "minus	shift	-" ~ "\n" ~
    "period	shift	58" ~ "\n" ~
    "comma	shift	59" ~ "\n" ~
    "asterisk	shift	-" ~ "\n" ~
    "divide	shift	-" ~ "\n" ~
    "f1	shift	27,91,49,59,50,80" ~ "\n" ~
    "f2	shift	27,91,49,59,50,81" ~ "\n" ~
    "f3	shift	27,91,49,59,50,82" ~ "\n" ~
    "f4	shift	27,91,49,59,50,83" ~ "\n" ~
    "f5	shift	27,91,49,53,59,50,126" ~ "\n" ~
    "f6	shift	27,91,49,55,59,50,126" ~ "\n" ~
    "f7	shift	27,91,49,56,59,50,126" ~ "\n" ~
    "f8	shift	27,91,49,57,59,50,126" ~ "\n" ~
    "f9	shift	27,91,50,48,59,50,126" ~ "\n" ~
    "f10	shift	-" ~ "\n" ~
    "f11	shift	27,91,50,51,59,50,126" ~ "\n" ~
    "f12	shift	27,91,50,52,59,50,126" ~ "\n" ~
    "f13	shift	-" ~ "\n" ~
    "f14	shift	-" ~ "\n" ~
    "f15	shift	-" ~ "\n" ~
    "f16	shift	-" ~ "\n" ~
    "f17	shift	-" ~ "\n" ~
    "f18	shift	-" ~ "\n" ~
    "f19	shift	-" ~ "\n" ~
    "f20	shift	-" ~ "\n" ~
    "f21	shift	-" ~ "\n" ~
    "f22	shift	-" ~ "\n" ~
    "f23	shift	-" ~ "\n" ~
    "f24	shift	-" ~ "\n" ~
    "oem_1	shift	195,133" ~ "\n" ~
    "oem_2	shift	195,132" ~ "\n" ~
    "oem_3	shift	195,150" ~ "\n" ~
    "oem_4	shift	-" ~ "\n" ~
    "oem_5	shift	-" ~ "\n" ~
    "oem_6	shift	-" ~ "\n" ~
    "oem_7	shift	-" ~ "\n" ~
    "oem_8	shift	-" ~ "\n" ~
    "oem_102	shift	-" ~ "\n" ~
    "a	ctrl	1" ~ "\n" ~
    "b	ctrl	2" ~ "\n" ~
    "c	ctrl	3" ~ "\n" ~
    "d	ctrl	4" ~ "\n" ~
    "e	ctrl	5" ~ "\n" ~
    "f	ctrl	6" ~ "\n" ~
    "g	ctrl	7" ~ "\n" ~
    "h	ctrl	8" ~ "\n" ~
    "i	ctrl	9" ~ "\n" ~
    "j	ctrl	10" ~ "\n" ~
    "k	ctrl	11" ~ "\n" ~
    "l	ctrl	12" ~ "\n" ~
    "m	ctrl	-" ~ "\n" ~
    "n	ctrl	14" ~ "\n" ~
    "o	ctrl	15" ~ "\n" ~
    "p	ctrl	16" ~ "\n" ~
    "q	ctrl	17" ~ "\n" ~
    "r	ctrl	18" ~ "\n" ~
    "s	ctrl	19" ~ "\n" ~
    "t	ctrl	20" ~ "\n" ~
    "u	ctrl	21" ~ "\n" ~
    "v	ctrl	22" ~ "\n" ~
    "w	ctrl	23" ~ "\n" ~
    "x	ctrl	24" ~ "\n" ~
    "y	ctrl	25" ~ "\n" ~
    "z	ctrl	26" ~ "\n" ~
    "tab	ctrl	-" ~ "\n" ~
    "page_up	ctrl	27,91,53,59,53,126" ~ "\n" ~
    "page_down	ctrl	27,91,54,59,53,126" ~ "\n" ~
    "end	ctrl	27,91,49,59,53,70" ~ "\n" ~
    "home	ctrl	27,91,49,59,53,72" ~ "\n" ~
    "left	ctrl	27,91,49,59,53,68" ~ "\n" ~
    "up	ctrl	27,91,49,59,53,65" ~ "\n" ~
    "right	ctrl	27,91,49,59,53,67" ~ "\n" ~
    "down	ctrl	27,91,49,59,53,66" ~ "\n" ~
    "key_0	ctrl	-" ~ "\n" ~
    "key_1	ctrl	-" ~ "\n" ~
    "key_2	ctrl	-" ~ "\n" ~
    "key_3	ctrl	-" ~ "\n" ~
    "key_4	ctrl	28" ~ "\n" ~
    "key_5	ctrl	29" ~ "\n" ~
    "key_6	ctrl	30" ~ "\n" ~
    "key_7	ctrl	31" ~ "\n" ~
    "key_8	ctrl	-" ~ "\n" ~
    "key_9	ctrl	-" ~ "\n" ~
    "numpad_0	ctrl	-" ~ "\n" ~
    "numpad_1	ctrl	-" ~ "\n" ~
    "numpad_2	ctrl	-" ~ "\n" ~
    "numpad_3	ctrl	-" ~ "\n" ~
    "numpad_4	ctrl	-" ~ "\n" ~
    "numpad_5	ctrl	-" ~ "\n" ~
    "numpad_6	ctrl	-" ~ "\n" ~
    "numpad_7	ctrl	-" ~ "\n" ~
    "numpad_8	ctrl	-" ~ "\n" ~
    "numpad_9	ctrl	-" ~ "\n" ~
    "plus	ctrl	-" ~ "\n" ~
    "minus	ctrl	-" ~ "\n" ~
    "period	ctrl	-" ~ "\n" ~
    "comma	ctrl	-" ~ "\n" ~
    "asterisk	ctrl	-" ~ "\n" ~
    "divide	ctrl	-" ~ "\n" ~
    "f1	ctrl	27,91,49,59,53,80" ~ "\n" ~
    "f2	ctrl	27,91,49,59,53,81" ~ "\n" ~
    "f3	ctrl	27,91,49,59,53,82" ~ "\n" ~
    "f4	ctrl	27,91,49,59,53,83" ~ "\n" ~
    "f5	ctrl	27,91,49,53,59,53,126" ~ "\n" ~
    "f6	ctrl	27,91,49,55,59,53,126" ~ "\n" ~
    "f7	ctrl	27,91,49,56,59,53,126" ~ "\n" ~
    "f8	ctrl	27,91,49,57,59,53,126" ~ "\n" ~
    "f9	ctrl	27,91,50,48,59,53,126" ~ "\n" ~
    "f10	ctrl	27,91,50,49,59,53,126" ~ "\n" ~
    "f11	ctrl	27,91,50,51,59,53,126" ~ "\n" ~
    "f12	ctrl	27,91,50,52,59,53,126" ~ "\n" ~
    "f13	ctrl	-" ~ "\n" ~
    "f14	ctrl	-" ~ "\n" ~
    "f15	ctrl	-" ~ "\n" ~
    "f16	ctrl	-" ~ "\n" ~
    "f17	ctrl	-" ~ "\n" ~
    "f18	ctrl	-" ~ "\n" ~
    "f19	ctrl	-" ~ "\n" ~
    "f20	ctrl	-" ~ "\n" ~
    "f21	ctrl	-" ~ "\n" ~
    "f22	ctrl	-" ~ "\n" ~
    "f23	ctrl	-" ~ "\n" ~
    "f24	ctrl	-" ~ "\n" ~
    "oem_1	ctrl	-" ~ "\n" ~
    "oem_2	ctrl	-" ~ "\n" ~
    "oem_3	ctrl	-" ~ "\n" ~
    "oem_4	ctrl	-" ~ "\n" ~
    "oem_5	ctrl	-" ~ "\n" ~
    "oem_6	ctrl	-" ~ "\n" ~
    "oem_7	ctrl	-" ~ "\n" ~
    "oem_8	ctrl	-" ~ "\n" ~
    "oem_102	ctrl	-" ~ "\n" ~
    "a	alt	27,97" ~ "\n" ~
    "b	alt	27,98" ~ "\n" ~
    "c	alt	27,99" ~ "\n" ~
    "d	alt	27,100" ~ "\n" ~
    "e	alt	27,101" ~ "\n" ~
    "f	alt	27,102" ~ "\n" ~
    "g	alt	27,103" ~ "\n" ~
    "h	alt	27,104" ~ "\n" ~
    "i	alt	27,105" ~ "\n" ~
    "j	alt	27,106" ~ "\n" ~
    "k	alt	27,107" ~ "\n" ~
    "l	alt	27,108" ~ "\n" ~
    "m	alt	27,109" ~ "\n" ~
    "n	alt	27,110" ~ "\n" ~
    "o	alt	27,111" ~ "\n" ~
    "p	alt	27,112" ~ "\n" ~
    "q	alt	27,113" ~ "\n" ~
    "r	alt	27,114" ~ "\n" ~
    "s	alt	27,115" ~ "\n" ~
    "t	alt	27,116" ~ "\n" ~
    "u	alt	27,117" ~ "\n" ~
    "v	alt	27,118" ~ "\n" ~
    "w	alt	27,119" ~ "\n" ~
    "x	alt	27,120" ~ "\n" ~
    "y	alt	27,121" ~ "\n" ~
    "z	alt	27,122" ~ "\n" ~
    "tab	alt	-" ~ "\n" ~
    "page_up	alt	27,91,53,59,51,126" ~ "\n" ~
    "page_down	alt	27,91,54,59,51,126" ~ "\n" ~
    "end	alt	27,91,49,59,51,70" ~ "\n" ~
    "home	alt	27,91,49,59,51,72" ~ "\n" ~
    "left	alt	27,91,49,59,51,68" ~ "\n" ~
    "up	alt	27,91,49,59,51,65" ~ "\n" ~
    "right	alt	27,91,49,59,51,67" ~ "\n" ~
    "down	alt	27,91,49,59,51,66" ~ "\n" ~
    "key_0	alt	27,48" ~ "\n" ~
    "key_1	alt	27,49" ~ "\n" ~
    "key_2	alt	27,50" ~ "\n" ~
    "key_3	alt	27,51" ~ "\n" ~
    "key_4	alt	27,52" ~ "\n" ~
    "key_5	alt	27,53" ~ "\n" ~
    "key_6	alt	27,54" ~ "\n" ~
    "key_7	alt	27,55" ~ "\n" ~
    "key_8	alt	27,56" ~ "\n" ~
    "key_9	alt	27,57" ~ "\n" ~
    "numpad_0	alt	-" ~ "\n" ~
    "numpad_1	alt	-" ~ "\n" ~
    "numpad_2	alt	-" ~ "\n" ~
    "numpad_3	alt	-" ~ "\n" ~
    "numpad_4	alt	-" ~ "\n" ~
    "numpad_5	alt	-" ~ "\n" ~
    "numpad_6	alt	-" ~ "\n" ~
    "numpad_7	alt	-" ~ "\n" ~
    "numpad_8	alt	-" ~ "\n" ~
    "numpad_9	alt	-" ~ "\n" ~
    "plus	alt	-" ~ "\n" ~
    "minus	alt	-" ~ "\n" ~
    "period	alt	27,46" ~ "\n" ~
    "comma	alt	27,44" ~ "\n" ~
    "asterisk	alt	-" ~ "\n" ~
    "divide	alt	-" ~ "\n" ~
    "f1	alt	-" ~ "\n" ~
    "f2	alt	-" ~ "\n" ~
    "f3	alt	-" ~ "\n" ~
    "f4	alt	39" ~ "\n" ~
    "f5	alt	27,91,49,53,59,51,126" ~ "\n" ~
    "f6	alt	27,91,49,55,59,51,126" ~ "\n" ~
    "f7	alt	-" ~ "\n" ~
    "f8	alt	-" ~ "\n" ~
    "f9	alt	27,91,50,48,59,51,126" ~ "\n" ~
    "f10	alt	-" ~ "\n" ~
    "f11	alt	27,91,50,51,59,51,126" ~ "\n" ~
    "f12	alt	27,91,50,52,59,51,126" ~ "\n" ~
    "f13	alt	-" ~ "\n" ~
    "f14	alt	-" ~ "\n" ~
    "f15	alt	-" ~ "\n" ~
    "f16	alt	-" ~ "\n" ~
    "f17	alt	-" ~ "\n" ~
    "f18	alt	-" ~ "\n" ~
    "f19	alt	-" ~ "\n" ~
    "f20	alt	-" ~ "\n" ~
    "f21	alt	-" ~ "\n" ~
    "f22	alt	-" ~ "\n" ~
    "f23	alt	-" ~ "\n" ~
    "f24	alt	-" ~ "\n" ~
    "oem_1	alt	27,195,165" ~ "\n" ~
    "oem_2	alt	27,195,164" ~ "\n" ~
    "oem_3	alt	27,195,182" ~ "\n" ~
    "oem_4	alt	-" ~ "\n" ~
    "oem_5	alt	-" ~ "\n" ~
    "oem_6	alt	-" ~ "\n" ~
    "oem_7	alt	-" ~ "\n" ~
    "oem_8	alt	-" ~ "\n" ~
    "oem_102	alt	-" ~ "\n" ~
    "escape	none	27" ~ "\n" ~
    "del	none	127" ~ "\n" ~
    "enter	none	13";
}
