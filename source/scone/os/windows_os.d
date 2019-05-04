module scone.os.windows_os;
version (Windows):

import scone.os : OS;
import scone.misc.utility : hasFlag;
import scone.window : Cell;
import scone.input : SK, SCK, InputEvent;
import scone.core;
import scone.color : Color;
import core.sys.windows.windows;
import std.algorithm : max, min;
import std.conv : to;
import std.stdio : stdout;
import std.string : toStringz;

extern (Windows)
{
    BOOL GetCurrentConsoleFont(HANDLE hConsoleOutput, BOOL bMaximumWindow, PCONSOLE_FONT_INFO lpConsoleCurrentFont);
    COORD GetConsoleFontSize(HANDLE hConsoleOutput, DWORD nFont);
}

abstract class WindowsOS : OS
{
    static:

    package(scone) auto init()
    {
        _initialSize = size();
        cursorVisible(false);

        // handle to console window
        consoleHandle = GetConsoleWindow();
        assert(consoleHandle != INVALID_HANDLE_VALUE, "Could not get console window handle: ERROR " ~ to!string(GetLastError()));

        // handle to console output stuff
        consoleOutputHandle = GetStdHandle(STD_OUTPUT_HANDLE);

        // error check
        assert(consoleOutputHandle != INVALID_HANDLE_VALUE, "Could not get standard output handle: ERROR " ~ to!string(GetLastError()));

        // store current screen buffer info
        assert(GetConsoleScreenBufferInfo(consoleOutputHandle, &consoleScreenBufferInfo), "Could not get console screen buffer info: ERROR " ~ to!string(GetLastError()));

        // handle to console input stuff
        consoleInputHandle = GetStdHandle(STD_INPUT_HANDLE);
        // and error check
        assert(consoleInputHandle != INVALID_HANDLE_VALUE, "Could not get standard window input handle: ERROR " ~ to!string(GetLastError()));

        // store the old keyboard mode
        assert(GetConsoleMode(consoleInputHandle, &oldConsoleMode), "Could not get console window mode: ERROR " ~ to!string(GetLastError()));
        // set new inputmodes
        assert(SetConsoleMode(consoleInputHandle, consoleMode), "Could not set console window mode: ERROR " ~ to!string(GetLastError()));

        //"removes" the enter release key when `dub` is run
        retreiveInputs();
        // sets the cursor invisible
        cursorVisible(false);
    }

    package(scone) auto deinit()
    {
        resize(_initialSize[0], _initialSize[1]);

        SetConsoleMode(consoleInputHandle, oldConsoleMode);
        SetConsoleScreenBufferSize(consoleOutputHandle, consoleScreenBufferInfo.dwSize);

        COORD coordScreen = {0, 0};
        DWORD charsWritten;
        DWORD cellCount = consoleScreenBufferInfo.dwSize.X * consoleScreenBufferInfo.dwSize.Y;

        FillConsoleOutputCharacter(consoleOutputHandle, cast(TCHAR) ' ', cellCount, coordScreen, &charsWritten);
        FillConsoleOutputAttribute(consoleOutputHandle, consoleScreenBufferInfo.wAttributes, cellCount, coordScreen, &charsWritten);

        cursorVisible(true);
        setCursor(0, 0);
    }

    /* Display cell in console */
    auto writeCell(in uint x, in uint y, ref Cell cell)
    {
        immutable(ushort) wx = to!ushort(x);
        immutable(ushort) wy = to!ushort(y);
        COORD charBufSize = {1, 1};
        COORD characterPos = {0, 0};
        SMALL_RECT writeArea = {wx, wy, wx, wy};
        CHAR_INFO character;
        character.AsciiChar = cell.character;
        character.Attributes = attributesFromCell(cell);
        WriteConsoleOutputA(consoleOutputHandle, &character, charBufSize, characterPos, &writeArea);
    }

