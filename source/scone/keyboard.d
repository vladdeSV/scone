module scone.keyboard;

/+

struct WinKey
{
    auto win_keyDown() @property
    {
        return cast(bool) _winKey.bKeyDown;
    }

    auto win_repeated() @property
    {
        return _winKey.wRepeatCount > 0;
    }

    auto win_repeatedAmount() @property
    {
        return cast(int) _winKey.wRepeatCount;
    }

    auto win_key()
    {
        return _winKey.wVirtualKeyCode;
    }

    private KEY_EVENT_RECORD _winKey;
}

enum KeyboardKey
{
    //Control-break processing
    SK_CANCEL = 0x03,

    //BACKSPACE key
    SK_BACK = 0x08,

    //TAB key
    SK_TAB = 0x09,

    //CLEAR key
    SK_CLEAR = 0x0C,

    //ENTER key
    SK_RETURN = 0x0D,

    //SHIFT key
    SK_SHIFT = 0x10,

    //CTRL key
    SK_CONTROL = 0x11,

    //ALT key
    SK_MENU = 0x12,

    //PAUSE key
    SK_PAUSE = 0x13,

    //CAPS LOCK key
    SK_CAPITAL = 0x14,

    //ESC key
    SK_ESCAPE = 0x1B,

    //SPACEBAR
    SK_SPACE = 0x20,

    //PAGE UP key
    SK_PRIOR = 0x21,

    //PAGE DOWN key
    SK_NEXT = 0x22,

    //END key
    SK_END = 0x23,

    //HOME key
    SK_HOME = 0x24,

    //LEFT ARROW key
    SK_LEFT = 0x25,

    //UP ARROW key
    SK_UP = 0x26,

    //RIGHT ARROW key
    SK_RIGHT = 0x27,

    //DOWN ARROW key
    SK_DOWN = 0x28,

    //SELECT key
    SK_SELECT = 0x29,

    //PRINT key
    SK_PRINT = 0x2A,

    //EXECUTE key
    SK_EXECUTE = 0x2B,

    //PRINT SCREEN key
    SK_SNAPSHOT = 0x2C,

    //INS key
    SK_INSERT = 0x2D,

    //DEL key
    SK_DELETE = 0x2E,

    //HELP key
    SK_HELP = 0x2F,

    //0 key
    SK_0 = 0x30,

    //1 key
    SK_1 = 0x31,

    //2 key
    SK_2 = 0x32,

    //3 key
    SK_3 = 0x33,

    //4 key
    SK_4 = 0x34,

    //5 key
    SK_5 = 0x35,

    //6 key
    SK_6 = 0x36,

    //7 key
    SK_7 = 0x37,

    //8 key
    SK_8 = 0x38,

    //9 key
    SK_9 = 0x39,

    //A key
    SK_A = 0x41,

    //B key
    SK_B = 0x42,

    //C key
    SK_C = 0x43,

    //D key
    SK_D = 0x44,

    //E key
    SK_E = 0x45,

    //F key
    SK_F = 0x46,

    //G key
    SK_G = 0x47,

    //H key
    SK_H = 0x48,

    //I key
    SK_I = 0x49,

    //J key
    SK_J = 0x4A,

    //K key
    SK_K = 0x4B,

    //L key
    SK_L = 0x4C,

    //M key
    SK_M = 0x4D,

    //N key
    SK_N = 0x4E,

    //O key
    SK_O = 0x4F,

    //P key
    SK_P = 0x50,

    //Q key
    SK_Q = 0x51,

    //R key
    SK_R = 0x52,

    //S key
    SK_S = 0x53,

    //T key
    SK_T = 0x54,

    //U key
    SK_U = 0x55,

    //V key
    SK_V = 0x56,

    //W key
    SK_W = 0x57,

    //X key
    SK_X = 0x58,

    //Y key
    SK_Y = 0x59,

    //Z key
    SK_Z = 0x5A,

    //Left Windows key (Natural keyboard)
    SK_LWIN = 0x5B,

    //Right Windows key (Natural keyboard)
    SK_RWIN = 0x5C,

    //Applications key (Natural keyboard)
    SK_APPS = 0x5D,

    //Computer Sleep key
    SK_SLEEP = 0x5F,

    //Numeric keypad 0 key
    SK_NUMPAD0 = 0x60,

    //Numeric keypad 1 key
    SK_NUMPAD1 = 0x61,

    //Numeric keypad 2 key
    SK_NUMPAD2 = 0x62,

    //Numeric keypad 3 key
    SK_NUMPAD3 = 0x63,

    //Numeric keypad 4 key
    SK_NUMPAD4 = 0x64,

    //Numeric keypad 5 key
    SK_NUMPAD5 = 0x65,

    //Numeric keypad 6 key
    SK_NUMPAD6 = 0x66,

    //Numeric keypad 7 key
    SK_NUMPAD7 = 0x67,

    //Numeric keypad 8 key
    SK_NUMPAD8 = 0x68,

    //Numeric keypad 9 key
    SK_NUMPAD9 = 0x69,

    //Multiply key
    SK_MULTIPLY = 0x6A,

    //Add key
    SK_ADD = 0x6B,

    //Separator key
    SK_SEPARATOR = 0x6C,

