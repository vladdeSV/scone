version(Windows):

enum WindowsVirtualKey
{

    //Left mouse button
    VK_LBUTTON = 0x01,

    //Right mouse button
    VK_RBUTTON = 0x02,

    //Control-break processing
    VK_CANCEL = 0x03,

    //Middle mouse button (three-button mouse)
    VK_MBUTTON = 0x04,

    //X1 mouse button
    VK_XBUTTON1 = 0x05,

    //X2 mouse button
    VK_XBUTTON2 = 0x06,

    //BACKSPACE key
    VK_BACK = 0x08,

    //TAB key
    VK_TAB = 0x09,

    //CLEAR key
    VK_CLEAR = 0x0C,

    //ENTER key
    VK_RETURN = 0x0D,

    //SHIFT key
    VK_SHIFT = 0x10,

    //CTRL key
    VK_CONTROL = 0x11,

    //ALT key
    VK_MENU = 0x12,

    //PAUSE key
    VK_PAUSE = 0x13,

    //CAPS LOCK key
    VK_CAPITAL = 0x14,

    //IME Kana mode
    VK_KANA = 0x15,

    //IME Hanguel mode (maintained for compatibility; use VK_HANGUL)
    VK_HANGUEL = 0x15,

    //IME Hangul mode
    VK_HANGUL = 0x15,

    //IME Junja mode
    VK_JUNJA = 0x17,

    //IME final mode
    VK_FINAL = 0x18,

    //IME Hanja mode
    VK_HANJA = 0x19,

    //IME Kanji mode
    VK_KANJI = 0x19,

    //ESC key
    VK_ESCAPE = 0x1B,

    //IME convert
    VK_CONVERT = 0x1C,

    //IME nonconvert
    VK_NONCONVERT = 0x1D,

    //IME accept
    VK_ACCEPT = 0x1E,

    //IME mode change request
    VK_MODECHANGE = 0x1F,

    //SPACEBAR
    VK_SPACE = 0x20,

    //PAGE UP key
    VK_PRIOR = 0x21,

    //PAGE DOWN key
    VK_NEXT = 0x22,

    //END key
    VK_END = 0x23,

    //HOME key
    VK_HOME = 0x24,

    //LEFT ARROW key
    VK_LEFT = 0x25,

    //UP ARROW key
    VK_UP = 0x26,

    //RIGHT ARROW key
    VK_RIGHT = 0x27,

    //DOWN ARROW key
    VK_DOWN = 0x28,

    //SELECT key
    VK_SELECT = 0x29,

    //PRINT key
    VK_PRINT = 0x2A,

    //EXECUTE key
    VK_EXECUTE = 0x2B,

    //PRINT SCREEN key
    VK_SNAPSHOT = 0x2C,

    //INS key
    VK_INSERT = 0x2D,

    //DEL key
    VK_DELETE = 0x2E,

    //HELP key
    VK_HELP = 0x2F,

    //0 key
    K_0 = 0x30,

    //1 key
    K_1 = 0x31,

    //2 key
    K_2 = 0x32,

    //3 key
    K_3 = 0x33,

    //4 key
    K_4 = 0x34,

    //5 key
    K_5 = 0x35,

    //6 key
    K_6 = 0x36,

    //7 key
    K_7 = 0x37,

    //8 key
    K_8 = 0x38,

    //9 key
    K_9 = 0x39,

    //A key
    K_A = 0x41,

    //B key
    K_B = 0x42,

    //C key
    K_C = 0x43,

    //D key
    K_D = 0x44,

    //E key
    K_E = 0x45,

    //F key
    K_F = 0x46,

    //G key
    K_G = 0x47,

    //H key
    K_H = 0x48,

    //I key
    K_I = 0x49,

    //J key
    K_J = 0x4A,

    //K key
    K_K = 0x4B,

    //L key
    K_L = 0x4C,

    //M key
    K_M = 0x4D,

    //N key
    K_N = 0x4E,

    //O key
    K_O = 0x4F,

    //P key
    K_P = 0x50,