    auto setCursor(in uint x, in uint y)
    {
        GetConsoleScreenBufferInfo(consoleOutputHandle, &consoleScreenBufferInfo);
        COORD change = {cast(short) min(consoleScreenBufferInfo.srWindow.Right - consoleScreenBufferInfo.srWindow.Left + 1, max(0, x)), cast(short) max(0, y)};

        stdout.flush();
        SetConsoleCursorPosition(consoleOutputHandle, change);
    }

    auto title(in string title)
    {
        SetConsoleTitleA(title.toStringz);
    }

    auto cursorVisible(in bool visible)
    {
        CONSOLE_CURSOR_INFO cci;
        GetConsoleCursorInfo(consoleOutputHandle, &cci);
        cci.bVisible = visible;
        SetConsoleCursorInfo(consoleOutputHandle, &cci);
    }

    auto lineWrapping(in bool lw)
    {
        lw ? SetConsoleMode(consoleOutputHandle, 0x0002) : SetConsoleMode(consoleOutputHandle, 0x0);
    }

    void resize(in uint width, in uint height)
    {
        // here comes a workaround of windows stange behaviour (in my honest opinion)
        // it sets the WINDOW size to 1x1, then sets the BUFFER size (crashes if window size is larger than buffer size), finally setting the correct window size

        CONSOLE_FONT_INFO consoleFontInfo;
        GetCurrentConsoleFont(consoleOutputHandle, FALSE, &consoleFontInfo);
        immutable COORD fontSize = GetConsoleFontSize(consoleOutputHandle, consoleFontInfo.nFont);
        immutable consoleMinimumPixelWidth = GetSystemMetrics(SM_CXMIN);
        immutable consoleMinimumPixelHeight = GetSystemMetrics(SM_CYMIN);

        if (width * fontSize.X < consoleMinimumPixelWidth || height * fontSize.Y < consoleMinimumPixelHeight)
        {
            // log(warn, tried to set the window size smaller than allowed. ignored resize)
            return;
        }

        // set window size to 1x1
        SMALL_RECT onebyone = {0, 0, 1, 1};
        assert(SetConsoleWindowInfo(consoleOutputHandle, 1, &onebyone), "1. Unable to resize window to 1x1: ERROR " ~ to!string(GetLastError()));

        // set the buffer size to desired size
        COORD size = {to!short(width), to!short(height)};
        assert(SetConsoleScreenBufferSize(consoleOutputHandle, size), "2. Unable to resize screen buffer: ERROR " ~ to!string(GetLastError()));

        // resize back the window to correct size
        SMALL_RECT info = {0, 0, to!short(width - 1), to!short(height - 1)};
        assert(SetConsoleWindowInfo(consoleOutputHandle, 1, &info), "3. Unable to resize window the second time: ERROR " ~ to!string(GetLastError()));
    }

    auto reposition(int x, int y)
    {
        SetWindowPos(consoleHandle, cast(void*) 0, x, y, 0, 0, SWP_NOZORDER | SWP_NOSIZE);
    }

    uint[2] size()
    {
        GetConsoleScreenBufferInfo(consoleOutputHandle, &consoleScreenBufferInfo);

        return [consoleScreenBufferInfo.srWindow.Right - consoleScreenBufferInfo.srWindow.Left + 1, consoleScreenBufferInfo.srWindow.Bottom - consoleScreenBufferInfo.srWindow.Top + 1];
    }

    auto retreiveInputs()
    {
        DWORD read = 0;
        GetNumberOfConsoleInputEvents(consoleInputHandle, &read);

        if (!read)
        {
            return null;
        }

        InputEvent[] _inputEvents;

        ReadConsoleInputA(consoleInputHandle, inputRecordBuffer.ptr, 128, &_inputsRead);
        for (uint e = 0; e < read; ++e)
        {
            switch (inputRecordBuffer[e].EventType)
            {
            case  /* 0x0002 */ MOUSE_EVENT:
                // this means the mouse has been clicked/moved
            case  /* 0x0004 */ WINDOW_BUFFER_SIZE_EVENT:
                // this means the window console has been resized
                // TODO: This is where we want to notify scone that the window should be cleared and redrawn
            case  /* 0x0008 */ MENU_EVENT:
                // this means the user has clicked on the menu (should be ignored according to microsoft)
            case  /* 0x0010 */ FOCUS_EVENT:
                // this means the user has switched focus of the window (should be ignored according to microsoft)
                break;
            case  /* 0x0001 */ KEY_EVENT:
                _inputEvents ~= InputEvent(
                    getKeyFromKeyEventRecord(inputRecordBuffer[e].KeyEvent),
                    getControlKeyFromKeyEventRecord(inputRecordBuffer[e].KeyEvent),
                    cast(bool) inputRecordBuffer[e].KeyEvent.bKeyDown
                );
                break;
            default:
                break;
            }
        }

        return _inputEvents;
    }