    //Subtract key
    SK_SUBTRACT = 0x6D,

    //Decimal key
    SK_DECIMAL = 0x6E,

    //Divide key
    SK_DIVIDE = 0x6F,

    //F1 key
    SK_F1 = 0x70,

    //F2 key
    SK_F2 = 0x71,

    //F3 key
    SK_F3 = 0x72,

    //F4 key
    SK_F4 = 0x73,

    //F5 key
    SK_F5 = 0x74,

    //F6 key
    SK_F6 = 0x75,

    //F7 key
    SK_F7 = 0x76,

    //F8 key
    SK_F8 = 0x77,

    //F9 key
    SK_F9 = 0x78,

    //F10 key
    SK_F10 = 0x79,

    //F11 key
    SK_F11 = 0x7A,

    //F12 key
    SK_F12 = 0x7B,

    //F13 key
    SK_F13 = 0x7C,

    //F14 key
    SK_F14 = 0x7D,

    //F15 key
    SK_F15 = 0x7E,

    //F16 key
    SK_F16 = 0x7F,

    //F17 key
    SK_F17 = 0x80,

    //F18 key
    SK_F18 = 0x81,

    //F19 key
    SK_F19 = 0x82,

    //F20 key
    SK_F20 = 0x83,

    //F21 key
    SK_F21 = 0x84,

    //F22 key
    SK_F22 = 0x85,

    //F23 key
    SK_F23 = 0x86,

    //F24 key
    SK_F24 = 0x87,

    //NUM LOCK key
    SK_NUMLOCK = 0x90,

    //SCROLL LOCK key
    SK_SCROLL = 0x91,

    //Left SHIFT key
    SK_LSHIFT = 0xA0,

    //Right SHIFT key
    SK_RSHIFT = 0xA1,

    //Left CONTROL key
    SK_LCONTROL = 0xA2,

    //Right CONTROL key
    SK_RCONTROL = 0xA3,

    //Left MENU key
    SK_LMENU = 0xA4,

    //Right MENU key
    SK_RMENU = 0xA5,

    //Browser Back key
    SK_BROWSER_BACK = 0xA6,

    //Browser Forward key
    SK_BROWSER_FORWARD = 0xA7,

    //Browser Refresh key
    SK_BROWSER_REFRESH = 0xA8,

    //Browser Stop key
    SK_BROWSER_STOP = 0xA9,

    //Browser Search key
    SK_BROWSER_SEARCH = 0xAA,

    //Browser Favorites key
    SK_BROWSER_FAVORITES = 0xAB,

    //Browser Start and Home key
    SK_BROWSER_HOME = 0xAC,

    //Volume Mute key
    SK_VOLUME_MUTE = 0xAD,

    //Volume Down key
    SK_VOLUME_DOWN = 0xAE,

    //Volume Up key
    SK_VOLUME_UP = 0xAF,

    //Next Track key
    SK_MEDIA_NEXT_TRACK = 0xB0,

    //Previous Track key
    SK_MEDIA_PREV_TRACK = 0xB1,

    //Stop Media key
    SK_MEDIA_STOP = 0xB2,

    //Play/Pause Media key
    SK_MEDIA_PLAY_PAUSE = 0xB3,

    //Start Mail key
    SK_LAUNCH_MAIL = 0xB4,

    //Select Media key
    SK_LAUNCH_MEDIA_SELECT = 0xB5,

    //Start Application 1 key
    SK_LAUNCH_APP1 = 0xB6,

    //Start Application 2 key
    SK_LAUNCH_APP2 = 0xB7,

    //Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the ';:' key
    SK_OEM_1 = 0xBA,

    //For any country/region, the '+' key
    SK_PLUS = 0xBB,

    //For any country/region, the ',' key
    SK_COMMA = 0xBC,

    //For any country/region, the '-' key
    SK_MINUS = 0xBD,

    //For any country/region, the '.' key
    SK_PERIOD = 0xBE,

    //Used to pass Unicode characters as if they were keystrokes. The SK_PACKET key is the low word of a 32-bit Virtual Key value used for non-keyboard input methods. For more information, see Remark in KEYBDINPUT, SendInput, WM_KEYDOWN, and WM_KEYUP
    SK_PACKET = 0xE7,

    //Erase EOF key
    SK_EREOF = 0xF9,

    //Play key
    SK_PLAY = 0xFA,

    //Zoom key
    SK_ZOOM = 0xFB,

    //Clear key
    SK_OEM_CLEAR = 0xFE
}

enum KeyboardControlKey
{
    //The CAPS LOCK light is on
    CAPSLOCK = 0x0080

    //The NUM LOCK light is on
    NUMLOCK = 0x0020

    //The SCROLL LOCK light is on
    SCROLLLOCK = 0x0040

    //The SHIFT key is pressed
    SHIFT = 0x0010

    //The key is enhanced
    ENHANCED = 0x0100

    //The left ALT key is pressed
    LEFT_ALT = 0x0002

    //The right ALT key is pressed
    RIGHT_ALT = 0x0001

    //The left CTRL key is pressed
    LEFT_CTRL = 0x0008

    //The right CTRL key is pressed
    RIGHT_CTRL = 0x0004
}
+/