    //Q key
    K_Q = 0x51,

    //R key
    K_R = 0x52,

    //S key
    K_S = 0x53,

    //T key
    K_T = 0x54,

    //U key
    K_U = 0x55,

    //V key
    K_V = 0x56,

    //W key
    K_W = 0x57,

    //X key
    K_X = 0x58,

    //Y key
    K_Y = 0x59,

    //Z key
    K_Z = 0x5A,

    //Left Windows key (Natural keyboard)
    VK_LWIN = 0x5B,

    //Right Windows key (Natural keyboard)
    VK_RWIN = 0x5C,

    //Applications key (Natural keyboard)
    VK_APPS = 0x5D,

    //Computer Sleep key
    VK_SLEEP = 0x5F,

    //Numeric keypad 0 key
    VK_NUMPAD0 = 0x60,

    //Numeric keypad 1 key
    VK_NUMPAD1 = 0x61,

    //Numeric keypad 2 key
    VK_NUMPAD2 = 0x62,

    //Numeric keypad 3 key
    VK_NUMPAD3 = 0x63,

    //Numeric keypad 4 key
    VK_NUMPAD4 = 0x64,

    //Numeric keypad 5 key
    VK_NUMPAD5 = 0x65,

    //Numeric keypad 6 key
    VK_NUMPAD6 = 0x66,

    //Numeric keypad 7 key
    VK_NUMPAD7 = 0x67,

    //Numeric keypad 8 key
    VK_NUMPAD8 = 0x68,

    //Numeric keypad 9 key
    VK_NUMPAD9 = 0x69,

    //Multiply key
    VK_MULTIPLY = 0x6A,

    //Add key
    VK_ADD = 0x6B,

    //Separator key
    VK_SEPARATOR = 0x6C,

    //Subtract key
    VK_SUBTRACT = 0x6D,

    //Decimal key
    VK_DECIMAL = 0x6E,

    //Divide key
    VK_DIVIDE = 0x6F,

    //F1 key
    VK_F1 = 0x70,

    //F2 key
    VK_F2 = 0x71,

    //F3 key
    VK_F3 = 0x72,

    //F4 key
    VK_F4 = 0x73,

    //F5 key
    VK_F5 = 0x74,

    //F6 key
    VK_F6 = 0x75,

    //F7 key
    VK_F7 = 0x76,

    //F8 key
    VK_F8 = 0x77,

    //F9 key
    VK_F9 = 0x78,

    //F10 key
    VK_F10 = 0x79,

    //F11 key
    VK_F11 = 0x7A,

    //F12 key
    VK_F12 = 0x7B,

    //F13 key
    VK_F13 = 0x7C,

    //F14 key
    VK_F14 = 0x7D,

    //F15 key
    VK_F15 = 0x7E,

    //F16 key
    VK_F16 = 0x7F,

    //F17 key
    VK_F17 = 0x80,

    //F18 key
    VK_F18 = 0x81,

    //F19 key
    VK_F19 = 0x82,

    //F20 key
    VK_F20 = 0x83,

    //F21 key
    VK_F21 = 0x84,

    //F22 key
    VK_F22 = 0x85,

    //F23 key
    VK_F23 = 0x86,

    //F24 key
    VK_F24 = 0x87,

    //NUM LOCK key
    VK_NUMLOCK = 0x90,

    //SCROLL LOCK key
    VK_SCROLL = 0x91,
    //Left SHIFT key
    VK_LSHIFT = 0xA0,

    //Right SHIFT key
    VK_RSHIFT = 0xA1,
    //Left CONTROL key
    VK_LCONTROL = 0xA2,

    //Right CONTROL key
    VK_RCONTROL = 0xA3,

    //Left MENU key
    VK_LMENU = 0xA4,

    //Right MENU key
    VK_RMENU = 0xA5,

    //Browser Back key
    VK_BROWSER_BACK = 0xA6,

    //Browser Forward key
    VK_BROWSER_FORWARD = 0xA7,

    //Browser Refresh key
    VK_BROWSER_REFRESH = 0xA8,

