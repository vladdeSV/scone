module scone.keyboard;

struct KeyEvent
{
    version(Windows) this(KEY_EVENT_RECORD k)
    {
        m_winKey = k;
    }

    auto keyDown() @property
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

    auto repeated() @property
    {
        version(Windows)
        {
            return m_winKey.wRepeatCount > 1; //TODO: Test to see if one press makes repeated equal to one or zero
        }
        version(Posix)
        {
            return 0;
        }
    }

    auto repeatedAmount() @property
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

    auto hasControlKey(ControlKey ck)
    {
        return hasFlag(controlKey, ck);
    }

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

    version(Windows) auto getVK()
    {
        return m_winKey.wVirtualKeyCode;
    }

    version(Windows) private KEY_EVENT_RECORD m_winKey;
}

auto getInputs()
{
    auto temp = keyInputs;
    clearInputs();
    return temp;
}

auto clearInputs()
{
    keyInputs = null;
}

package(scone):

import scone.utility;

version(Windows)
{
    import scone.windows.winkeyboard;
    import core.sys.windows.windows;
}
//version(Posix) public import scone.posix.posixkeyboard;

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

enum Key
{
    UNKNOWN,
    ////Control-break processing
    //SK_CANCEL,

    //BACKSPACE key
    SK_BACKSPACE,

    //TAB key
    SK_TAB,

    //CLEAR key
    SK_CLEAR,

    //ENTER key
    SK_ENTER,

    //SHIFT key
    SK_SHIFT,

    //CTRL key
    SK_CONTROL,

    //ALT key
    SK_ALT,

    //PAUSE key
    SK_PAUSE,

    //CAPS LOCK key
    SK_CAPSLOCK,

    //ESC key
    SK_ESCAPE,

    //SPACEBAR
    SK_SPACE,

    //PAGE UP key
    SK_PAGE_UP,

    //PAGE DOWN key
    SK_PAGE_DOWN,

    //END key
    SK_END,

    //HOME key
    SK_HOME,

    //LEFT ARROW key
    SK_LEFT,

    //UP ARROW key
    SK_UP,

    //RIGHT ARROW key
    SK_RIGHT,

    //DOWN ARROW key
    SK_DOWN,

    //SELECT key
    SK_SELECT,

    //PRINT key
    SK_PRINT,

    //EXECUTE key
    SK_EXECUTE,

    //PRINT SCREEN key
    SK_PRINT_SCREEN,

    //INS key
    SK_INSERT,

    //DEL key
    SK_DELETE,

    //HELP key
    SK_HELP,

    //0 key
    SK_0,

    //1 key
    SK_1,

    //2 key
    SK_2,

    //3 key
    SK_3,

    //4 key
    SK_4,

    //5 key
    SK_5,

    //6 key
    SK_6,

    //7 key
    SK_7,

    //8 key
    SK_8,

    //9 key
    SK_9,

    //A key
    SK_A,

    //B key
    SK_B,

    //C key
    SK_C,

    //D key
    SK_D,

    //E key
    SK_E,

    //F key
    SK_F,

    //G key
    SK_G,

    //H key
    SK_H,

    //I key
    SK_I,

    //J key
    SK_J,

    //K key
    SK_K,

    //L key
    SK_L,

    //M key
    SK_M,

    //N key
    SK_N,

    //O key
    SK_O,

    //P key
    SK_P,

    //Q key
    SK_Q,

    //R key
    SK_R,

    //S key
    SK_S,

    //T key
    SK_T,

    //U key
    SK_U,

    //V key
    SK_V,

    //W key
    SK_W,

    //X key
    SK_X,

    //Y key
    SK_Y,

    //Z key
    SK_Z,

    //Left Windows key (Natural keyboard)
    SK_WINDOWS_LEFT,

    //Right Windows key (Natural keyboard)
    SK_WINDOWS_RIGHT,

    //Applications key (Natural keyboard)
    SK_APPS,

    //Computer Sleep key
    SK_SLEEP,

    //Numeric keypad 0 key
    SK_NUMPAD_0,

    //Numeric keypad 1 key
    SK_NUMPAD_1,

    //Numeric keypad 2 key
    SK_NUMPAD_2,

    //Numeric keypad 3 key
    SK_NUMPAD_3,

    //Numeric keypad 4 key
    SK_NUMPAD_4,

    //Numeric keypad 5 key
    SK_NUMPAD_5,

    //Numeric keypad 6 key
    SK_NUMPAD_6,

    //Numeric keypad 7 key
    SK_NUMPAD_7,

    //Numeric keypad 8 key
    SK_NUMPAD_8,

    //Numeric keypad 9 key
    SK_NUMPAD_9,

    //Multiply key
    SK_MULTIPLY,