    ushort attributesFromCell(Cell cell)
    {
        ushort attributes;

        switch (cell.foreground)
        {
        case Color.blue:
            attributes |= FOREGROUND_INTENSITY | FOREGROUND_BLUE;
            break;
        case Color.blueDark:
            attributes |= FOREGROUND_BLUE;
            break;
        case Color.cyan:
            attributes |= FOREGROUND_INTENSITY | FOREGROUND_GREEN | FOREGROUND_BLUE;
            break;
        case Color.cyanDark:
            attributes |= FOREGROUND_GREEN | FOREGROUND_BLUE;
            break;
        case Color.white:
            attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
            break;
        case Color.initial:
        case Color.whiteDark:
            attributes |= FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
            break;
        case Color.black:
            attributes |= FOREGROUND_INTENSITY;
            break;
        case Color.blackDark:
            attributes |= 0;
            break;
        case Color.green:
            attributes |= FOREGROUND_INTENSITY | FOREGROUND_GREEN;
            break;
        case Color.greenDark:
            attributes |= FOREGROUND_GREEN;
            break;
        case Color.magenta:
            attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_BLUE;
            break;
        case Color.magentaDark:
            attributes |= FOREGROUND_RED | FOREGROUND_BLUE;
            break;
        case Color.red:
            attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED;
            break;
        case Color.redDark:
            attributes |= FOREGROUND_RED;
            break;
        case Color.yellow:
            attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN;
            break;
        case Color.yellowDark:
            attributes |= FOREGROUND_RED | FOREGROUND_GREEN;
            break;
        default:
            break;
        }

        switch (cell.background)
        {
        case Color.blue:
            attributes |= BACKGROUND_INTENSITY | BACKGROUND_BLUE;
            break;
        case Color.blueDark:
            attributes |= BACKGROUND_BLUE;
            break;
        case Color.cyan:
            attributes |= BACKGROUND_INTENSITY | BACKGROUND_GREEN | BACKGROUND_BLUE;
            break;
        case Color.cyanDark:
            attributes |= BACKGROUND_GREEN | BACKGROUND_BLUE;
            break;
        case Color.white:
            attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE;
            break;
        case Color.whiteDark:
            attributes |= BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE;
            break;
        case Color.black:
            attributes |= BACKGROUND_INTENSITY;
            break;
        case Color.initial:
        case Color.blackDark:
            attributes |= 0;
            break;
        case Color.green:
            attributes |= BACKGROUND_INTENSITY | BACKGROUND_GREEN;
            break;
        case Color.greenDark:
            attributes |= BACKGROUND_GREEN;
            break;
        case Color.magenta:
            attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_BLUE;
            break;
        case Color.magentaDark:
            attributes |= BACKGROUND_RED | BACKGROUND_BLUE;
            break;
        case Color.red:
            attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED;
            break;
        case Color.redDark:
            attributes |= BACKGROUND_RED;
            break;
        case Color.yellow:
            attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN;
            break;
        case Color.yellowDark:
            attributes |= BACKGROUND_RED | BACKGROUND_GREEN;
            break;
        default:
            break;
        }

        return attributes;
    }