    //Browser Stop key
    VK_BROWSER_STOP = 0xA9,

    //Browser Search key
    VK_BROWSER_SEARCH = 0xAA,

    //Browser Favorites key
    VK_BROWSER_FAVORITES = 0xAB,

    //Browser Start and Home key
    VK_BROWSER_HOME = 0xAC,

    //Volume Mute key
    VK_VOLUME_MUTE = 0xAD,

    //Volume Down key
    VK_VOLUME_DOWN = 0xAE,

    //Volume Up key
    VK_VOLUME_UP = 0xAF,

    //Next Track key
    VK_MEDIA_NEXT_TRACK = 0xB0,

    //Previous Track key
    VK_MEDIA_PREV_TRACK = 0xB1,

    //Stop Media key
    VK_MEDIA_STOP = 0xB2,

    //Play/Pause Media key
    VK_MEDIA_PLAY_PAUSE = 0xB3,

    //Start Mail key
    VK_LAUNCH_MAIL = 0xB4,

    //Select Media key
    VK_LAUNCH_MEDIA_SELECT = 0xB5,

    //Start Application 1 key
    VK_LAUNCH_APP1 = 0xB6,

    //Start Application 2 key
    VK_LAUNCH_APP2 = 0xB7,

    //Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the ';:' key
    VK_OEM_1 = 0xBA,

    //For any country/region, the '+' key
    VK_OEM_PLUS = 0xBB,

    //For any country/region, the ',' key
    VK_OEM_COMMA = 0xBC,

    //For any country/region, the '-' key
    VK_OEM_MINUS = 0xBD,

    //For any country/region, the '.' key
    VK_OEM_PERIOD = 0xBE,

    //Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the '/?' key
    VK_OEM_2 = 0xBF,

    //Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the '`~' key
    VK_OEM_3 = 0xC0,

    //Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the '[{' key
    VK_OEM_4 = 0xDB,

    //Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the '\\|' key
    VK_OEM_5 = 0xDC,

    //Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the ']}' key
    VK_OEM_6 = 0xDD,

    //Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the 'single-quote/double-quote' key
    VK_OEM_7 = 0xDE,

    //Used for miscellaneous characters; it can vary by keyboard.
    VK_OEM_8 = 0xDF,

    //Either the angle bracket key or the backslash key on the RT 102-key keyboard
    VK_OEM_102 = 0xE2,

    //IME PROCESS key
    VK_PROCESSKEY = 0xE5,

    //Used to pass Unicode characters as if they were keystrokes. The VK_PACKET key is the low word of a 32-bit Virtual Key value used for non-keyboard input methods. For more information, see Remark in KEYBDINPUT, SendInput, WM_KEYDOWN, and WM_KEYUP
    VK_PACKET = 0xE7,

    //Attn key
    VK_ATTN = 0xF6,

    //CrSel key
    VK_CRSEL = 0xF7,

    //ExSel key
    VK_EXSEL = 0xF8,

    //Erase EOF key
    VK_EREOF = 0xF9,

    //Play key
    VK_PLAY = 0xFA,

    //Zoom key
    VK_ZOOM = 0xFB,

    //PA1 key
    VK_PA1 = 0xFD,

    //Clear key
    VK_OEM_CLEAR = 0xFE
}

enum WindowsControlKey
{
    //The CAPS LOCK light is on
    CAPSLOCK_ON = 0x0080

    //The NUM LOCK light is on
    NUMLOCK_ON = 0x0020

    //The SCROLL LOCK light is on
    SCROLLLOCK_ON = 0x0040

    //The SHIFT key is pressed
    SHIFT_PRESSED = 0x0010

    //The key is enhanced
    ENHANCED_KEY = 0x0100

    //The left ALT key is pressed
    LEFT_ALT_PRESSED = 0x0002

    //The right ALT key is pressed
    RIGHT_ALT_PRESSED = 0x0001

    //The left CTRL key is pressed
    LEFT_CTRL_PRESSED = 0x0008

    //The right CTRL key is pressed
    RIGHT_CTRL_PRESSED = 0x0004
}
