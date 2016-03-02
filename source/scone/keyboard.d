module scone.keyboard;

import scone.core;
import scone.utility;

/**
 * Key event structure
 * Contains general information about a key press
 * Note: Does not work on POSIX yet!
 */
struct KeyEvent
{
    package(scone) version(Windows) this(KEY_EVENT_RECORD k)
    {
        _winKey = k;
    }

    /**
     * Check if the button is pressed or released.
     * Returns: bool, true if pressed, false if not
     */
    auto pressed() @property
    {
        version(Windows)
        {
            return cast(bool) _winKey.bKeyDown;
        }
        version(Posix)
        {
            return 0;
        }
    }

    /**
     * Get the key
     * Returns: SK (enum) of the key being pressed
     */
    auto key() @property
    {
        version(Windows)
        {
            return win_getKeyFromKeyEventRecord(_winKey);
        }
        version(Posix)
        {
            return 0;
        }
    }

    /**
     * Check if the KeyEvent has a "control key" pressed.
     * Returns: true, if all control keys entered are pressed
     *
     * Example:
     * --------------------
     * foreach(input; getInputs())
     * {
     *     if(input.hasControlKey(ControlKey.CTRL | ControlKey.ALT | ControlKey.SHIFT))
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

    /+
    /**
     * Check the amount of times an event has been repeated since last check (held down).
     * Returns: int, the amount of repeats
     * Note: This is a bit unstable. I suggest you don't use /vladde
     */
    @disable auto repeated() @property
    {
        version(Windows)
        {
            return cast(int) _winKey.wRepeatCount;
        }
        version(Posix)
        {
            return 0;
        }
    }
    +/

    /**
     * Get control all keys
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
        version(Windows)
        {
            return win_getControlKeyFromKeyEventRecord(_winKey);
        }
        version(Posix)
        {
            return 0;
        }
    }

    version(Windows) private KEY_EVENT_RECORD _winKey;
}

/**
 * Get all inputs since last function call.
 * Returns: KeyEvent[], of all key presses since last call
 * Note: (Windows) A maximum of 128 key presses can be stored in between each call. This should however not be a problem, since `getInputs()` should be called each game tick
 */
auto getInputs()
{
    version(Windows) win_getInput();
    auto temp = keyInputs;
    clearInputs();
    return temp;
}

/**
 * Clears all buffered inputs.
 * Useful if you have a loading screen of some sort, and need to clear key presses once loaded.
 */
auto clearInputs()
{
    keyInputs = null;
}

///All keys that Scone can handle
enum SK
{
    ///Unknown key (Should never appear. If do, please report bug)
    Unknown,

    ///BACKSPACE key
    Backspace,

    ///TAB key
    Tab,

    ///CLEAR key
    Clear,

    ///ENTER key
    Enter,

    ///SHIFT key
    Shift,

    ///CTRL key
    Control,

    ///ALT key
    Alt,

    ///PAUSE key
    Pause,

    ///CAPS LOCK key
    Capslock,

    ///ESC key
    Escape,

    ///SPACEBAR
    Space,

    ///PAGE UP key
    Page_up,

    ///PAGE DOWN key
    Page_down,

    ///END key
    End,

    ///HOME key
    Home,

    ///LEFT ARROW key
    Left,

    ///UP ARROW key
    Up,

    ///RIGHT ARROW key
    Right,

    ///DOWN ARROW key
    Down,

    ///SELECT key
    Select,

    ///PRINT key
    Print,

    ///EXECUTE key
    Execute,

    ///PRINT SCREEN key
    Print_screen,

    ///INS key
    Insert,

    ///DEL key
    Delete,

    ///HELP key
    Help,

    ///0 key
    Key_0,

    ///1 key
    Key_1,

    ///2 key
    Key_2,

    ///3 key
    Key_3,

    ///4 key
    Key_4,

    ///5 key
    Key_5,

    ///6 key
    Key_6,

    ///7 key
    Key_7,

    ///8 key
    Key_8,

    ///9 key
    Key_9,

    ///A key
    A,

    ///B key
    B,

    ///C key
    C,

    ///D key
    D,

    ///E key
    E,

    ///F key
    F,

    ///G key
    G,

    ///H key
    H,

    ///I key
    I,

    ///J key
    J,

    ///K key
    K,

    ///L key
    L,

    ///M key
    M,

    ///N key
    N,

    ///O key
    O,

    ///P key
    P,

    ///Q key
    Q,

    ///R key
    R,

    ///S key
    S,

    ///T key
    T,

    ///U key
    U,

    ///V key
    V,

    ///W key
    W,

    ///X key
    X,

    ///Y key
    Y,

    ///Z key
    Z,

    ///Left Windows key (Natural keyboard)
    Windows_left,

    ///Right Windows key (Natural keyboard)
    Windows_right,

    ///Applications key (Natural keyboard)
    Apps,

    ///Computer Sleep key
    Sleep,

    ///Numeric keypad 0 key
    Numpad_0,

    ///Numeric keypad 1 key
    Numpad_1,

    ///Numeric keypad 2 key
    Numpad_2,

    ///Numeric keypad 3 key
    Numpad_3,

    ///Numeric keypad 4 key
    Numpad_4,

    ///Numeric keypad 5 key
    Numpad_5,

    ///Numeric keypad 6 key
    Numpad_6,

    ///Numeric keypad 7 key
    Numpad_7,

