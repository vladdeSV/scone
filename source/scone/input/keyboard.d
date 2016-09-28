module scone.input.keyboard;

import scone.misc.utility;
import scone.misc.core;

/**
 * Key event structure
 * Contains general information about a key press
 */
struct KeyEvent
{
    version(Windows) this(SK key, SCK controlKey, bool pressed)
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

    /**
     * Get control all keys, used to check if ONLY certain control keys are down
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

    private
    {
        SK _key;
        SCK _controlKey;
        bool _pressed;
    }
}

/**
 * Get all inputs since last function call.
 * Returns: KeyEvent[], of all key presses since last call
 * Note: (Windows) A maximum of 128 key presses can be stored in between each call.
 */
auto getInputs()
{
    version(Windows) win_getInput();

    scope(exit)
    {
        clearInputs();
    }

    return keyInputs;
}
/**
 * Clears all buffered inputs.
 * Useful if you have a loading screen of some sort, and need to clear key presses once loaded.
 */
auto clearInputs()
{
    keyInputs = null;
}

///All keys which scone can handle
enum SK
{
    ///Unknown key (Should never appear. If do, please report bug)
    unknown,

    ///BACKSPACE key
    backspace,

    ///TAB key
    tab,

    ///CLEAR key
    clear,

    ///ENTER key
    enter,

    ///SHIFT key
    shift,

    ///CTRL key
    control,

    ///ALT key
    alt,

    ///PAUSE key
    pause,

    ///CAPS LOCK key
    capslock,

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

    ///SELECT key
    select,

    ///PRINT key
    print,

    ///EXECUTE key
    execute,

    ///PRINT SCREEN key
    print_screen,

    ///INS key
    insert,

    ///DEL key
    del,

    ///HELP key
    help,

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

    ///Left Windows key (Natural keyboard)
    windows_left,

    ///Right Windows key (Natural keyboard)
    windows_right,

    ///Applications key (Natural keyboard)
    apps,

    ///Computer Sleep key
    sleep,

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

    ///Multiply key
    multiply,

    ///Add key
    add,

    ///Separator key
    separator,

    ///Subtract key
    subtract,

    ///Decimal key
    decimal,

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

    ///NUM LOCK key
    numlock,

    ///SCROLL LOCK key
    scroll_lock,

    ///Left SHIFT key
    shift_left,

    ///Right SHIFT key
    shift_right,

    ///Left CONTROL key
    control_left,

    ///Right CONTROL key
    control_right,

    ///Left MENU key
    menu_left,

    ///Right MENU key
    menu_right,

    ///Browser Back key
    browser_back,

    ///Browser Forward key
    browser_forward,

    ///Browser Refresh key
    browser_refresh,

    ///Browser Stop key
    browser_stop,

    ///Browser Search key
    browser_search,

    ///Browser Favorites key
    browser_favorites,

    ///Browser Start and Home key
    browser_home,

    ///Volume Mute key
    volume_mute,

    ///Volume Down key
    volume_down,

    ///Volume Up key
    volume_up,

    ///Next Track key
    media_next,

    ///Previous Track key
    media_prev,

    ///Stop Media key
    media_stop,

    ///Play/Pause Media key
    media_play_pause,

    ///Start Mail key
    launch_mail,

    ///Select Media key
    launch_media_select,

    ///Start Application 1 key
    launch_app_1,

    ///Start Application 2 key
    launch_app_2,

    //Add OEM to name?
    ///For any country/region, the '+' key
    plus,

    ///For any country/region, the ',' key
    comma,

    ///For any country/region, the '-' key
    minus,

    ///For any country/region, the '.' key
    period,

    ///Used to pass Unicode characters as if they were keystrokes. The PACKET key is the low word of a 32-bit Virtual Key value used for non-keyboard input methods. For more information, see Remark in KEYBDINPUT, SendInput, WM_KEYDOWN, and WM_KEYUP
    packet,

    ///Erase EOF key
    ereof,

    ///Play key
    play,

    ///Zoom key
    zoom,

    ///Clear key
    oem_clear,

    ///Attn key
    attn,

    ///CrSel key
    crsel,

    ///ExSel key
    exsel,

    ///Used for miscellaneous characters; it can vary by keyboard.
    oem_1,

    ///Used for miscellaneous characters; it can vary by keyboard.
    oem_2,

    ///Used for miscellaneous characters; it can vary by keyboard.
    oem_3,

    ///Used for miscellaneous characters; it can vary by keyboard.
    oem_4,

    ///Used for miscellaneous characters; it can vary by keyboard.
    oem_5,

    ///Used for miscellaneous characters; it can vary by keyboard.
    oem_6,

    ///Used for miscellaneous characters; it can vary by keyboard.
    oem_7,

    ///Used for miscellaneous characters; it can vary by keyboard.
    oem_8,

    ///Either the angle bracket key or the backslash key on the RT 102-key keyboard
    oem_102,

    ///Control-break processing
    cancel,
}

/**
 * Control keys.
 * Reason to why these are in a separate enum is because it must not be confused with their SK.* counter part.
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

package(scone)
{
    import core.sys.windows.windows;
    import scone.input.win_keyboard;

    KeyEvent[] keyInputs;

    auto openKeyboard()
    {
        version(Windows) win_openKeyboard();
    }

    auto closeKeyboard()
    {
        version(Windows) win_closeKeyboard();
    }
}