    SK getKeyFromKeyEventRecord(KEY_EVENT_RECORD k)
    {
        switch (k.wVirtualKeyCode)
        {
        case WindowsKeyCode.K_0:
            return SK.key_0;
        case WindowsKeyCode.K_1:
            return SK.key_1;
        case WindowsKeyCode.K_2:
            return SK.key_2;
        case WindowsKeyCode.K_3:
            return SK.key_3;
        case WindowsKeyCode.K_4:
            return SK.key_4;
        case WindowsKeyCode.K_5:
            return SK.key_5;
        case WindowsKeyCode.K_6:
            return SK.key_6;
        case WindowsKeyCode.K_7:
            return SK.key_7;
        case WindowsKeyCode.K_8:
            return SK.key_8;
        case WindowsKeyCode.K_9:
            return SK.key_9;
        case WindowsKeyCode.K_A:
            return SK.a;
        case WindowsKeyCode.K_B:
            return SK.b;
        case WindowsKeyCode.K_C:
            return SK.c;
        case WindowsKeyCode.K_D:
            return SK.d;
        case WindowsKeyCode.K_E:
            return SK.e;
        case WindowsKeyCode.K_F:
            return SK.f;
        case WindowsKeyCode.K_G:
            return SK.g;
        case WindowsKeyCode.K_H:
            return SK.h;
        case WindowsKeyCode.K_I:
            return SK.i;
        case WindowsKeyCode.K_J:
            return SK.j;
        case WindowsKeyCode.K_K:
            return SK.k;
        case WindowsKeyCode.K_L:
            return SK.l;
        case WindowsKeyCode.K_M:
            return SK.m;
        case WindowsKeyCode.K_N:
            return SK.n;
        case WindowsKeyCode.K_O:
            return SK.o;
        case WindowsKeyCode.K_P:
            return SK.p;
        case WindowsKeyCode.K_Q:
            return SK.q;
        case WindowsKeyCode.K_R:
            return SK.r;
        case WindowsKeyCode.K_S:
            return SK.s;
        case WindowsKeyCode.K_T:
            return SK.t;
        case WindowsKeyCode.K_U:
            return SK.u;
        case WindowsKeyCode.K_V:
            return SK.v;
        case WindowsKeyCode.K_W:
            return SK.w;
        case WindowsKeyCode.K_X:
            return SK.x;
        case WindowsKeyCode.K_Y:
            return SK.y;
        case WindowsKeyCode.K_Z:
            return SK.z;
        case VK_F1:
            return SK.f1;
        case VK_F2:
            return SK.f2;
        case VK_F3:
            return SK.f3;
        case VK_F4:
            return SK.f4;
        case VK_F5:
            return SK.f5;
        case VK_F6:
            return SK.f6;
        case VK_F7:
            return SK.f7;
        case VK_F8:
            return SK.f8;
        case VK_F9:
            return SK.f9;
        case VK_F10:
            return SK.f10;
        case VK_F11:
            return SK.f11;
        case VK_F12:
            return SK.f12;
        case VK_F13:
            return SK.f13;
        case VK_F14:
            return SK.f14;
        case VK_F15:
            return SK.f15;
        case VK_F16:
            return SK.f16;
        case VK_F17:
            return SK.f17;
        case VK_F18:
            return SK.f18;
        case VK_F19:
            return SK.f19;
        case VK_F20:
            return SK.f20;
        case VK_F21:
            return SK.f21;
        case VK_F22:
            return SK.f22;
        case VK_F23:
            return SK.f23;
        case VK_F24:
            return SK.f24;
        case VK_NUMPAD0:
            return SK.numpad_0;
        case VK_NUMPAD1:
            return SK.numpad_1;
        case VK_NUMPAD2:
            return SK.numpad_2;
        case VK_NUMPAD3:
            return SK.numpad_3;
        case VK_NUMPAD4:
            return SK.numpad_4;
        case VK_NUMPAD5:
            return SK.numpad_5;
        case VK_NUMPAD6:
            return SK.numpad_6;
        case VK_NUMPAD7:
            return SK.numpad_7;
        case VK_NUMPAD8:
            return SK.numpad_8;
        case VK_NUMPAD9:
            return SK.numpad_9;
        case VK_BACK:
            return SK.backspace;
        case VK_TAB:
            return SK.tab;
        case VK_ESCAPE:
            return SK.escape;
        case VK_SPACE:
            return SK.space;
        case VK_PRIOR:
            return SK.page_up;
        case VK_NEXT:
            return SK.page_down;
        case VK_END:
            return SK.end;
        case VK_HOME:
            return SK.home;
        case VK_LEFT:
            return SK.left;
        case VK_RIGHT:
            return SK.right;
        case VK_UP:
            return SK.up;
        case VK_DOWN:
            return SK.down;
        case VK_DELETE:
            return SK.del;
        case VK_SEPARATOR:
            return SK.enter;
        case VK_ADD:
            return SK.plus;
        case VK_OEM_PLUS:
            return SK.plus;
        case VK_SUBTRACT:
            return SK.minus;
        case VK_OEM_MINUS:
            return SK.minus;
        case VK_OEM_PERIOD:
            return SK.period;
        case VK_OEM_COMMA:
            return SK.comma;
        case VK_DECIMAL:
            return SK.comma;
        case VK_MULTIPLY:
            return SK.asterisk;
        case VK_DIVIDE:
            return SK.divide;
        case VK_OEM_1:
            return SK.oem_1;
        case VK_OEM_2:
            return SK.oem_2;
        case VK_OEM_3:
            return SK.oem_3;
        case VK_OEM_4:
            return SK.oem_4;
        case VK_OEM_5:
            return SK.oem_5;
        case VK_OEM_6:
            return SK.oem_6;
        case VK_OEM_7:
            return SK.oem_7;
        case VK_OEM_8:
            return SK.oem_8;
        case VK_OEM_102:
            return SK.oem_102;
        case VK_RETURN:
            return SK.enter;

            /+
        case VK_CLEAR: return SK.clear;
        case VK_SHIFT: return SK.shift;
        case VK_CONTROL: return SK.control;
        case VK_MENU: return SK.alt;
        case VK_CAPITAL: return SK.capslock;
        case VK_SELECT: return SK.select;
        case VK_PRINT: return SK.print;
        case VK_EXECUTE: return SK.execute;
        case VK_SNAPSHOT: return SK.print_screen;
        case VK_INSERT: return SK.insert;
        case VK_HELP: return SK.help;
        case VK_LWIN: return SK.windows_left;
        case VK_RWIN: return SK.windows_right;
        case VK_APPS: return SK.apps;
        case VK_SLEEP: return SK.sleep;
        case VK_NUMLOCK: return SK.numlock;
        case VK_SCROLL: return SK.scroll_lock;
        case VK_LSHIFT: return SK.shift_left;
        case VK_RSHIFT: return SK.shift_right;
        case VK_LCONTROL: return SK.control_left;
        case VK_RCONTROL: return SK.control_right;
        case VK_LMENU: return SK.menu_left;
        case VK_RMENU: return SK.menu_right;
        case VK_BROWSER_BACK: return SK.browser_back;
        case VK_BROWSER_FORWARD: return SK.browser_forward;
        case VK_BROWSER_REFRESH: return SK.browser_refresh;
        case VK_BROWSER_STOP: return SK.browser_stop;
        case VK_BROWSER_SEARCH: return SK.browser_search;
        case VK_BROWSER_FAVORITES: return SK.browser_favorites;
        case VK_BROWSER_HOME: return SK.browser_home;
        case VK_VOLUME_MUTE: return SK.volume_mute;
        case VK_VOLUME_DOWN: return SK.volume_down;
        case VK_VOLUME_UP: return SK.volume_up;
        case VK_MEDIA_NEXT_TRACK: return SK.media_next;
        case VK_MEDIA_PREV_TRACK: return SK.media_prev;
        case VK_MEDIA_STOP: return SK.media_stop;
        case VK_MEDIA_PLAY_PAUSE: return SK.media_play_pause;
        case VK_LAUNCH_MAIL: return SK.launch_mail;
        case VK_LAUNCH_MEDIA_SELECT: return SK.launch_media_select;
        case VK_LAUNCH_APP1: return SK.launch_app_1;
        case VK_LAUNCH_APP2: return SK.launch_app_2;case VK_PACKET: return SK.packet;
        case VK_ATTN: return SK.attn;
        case VK_CRSEL: return SK.crsel;
        case VK_EXSEL: return SK.exsel;
        case VK_EREOF: return SK.ereof;
        case VK_PLAY: return SK.play;
        case VK_ZOOM: return SK.zoom;
        case VK_OEM_CLEAR: return SK.oem_clear;
        case VK_PAUSE: return SK.pause;
        case VK_CANCEL: return SK.cancel;
        +/

        default:
            return SK.unknown;
        }
    }

