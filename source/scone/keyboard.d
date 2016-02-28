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
        m_winKey = k;
    }

    /**
     * Check if the button is pressed or released.
     * Returns: bool, true if pressed, false if not
     */
    auto pressed() @property
    {
        version(Windows)
        {
            return cast(bool) m_winKey.bKeyDown;
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
            return win_getKeyFromKeyEventRecord(m_winKey);
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
            return cast(int) m_winKey.wRepeatCount;
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
            return win_getControlKeyFromKeyEventRecord(m_winKey);
        }
        version(Posix)
        {
            return 0;
        }
    }

    version(Windows) private KEY_EVENT_RECORD m_winKey;
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
    UNKNOWN,

    ///BACKSPACE key
    BACKSPACE,

    ///TAB key
    TAB,

    ///CLEAR key
    CLEAR,

    ///ENTER key
    ENTER,

    ///SHIFT key
    SHIFT,

    ///CTRL key
    CONTROL,

    ///ALT key
    ALT,

    ///PAUSE key
    PAUSE,

    ///CAPS LOCK key
    CAPSLOCK,

    ///ESC key
    ESCAPE,

    ///SPACEBAR
    SPACE,

    ///PAGE UP key
    PAGE_UP,

    ///PAGE DOWN key
    PAGE_DOWN,

    ///END key
    END,

    ///HOME key
    HOME,

    ///LEFT ARROW key
    LEFT,

    ///UP ARROW key
    UP,

    ///RIGHT ARROW key
    RIGHT,

    ///DOWN ARROW key
    DOWN,

    ///SELECT key
    SELECT,

    ///PRINT key
    PRINT,

    ///EXECUTE key
    EXECUTE,

    ///PRINT SCREEN key
    PRINT_SCREEN,

    ///INS key
    INSERT,

    ///DEL key
    DELETE,

    ///HELP key
    HELP,

    ///0 key
    K_0,

    ///1 key
    K_1,

    ///2 key
    K_2,

    ///3 key
    K_3,

    ///4 key
    K_4,

    ///5 key
    K_5,

    ///6 key
    K_6,

    ///7 key
    K_7,

    ///8 key
    K_8,

    ///9 key
    K_9,

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
    WINDOWS_LEFT,

    ///Right Windows key (Natural keyboard)
    WINDOWS_RIGHT,

    ///Applications key (Natural keyboard)
    APPS,

    ///Computer Sleep key
    SLEEP,

    ///Numeric keypad 0 key
    NUMPAD_0,

    ///Numeric keypad 1 key
    NUMPAD_1,

    ///Numeric keypad 2 key
    NUMPAD_2,

    ///Numeric keypad 3 key
    NUMPAD_3,

    ///Numeric keypad 4 key
    NUMPAD_4,

    ///Numeric keypad 5 key
    NUMPAD_5,

    ///Numeric keypad 6 key
    NUMPAD_6,

    ///Numeric keypad 7 key
    NUMPAD_7,

    ///Numeric keypad 8 key
    NUMPAD_8,

    ///Numeric keypad 9 key
    NUMPAD_9,

    ///Multiply key
    MULTIPLY,

    ///Add key
    ADD,

    ///Separator key
    SEPARATOR,

    ///Subtract key
    SUBTRACT,

    ///Decimal key
    DECIMAL,

    ///Divide key
    DIVIDE,

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
    NUMLOCK,

    ///SCROLL LOCK key
    SCROLL_LOCK,

    ///Left SHIFT key
    SHIFT_LEFT,

    ///Right SHIFT key
    SHIFT_RIGHT,

    ///Left CONTROL key
    CONTROL_LEFT,

    ///Right CONTROL key
    CONTROL_RIGHT,

    ///Left MENU key
    MENU_LEFT,

    ///Right MENU key
    MENU_RIGHT,

    ///Browser Back key
    BROWSER_BACK,

    ///Browser Forward key
    BROWSER_FORWARD,

    ///Browser Refresh key
    BROWSER_REFRESH,

    ///Browser Stop key
    BROWSER_STOP,

    ///Browser Search key
    BROWSER_SEARCH,

    ///Browser Favorites key
    BROWSER_FAVORITES,

    ///Browser Start and Home key
    BROWSER_HOME,

    ///Volume Mute key
    VOLUME_MUTE,

    ///Volume Down key
    VOLUME_DOWN,

    ///Volume Up key
    VOLUME_UP,

    ///Next Track key
    MEDIA_NEXT,

    ///Previous Track key
    MEDIA_PREV,

    ///Stop Media key
    MEDIA_STOP,

    ///Play/Pause Media key
    MEDIA_PLAY_PAUSE,

    ///Start Mail key
    LAUNCH_MAIL,

    ///Select Media key
    LAUNCH_MEDIA_SELECT,

    ///Start Application 1 key
    LAUNCH_APP_1,

    ///Start Application 2 key
    LAUNCH_APP_2,

    //Add OEM to name?
    ///For any country/region, the '+' key
    PLUS,

    ///For any country/region, the ',' key
    COMMA,

    ///For any country/region, the '-' key
    MINUS,

    ///For any country/region, the '.' key
    PERIOD,

    ///Used to pass Unicode characters as if they were keystrokes. The PACKET key is the low word of a 32-bit Virtual Key value used for non-keyboard input methods. For more information, see Remark in KEYBDINPUT, SendInput, WM_KEYDOWN, and WM_KEYUP
    PACKET,

    ///Erase EOF key
    EREOF,

    ///Play key
    PLAY,

    ///Zoom key
    ZOOM,

    ///Clear key
    OEM_CLEAR,

    ///Attn key
    ATTN,

    ///CrSel key
    CRSEL,

    ///ExSel key
    EXSEL,

    ///Used for miscellaneous characters; it can vary by keyboard.
    OEM_1,

    ///Used for miscellaneous characters; it can vary by keyboard.
    OEM_2,

    ///Used for miscellaneous characters; it can vary by keyboard.
    OEM_3,

    ///Used for miscellaneous characters; it can vary by keyboard.
    OEM_4,

    ///Used for miscellaneous characters; it can vary by keyboard.
    OEM_5,

    ///Used for miscellaneous characters; it can vary by keyboard.
    OEM_6,

    ///Used for miscellaneous characters; it can vary by keyboard.
    OEM_7,

    ///Used for miscellaneous characters; it can vary by keyboard.
    OEM_8,

    ///Either the angle bracket key or the backslash key on the RT 102-key keyboard
    OEM_102,

    ///Control-break processing
    CANCEL
}

/**
 * Control keys.
 * Reason to why these are in a enum is because it must not be confused with their * counter part.
 */
enum SCK
{
    ///No control key is being pressed
    NONE = 0,

    ///CAPS LOCK light is activated
    CAPSLOCK = 1,

    ///NUM LOCK is activated
    NUMLOCK = 2,

    ///SCROLL LOCK is activated
    SCROLLLOCK = 4,

    ///SHIFT key is pressed
    SHIFT = 8,

    ///The key is enhanced (?)
    ENHANCED = 16,

    ///Left or right ALT key is pressed
    ALT = 32,

    ///Left or right CTRL key is pressed
    CTRL = 64,
}

package(scone)
{
    KeyEvent[] keyInputs;

    version(Windows)
    {
        import scone.windows.winkeyboard;
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