    //Add key
    SK_ADD,

    //Separator key
    SK_SEPARATOR,

    //Subtract key
    SK_SUBTRACT,

    //Decimal key
    SK_DECIMAL,

    //Divide key
    SK_DIVIDE,

    //F1 key
    SK_F1,

    //F2 key
    SK_F2,

    //F3 key
    SK_F3,

    //F4 key
    SK_F4,

    //F5 key
    SK_F5,

    //F6 key
    SK_F6,

    //F7 key
    SK_F7,

    //F8 key
    SK_F8,

    //F9 key
    SK_F9,

    //F10 key
    SK_F10,

    //F11 key
    SK_F11,

    //F12 key
    SK_F12,

    //F13 key
    SK_F13,

    //F14 key
    SK_F14,

    //F15 key
    SK_F15,

    //F16 key
    SK_F16,

    //F17 key
    SK_F17,

    //F18 key
    SK_F18,

    //F19 key
    SK_F19,

    //F20 key
    SK_F20,

    //F21 key
    SK_F21,

    //F22 key
    SK_F22,

    //F23 key
    SK_F23,

    //F24 key
    SK_F24,

    //NUM LOCK key
    SK_NUMLOCK,

    //SCROLL LOCK key
    SK_SCROLL_LOCK,

    //Left SHIFT key
    SK_SHIFT_LEFT,

    //Right SHIFT key
    SK_SHIFT_RIGHT,

    //Left CONTROL key
    SK_CONTROL_LEFT,

    //Right CONTROL key
    SK_CONTROL_RIGHT,

    //Left MENU key
    SK_MENU_LEFT,

    //Right MENU key
    SK_MENU_RIGHT,

    //Browser Back key
    SK_BROWSER_BACK,

    //Browser Forward key
    SK_BROWSER_FORWARD,

    //Browser Refresh key
    SK_BROWSER_REFRESH,

    //Browser Stop key
    SK_BROWSER_STOP,

    //Browser Search key
    SK_BROWSER_SEARCH,

    //Browser Favorites key
    SK_BROWSER_FAVORITES,

    //Browser Start and Home key
    SK_BROWSER_HOME,

    //Volume Mute key
    SK_VOLUME_MUTE,

    //Volume Down key
    SK_VOLUME_DOWN,

    //Volume Up key
    SK_VOLUME_UP,

    //Next Track key
    SK_MEDIA_NEXT,

    //Previous Track key
    SK_MEDIA_PREV,

    //Stop Media key
    SK_MEDIA_STOP,

    //Play/Pause Media key
    SK_MEDIA_PLAY_PAUSE,

    //Start Mail key
    SK_LAUNCH_MAIL,

    //Select Media key
    SK_LAUNCH_MEDIA_SELECT,

    //Start Application 1 key
    SK_LAUNCH_APP_1,

    //Start Application 2 key
    SK_LAUNCH_APP_2,

    //Add OEM to name?
    //For any country/region, the '+' key
    SK_PLUS,

    //For any country/region, the ',' key
    SK_COMMA,

    //For any country/region, the '-' key
    SK_MINUS,

    //For any country/region, the '.' key
    SK_PERIOD,

    //Used to pass Unicode characters as if they were keystrokes. The SK_PACKET key is the low word of a 32-bit Virtual Key value used for non-keyboard input methods. For more information, see Remark in KEYBDINPUT, SendInput, WM_KEYDOWN, and WM_KEYUP
    SK_PACKET,

    //Erase EOF key
    SK_EREOF,

    //Play key
    SK_PLAY,

    //Zoom key
    SK_ZOOM,

    //Clear key
    SK_ATTN,
    SK_CRSEL,
    SK_EXSEL,
    SK_MENU,
    SK_OEM_1,
    SK_OEM_2,
    SK_OEM_3,
    SK_OEM_4,
    SK_OEM_5,
    SK_OEM_6,
    SK_OEM_7,
    SK_OEM_8,
    SK_OEM_102,
    SK_OEM_CLEAR,
    SK_PROCESSKEY,

    SK_BUTTON_LEFT,
    SK_BUTTON_RIGHT,
    SK_CLICK,
    SK_CANCEL,
    SK_XBUTTON1,
    SK_XBUTTON2,
}

enum ControlKey
{
    NONE = 0,

    //The CAPS LOCK light is on
    CAPSLOCK = 1,

    //The NUM LOCK light is on
    NUMLOCK = 2,

    //The SCROLL LOCK light is on
    SCROLLLOCK = 4,

    //The SHIFT key is pressed
    SHIFT = 8,

    //The key is enhanced (?)
    ENHANCED = 16,

    //The left ALT key is pressed
    ALT = 32,

    //The left CTRL key is pressed
    CTRL = 64,
}