    SCK getControlKeyFromKeyEventRecord(KEY_EVENT_RECORD k)
    {
        SCK fin;

        auto cm = k.dwControlKeyState;

        if (hasFlag(cm, CAPSLOCK_ON))
        {
            fin |= SCK.capslock;
        }
        if (hasFlag(cm, SCROLLLOCK_ON))
        {
            fin |= SCK.scrolllock;
        }
        if (hasFlag(cm, SHIFT_PRESSED))
        {
            fin |= SCK.shift;
        }
        if (hasFlag(cm, ENHANCED_KEY))
        {
            fin |= SCK.enhanced;
        }
        if (hasFlag(cm, LEFT_ALT_PRESSED))
        {
            fin |= SCK.alt;
        }
        if (hasFlag(cm, RIGHT_ALT_PRESSED))
        {
            fin |= SCK.alt;
        }
        if (hasFlag(cm, LEFT_CTRL_PRESSED))
        {
            fin |= SCK.ctrl;
        }
        if (hasFlag(cm, RIGHT_CTRL_PRESSED))
        {
            fin |= SCK.ctrl;
        }
        if (hasFlag(cm, NUMLOCK_ON))
        {
            fin |= SCK.numlock;
        }

        return fin;
    }
 
    /// Specific key codes for (practically) ASCII
    /// Authors note: I believe all these can be found in the Dlang source code, however, they are here because they didn't exist in an ealier verison of Dlang.
    private enum WindowsKeyCode
    {
        /// 0 key
        K_0 = 0x30,
        /// 1 key
        K_1 = 0x31,
        /// 2 key
        K_2 = 0x32,
        /// 3 key
        K_3 = 0x33,
        /// 4 key
        K_4 = 0x34,
        /// 5 key
        K_5 = 0x35,
        /// 6 key
        K_6 = 0x36,
        /// 7 key
        K_7 = 0x37,
        /// 8 key
        K_8 = 0x38,
        /// 9 key
        K_9 = 0x39,
        /// A key
        K_A = 0x41,
        /// B key
        K_B = 0x42,
        /// C key
        K_C = 0x43,
        /// D key
        K_D = 0x44,
        /// E key
        K_E = 0x45,
        /// F key
        K_F = 0x46,
        /// G key
        K_G = 0x47,
        /// H key
        K_H = 0x48,
        /// I key
        K_I = 0x49,
        /// J key
        K_J = 0x4A,
        /// K key
        K_K = 0x4B,
        /// L key
        K_L = 0x4C,
        /// M key
        K_M = 0x4D,
        /// N key
        K_N = 0x4E,
        /// O key
        K_O = 0x4F,
        /// P key
        K_P = 0x50,
        /// Q key
        K_Q = 0x51,
        /// R key
        K_R = 0x52,
        /// S key
        K_S = 0x53,
        /// T key
        K_T = 0x54,
        /// U key
        K_U = 0x55,
        /// V key
        K_V = 0x56,
        /// W key
        K_W = 0x57,
        /// X key
        K_X = 0x58,
        /// Y key
        K_Y = 0x59,
        /// Z key
        K_Z = 0x5A,
    }

    private HANDLE consoleHandle, consoleOutputHandle, consoleInputHandle;
    private DWORD _inputsRead, consoleMode = ENABLE_WINDOW_INPUT | ENABLE_MOUSE_INPUT, oldConsoleMode;
    private INPUT_RECORD[128] inputRecordBuffer;
    private CONSOLE_SCREEN_BUFFER_INFO consoleScreenBufferInfo;
    private uint[2] _initialSize;
}