    ///Numeric keypad 8 key
    Numpad_8,

    ///Numeric keypad 9 key
    Numpad_9,

    ///Multiply key
    Multiply,

    ///Add key
    Add,

    ///Separator key
    Separator,

    ///Subtract key
    Subtract,

    ///Decimal key
    Decimal,

    ///Divide key
    Divide,

    ///F1 key
    F1,

    ///F2 key
    F2,

    ///F3 key
    F3,

    ///F4 key
    F4,

    ///F5 key
    F5,

    ///F6 key
    F6,

    ///F7 key
    F7,

    ///F8 key
    F8,

    ///F9 key
    F9,

    ///F10 key
    F10,

    ///F11 key
    F11,

    ///F12 key
    F12,

    ///F13 key
    F13,

    ///F14 key
    F14,

    ///F15 key
    F15,

    ///F16 key
    F16,

    ///F17 key
    F17,

    ///F18 key
    F18,

    ///F19 key
    F19,

    ///F20 key
    F20,

    ///F21 key
    F21,

    ///F22 key
    F22,

    ///F23 key
    F23,

    ///F24 key
    F24,

    ///NUM LOCK key
    Numlock,

    ///SCROLL LOCK key
    Scroll_lock,

    ///Left SHIFT key
    Shift_left,

    ///Right SHIFT key
    Shift_right,

    ///Left CONTROL key
    Control_left,

    ///Right CONTROL key
    Control_right,

    ///Left MENU key
    Menu_left,

    ///Right MENU key
    Menu_right,

    ///Browser Back key
    Browser_back,

    ///Browser Forward key
    Browser_forward,

    ///Browser Refresh key
    Browser_refresh,

    ///Browser Stop key
    Browser_stop,

    ///Browser Search key
    Browser_search,

    ///Browser Favorites key
    Browser_favorites,

    ///Browser Start and Home key
    Browser_home,

    ///Volume Mute key
    Volume_mute,

    ///Volume Down key
    Volume_down,

    ///Volume Up key
    Volume_up,

    ///Next Track key
    Media_next,

    ///Previous Track key
    Media_prev,

    ///Stop Media key
    Media_stop,

    ///Play/Pause Media key
    Media_play_pause,

    ///Start Mail key
    Launch_mail,

    ///Select Media key
    Launch_media_select,

    ///Start Application 1 key
    Launch_app_1,

    ///Start Application 2 key
    Launch_app_2,

    //Add OEM to name?
    ///For any country/region, the '+' key
    Plus,

    ///For any country/region, the ',' key
    Comma,

    ///For any country/region, the '-' key
    Minus,

    ///For any country/region, the '.' key
    Period,

    ///Used to pass Unicode characters as if they were keystrokes. The PACKET key is the low word of a 32-bit Virtual Key value used for non-keyboard input methods. For more information, see Remark in KEYBDINPUT, SendInput, WM_KEYDOWN, and WM_KEYUP
    Packet,

    ///Erase EOF key
    Ereof,

    ///Play key
    Play,

    ///Zoom key
    Zoom,

    ///Clear key
    Oem_clear,

    ///Attn key
    Attn,

    ///CrSel key
    Crsel,

    ///ExSel key
    Exsel,

    ///Used for miscellaneous characters; it can vary by keyboard.
    Oem_1,

    ///Used for miscellaneous characters; it can vary by keyboard.
    Oem_2,

    ///Used for miscellaneous characters; it can vary by keyboard.
    Oem_3,

    ///Used for miscellaneous characters; it can vary by keyboard.
    Oem_4,

    ///Used for miscellaneous characters; it can vary by keyboard.
    Oem_5,

    ///Used for miscellaneous characters; it can vary by keyboard.
    Oem_6,

    ///Used for miscellaneous characters; it can vary by keyboard.
    Oem_7,

    ///Used for miscellaneous characters; it can vary by keyboard.
    Oem_8,

    ///Either the angle bracket key or the backslash key on the RT 102-key keyboard
    Oem_102,

    ///Control-break processing
    Cancel,
}

/**
 * Control keys.
 * Reason to why these are in a separate enum is because it must not be confused with their SK.* counter part.
 */
enum SCK
{
    ///No control key is being pressed
    None = 0,

    ///CAPS LOCK light is activated
    Capslock = 1,

    ///NUM LOCK is activated
    Numlock = 2,

    ///SCROLL LOCK is activated
    Scrolllock = 4,

    ///SHIFT key is pressed
    Shift = 8,

    ///The key is enhanced (?)
    Enhanced = 16,

    ///Left or right ALT key is pressed
    Alt = 32,

    ///Left or right CTRL key is pressed
    Ctrl = 64,
}

package(scone)
{
    KeyEvent[] keyInputs;

    version(Windows)
    {
        import scone.windows.win_keyboard;
        import core.sys.windows.windows;
    }

    auto keyboardInit()
    {
        if(!moduleKeyboard)
        {
            version (Windows)
            {
                win_initKeyboard();
            }
            version (Posix)
            {
                //posix_initKeyboard();
            }

            moduleKeyboard = true;
        }
    }

    auto keyboardClose()
    {
        if(moduleKeyboard)
        {
            version(Windows)
            {
                win_exitKeyboard();
            }
            version(Posix)
            {
                //posix_exitKeyboard();
            }

            moduleKeyboard = false;
        }
    }
}
