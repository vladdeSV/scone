module scone.os;

import scone.input;
import core.thread;
import std.random;
import scone.window : Color;
import scone.input;

version(Windows)
{
    import core.sys.windows.windows;
    import scone.misc.utility : hasFlag;
    import scone.window : Cell;
    import scone.core;
    import std.algorithm : max, min;
    import std.conv : to;
    import std.stdio : stdout;
    import std.string : toStringz;
}

version(Posix)
{
    ///needs to be specifically set, otherwise ioctl crashes D:
    version (OSX) enum TIOCGWINSZ = 0x40087468;

    import core.stdc.stdio;
    import core.sys.posix.fcntl;
    import core.sys.posix.poll;
    import core.sys.posix.sys.ioctl;
    import core.sys.posix.unistd : read;
    import core.sys.posix.unistd : STDOUT_FILENO;
    import std.concurrency : spawn, Tid, thisTid, send, receiveTimeout;
    import std.conv : to, text;
    import std.datetime : Duration, msecs;
    import std.stdio : writef, stdout;

    extern(C)
    {
        import core.sys.posix.termios;
        void cfmakeraw(termios *termios_p);
    }
}

import std.system;
///OS struct name. Called via `mixin(_os~".init();");` //on windows becomes: `Windows.init();`
private enum _os = (os == std.system.OS.win32 || os == std.system.OS.win64) ? "Windows" : "Posix";

///Wrapper for OS specific functions
struct OS
{
    static:

    ///Initializes console/terminal to best settings when using scone
    package(scone)
    auto init()
    {
        mixin(_os~".init();");

        //store original size
        _initialSize = size();
        cursorVisible(false);
    }

    ///De-initializes console/terminal
    package(scone)
    auto deinit()
    {
        mixin(_os~".deinit();");
    }

    ///Get the size of the window
    ///Returns: int[2], where [0] is width, and [1] is height
    auto size()
    {
        mixin("return "~_os~".size();");
    }

    ///Set the size of the window
    auto resize(in size_t width, in size_t height)
    {
        mixin(_os~".resize(width, height);");
    }

    ///Reposition the window, where x=0,y=0 is the top-left corner
    auto reposition(in size_t x, in size_t y)
    {
        mixin(_os~".reposition(x, y);");
    }

    ///Set if the cursor should be visible
    auto cursorVisible(in bool visible) @property
    {
        mixin(_os~".cursorVisible(visible);");
    }

    ///Set the cursor at position
    ///Note: This function should only be called by scone itself
    auto setCursor(in size_t x, in size_t y)
    {
        mixin(_os~".setCursor(x, y);");
    }

    ///Set the title of the window
    auto title(in string title) @property
    {
        mixin(_os~".title(title);");
    }

    private int[2] _initialSize;

    version(Windows)
    static struct Windows
    {
        static:

        package(scone)
        auto init()
        {
            //handle to console window
            _hConsoleOutput = GetStdHandle(STD_OUTPUT_HANDLE);
            //error check
            assert(_hConsoleOutput != INVALID_HANDLE_VALUE, "_hConsoleOutput == INVALID_HANDLE_VALUE");
            //store current screen buffer info
            assert(GetConsoleScreenBufferInfo(_hConsoleOutput, &_consoleScreenBufferInfo), "GetConsoleScreenBufferInfo(_hConsoleOutput, &_consoleScreenBufferInfo)");

            //handle to console input stuff
            _hConsoleInput  = GetStdHandle(STD_INPUT_HANDLE);
            //and error check
            assert(_hConsoleInput != INVALID_HANDLE_VALUE, "_hConsoleInput == INVALID_HANDLE_VALUE");
            //store the old keyboard mode
            assert(GetConsoleMode(_hConsoleInput, &_oldMode), "GetConsoleMode(_hConsoleInput, &_oldMode)");

            //    does the following line even do anything?
            //set new inputmodes
            //assert(SetConsoleMode(_hConsoleInput, _mode), "SetConsoleMode(_hConsoleInput, _mode)");

            //"removes" the enter release key when `dub` is run
            retreiveInputs();
            //sets the cursor invisible
            cursorVisible(false);
        }

        package(scone)
        auto deinit()
        {
            resize(_initialSize[0], _initialSize[1]);

            SetConsoleMode(_hConsoleInput, _oldMode);
            SetConsoleScreenBufferSize(_hConsoleOutput, _consoleScreenBufferInfo.dwSize);

            COORD coordScreen = { 0, 0 };
            DWORD charsWritten;
            DWORD cellCount = _consoleScreenBufferInfo.dwSize.X * _consoleScreenBufferInfo.dwSize.Y;

            FillConsoleOutputCharacter(_hConsoleOutput, cast(TCHAR) ' ', cellCount, coordScreen, &charsWritten);
            FillConsoleOutputAttribute(_hConsoleOutput, _consoleScreenBufferInfo.wAttributes, cellCount, coordScreen, &charsWritten);

            cursorVisible(true);
            setCursor(0,0);
        }

        /* Display cell in console */
        auto writeCell(in size_t x, in size_t y, ref Cell cell)
        {
            ushort wx = to!ushort(x), wy = to!ushort(y);
            COORD charBufSize = {1,1};
            COORD characterPos = {0,0};
            SMALL_RECT writeArea = {wx, wy, wx, wy};
            CHAR_INFO character;
            character.AsciiChar = cell.character;
            character.Attributes = attributesFromCell(cell);
            WriteConsoleOutputA(_hConsoleOutput, &character, charBufSize, characterPos, &writeArea);
        }

        /** Set cursor position. */
        auto setCursor(in size_t x, in size_t y)
        {
            GetConsoleScreenBufferInfo(_hConsoleOutput, &_consoleScreenBufferInfo);
            COORD change =
            {
                cast(short) min(_consoleScreenBufferInfo.srWindow.Right -
                _consoleScreenBufferInfo.srWindow.Left + 1, max(0, x)), cast(short)
                max(0, y)
            };

            stdout.flush();
            SetConsoleCursorPosition(_hConsoleOutput, change);
        }

        /** Set window title */
        auto title(in string title) @property
        {
            SetConsoleTitleA(title.toStringz);
        }

        /** Set cursor visible. */
        auto cursorVisible(in bool visible) @property
        {
            CONSOLE_CURSOR_INFO cci;
            GetConsoleCursorInfo(_hConsoleOutput, &cci);
            cci.bVisible = visible;
            SetConsoleCursorInfo(_hConsoleOutput, &cci);
        }

        /** Set line wrapping. */
        auto lineWrapping(in bool lw) @property
        {
            lw ? SetConsoleMode(_hConsoleOutput, 0x0002)
            : SetConsoleMode(_hConsoleOutput, 0x0);
        }

        void resize(in size_t width, in size_t height)
        {
            SMALL_RECT winInfo = _consoleScreenBufferInfo.srWindow;
            COORD windowSize = {to!short(winInfo.Right - winInfo.Left + 1), to!short(winInfo.Bottom - winInfo.Top + 1)};

            if (windowSize.X > width || windowSize.Y > height)
            {
                //window size needs to be adjusted before the buffer size can be reduced
                SMALL_RECT info =
                {
                    0,
                    0,
                    width <  windowSize.X ? to!short(width-1)  : to!short(windowSize.X-1),
                    height < windowSize.Y ? to!short(height-1) : to!short(windowSize.Y-1)
                };

                assert(SetConsoleWindowInfo(_hConsoleOutput, 1, &info), "Unable to resize window before resizing buffer");
            }

            COORD size = { to!short(width), to!short(height) };
            assert(SetConsoleScreenBufferSize(_hConsoleOutput, size), "Unable to resize screen buffer");

            SMALL_RECT info = { 0, 0, to!short(width - 1), to!short(height - 1) };
            assert(SetConsoleWindowInfo(_hConsoleOutput, 1, &info), "Unable to resize window after resizing buffer");
        }

        auto reposition(in size_t x, in size_t y)
        {
            //todo...
        }

        int[2] size()
        {
            import std.conv : to;

            GetConsoleScreenBufferInfo(_hConsoleOutput, &_consoleScreenBufferInfo);

            return
            [
                to!int(
                    _consoleScreenBufferInfo.srWindow.Right -
                    _consoleScreenBufferInfo.srWindow.Left + 1
                ),
                to!int(
                    _consoleScreenBufferInfo.srWindow.Bottom -
                    _consoleScreenBufferInfo.srWindow.Top  + 1
                )
            ];
        }

        private HANDLE _hConsoleOutput, _hConsoleInput;
        private DWORD _inputsRead, _mode = ENABLE_WINDOW_INPUT | ENABLE_MOUSE_INPUT, _oldMode;
        private INPUT_RECORD[128] _inputBuffer;
        private CONSOLE_SCREEN_BUFFER_INFO _consoleScreenBufferInfo;

        ushort attributesFromCell(Cell cell)
        {
            ushort attributes;

            switch(cell.foreground)
            {
            case Color.blue:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_BLUE;
                break;
            case Color.blue_dark:
                attributes |= FOREGROUND_BLUE;
                break;
            case Color.cyan:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_GREEN | FOREGROUND_BLUE;
                break;
            case Color.cyan_dark:
                attributes |= FOREGROUND_GREEN | FOREGROUND_BLUE;
                break;
            case Color.white:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
                break;
            case Color.white_dark:
                attributes |= FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
                break;
            case Color.black:
                attributes |= FOREGROUND_INTENSITY;
                break;
            case Color.black_dark:
                attributes |= 0;
                break;
            case Color.green:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_GREEN;
                break;
            case Color.green_dark:
                attributes |= FOREGROUND_GREEN;
                break;
            case Color.magenta:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_BLUE;
                break;
            case Color.magenta_dark:
                attributes |= FOREGROUND_RED | FOREGROUND_BLUE;
                break;
            case Color.red:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED;
                break;
            case Color.red_dark:
                attributes |= FOREGROUND_RED;
                break;
            case Color.yellow:
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN;
                break;
            case Color.yellow_dark:
                attributes |= FOREGROUND_RED | FOREGROUND_GREEN;
                break;
            default:
                break;
            }

            switch(cell.background)
            {
            case Color.blue:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_BLUE;
                break;
            case Color.blue_dark:
                attributes |= BACKGROUND_BLUE;
                break;
            case Color.cyan:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_GREEN | BACKGROUND_BLUE;
                break;
            case Color.cyan_dark:
                attributes |= BACKGROUND_GREEN | BACKGROUND_BLUE;
                break;
            case Color.white:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE;
                break;
            case Color.white_dark:
                attributes |= BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE;
                break;
            case Color.black:
                attributes |= BACKGROUND_INTENSITY;
                break;
            case Color.black_dark:
                attributes |= 0;
                break;
            case Color.green:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_GREEN;
                break;
            case Color.green_dark:
                attributes |= BACKGROUND_GREEN;
                break;
            case Color.magenta:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_BLUE;
                break;
            case Color.magenta_dark:
                attributes |= BACKGROUND_RED | BACKGROUND_BLUE;
                break;
            case Color.red:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED;
                break;
            case Color.red_dark:
                attributes |= BACKGROUND_RED;
                break;
            case Color.yellow:
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN;
                break;
            case Color.yellow_dark:
                attributes |= BACKGROUND_RED | BACKGROUND_GREEN;
                break;
            default:
                break;
            }

            return attributes;
        }

        auto retreiveInputs()
        {
            DWORD read = 0;
            GetNumberOfConsoleInputEvents(_hConsoleInput, &read);

            if(!read)
            {
                return null;
            }

            InputEvent[] _inputEvents;

            ReadConsoleInputA(_hConsoleInput, _inputBuffer.ptr, 128, &_inputsRead);
            for(size_t e = 0; e < read; ++e)
            {
                switch(_inputBuffer[e].EventType)
                {
                case KEY_EVENT:
                    _inputEvents ~= InputEvent
                    (
                        getKeyFromKeyEventRecord(_inputBuffer[e].KeyEvent),
                        getControlKeyFromKeyEventRecord(_inputBuffer[e].KeyEvent),
                        cast(bool) _inputBuffer[e].KeyEvent.bKeyDown
                    );

                    break;
                default:
                    break;
                }
            }

            return _inputEvents;
        }

        ///todo: add mouse input
        SK getKeyFromKeyEventRecord(KEY_EVENT_RECORD k)
        {
            switch(k.wVirtualKeyCode)
            {
            case WindowsKeyCode.K_0: return SK.key_0;
            case WindowsKeyCode.K_1: return SK.key_1;
            case WindowsKeyCode.K_2: return SK.key_2;
            case WindowsKeyCode.K_3: return SK.key_3;
            case WindowsKeyCode.K_4: return SK.key_4;
            case WindowsKeyCode.K_5: return SK.key_5;
            case WindowsKeyCode.K_6: return SK.key_6;
            case WindowsKeyCode.K_7: return SK.key_7;
            case WindowsKeyCode.K_8: return SK.key_8;
            case WindowsKeyCode.K_9: return SK.key_9;
            case WindowsKeyCode.K_A: return SK.a;
            case WindowsKeyCode.K_B: return SK.b;
            case WindowsKeyCode.K_C: return SK.c;
            case WindowsKeyCode.K_D: return SK.d;
            case WindowsKeyCode.K_E: return SK.e;
            case WindowsKeyCode.K_F: return SK.f;
            case WindowsKeyCode.K_G: return SK.g;
            case WindowsKeyCode.K_H: return SK.h;
            case WindowsKeyCode.K_I: return SK.i;
            case WindowsKeyCode.K_J: return SK.j;
            case WindowsKeyCode.K_K: return SK.k;
            case WindowsKeyCode.K_L: return SK.l;
            case WindowsKeyCode.K_M: return SK.m;
            case WindowsKeyCode.K_N: return SK.n;
            case WindowsKeyCode.K_O: return SK.o;
            case WindowsKeyCode.K_P: return SK.p;
            case WindowsKeyCode.K_Q: return SK.q;
            case WindowsKeyCode.K_R: return SK.r;
            case WindowsKeyCode.K_S: return SK.s;
            case WindowsKeyCode.K_T: return SK.t;
            case WindowsKeyCode.K_U: return SK.u;
            case WindowsKeyCode.K_V: return SK.v;
            case WindowsKeyCode.K_W: return SK.w;
            case WindowsKeyCode.K_X: return SK.x;
            case WindowsKeyCode.K_Y: return SK.y;
            case WindowsKeyCode.K_Z: return SK.z;
            case VK_F1: return SK.f1;
            case VK_F2: return SK.f2;
            case VK_F3: return SK.f3;
            case VK_F4: return SK.f4;
            case VK_F5: return SK.f5;
            case VK_F6: return SK.f6;
            case VK_F7: return SK.f7;
            case VK_F8: return SK.f8;
            case VK_F9: return SK.f9;
            case VK_F10: return SK.f10;
            case VK_F11: return SK.f11;
            case VK_F12: return SK.f12;
            case VK_F13: return SK.f13;
            case VK_F14: return SK.f14;
            case VK_F15: return SK.f15;
            case VK_F16: return SK.f16;
            case VK_F17: return SK.f17;
            case VK_F18: return SK.f18;
            case VK_F19: return SK.f19;
            case VK_F20: return SK.f20;
            case VK_F21: return SK.f21;
            case VK_F22: return SK.f22;
            case VK_F23: return SK.f23;
            case VK_F24: return SK.f24;
            case VK_NUMPAD0: return SK.numpad_0;
            case VK_NUMPAD1: return SK.numpad_1;
            case VK_NUMPAD2: return SK.numpad_2;
            case VK_NUMPAD3: return SK.numpad_3;
            case VK_NUMPAD4: return SK.numpad_4;
            case VK_NUMPAD5: return SK.numpad_5;
            case VK_NUMPAD6: return SK.numpad_6;
            case VK_NUMPAD7: return SK.numpad_7;
            case VK_NUMPAD8: return SK.numpad_8;
            case VK_NUMPAD9: return SK.numpad_9;
            case VK_BACK: return SK.backspace;
            case VK_TAB: return SK.tab;
            case VK_ESCAPE: return SK.escape;
            case VK_SPACE: return SK.space;
            case VK_PRIOR: return SK.page_up;
            case VK_NEXT: return SK.page_down;
            case VK_END: return SK.end;
            case VK_HOME: return SK.home;
            case VK_LEFT: return SK.left;
            case VK_RIGHT: return SK.right;
            case VK_UP: return SK.up;
            case VK_DOWN: return SK.down;
            case VK_DELETE: return SK.del;
            case VK_SEPARATOR: return SK.enter;
            case VK_ADD: return SK.plus;
            case VK_OEM_PLUS: return SK.plus;
            case VK_SUBTRACT: return SK.minus;
            case VK_OEM_MINUS: return SK.minus;
            case VK_OEM_PERIOD: return SK.period;
            case VK_OEM_COMMA: return SK.comma;
            case VK_DECIMAL: return SK.comma;
            case VK_MULTIPLY: return SK.asterisk;
            case VK_DIVIDE: return SK.divide;
            case VK_OEM_1: return SK.oem_1;
            case VK_OEM_2: return SK.oem_2;
            case VK_OEM_3: return SK.oem_3;
            case VK_OEM_4: return SK.oem_4;
            case VK_OEM_5: return SK.oem_5;
            case VK_OEM_6: return SK.oem_6;
            case VK_OEM_7: return SK.oem_7;
            case VK_OEM_8: return SK.oem_8;
            case VK_OEM_102: return SK.oem_102;
            case VK_RETURN: return SK.enter;

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

            default: return SK.unknown;
            }
        }

        ///key codes
        enum WindowsKeyCode
        {
            ///0 key
            K_0 = 0x30,
            ///1 key
            K_1 = 0x31,
            ///2 key
            K_2 = 0x32,
            ///3 key
            K_3 = 0x33,
            ///4 key
            K_4 = 0x34,
            ///5 key
            K_5 = 0x35,
            ///6 key
            K_6 = 0x36,
            ///7 key
            K_7 = 0x37,
            ///8 key
            K_8 = 0x38,
            ///9 key
            K_9 = 0x39,
            ///A key
            K_A = 0x41,
            ///B key
            K_B = 0x42,
            ///C key
            K_C = 0x43,
            ///D key
            K_D = 0x44,
            ///E key
            K_E = 0x45,
            ///F key
            K_F = 0x46,
            ///G key
            K_G = 0x47,
            ///H key
            K_H = 0x48,
            ///I key
            K_I = 0x49,
            ///J key
            K_J = 0x4A,
            ///K key
            K_K = 0x4B,
            ///L key
            K_L = 0x4C,
            ///M key
            K_M = 0x4D,
            ///N key
            K_N = 0x4E,
            ///O key
            K_O = 0x4F,
            ///P key
            K_P = 0x50,
            ///Q key
            K_Q = 0x51,
            ///R key
            K_R = 0x52,
            ///S key
            K_S = 0x53,
            ///T key
            K_T = 0x54,
            ///U key
            K_U = 0x55,
            ///V key
            K_V = 0x56,
            ///W key
            K_W = 0x57,
            ///X key
            K_X = 0x58,
            ///Y key
            K_Y = 0x59,
            ///Z key
            K_Z = 0x5A,
        }

        SCK getControlKeyFromKeyEventRecord(KEY_EVENT_RECORD k)
        {
            SCK fin;

            auto cm = k.dwControlKeyState;

            if(hasFlag(cm, CAPSLOCK_ON))
            {
                fin |= SCK.capslock;
            }
            if(hasFlag(cm, SCROLLLOCK_ON))
            {
                fin |= SCK.scrolllock;
            }
            if(hasFlag(cm, SHIFT_PRESSED))
            {
                fin |= SCK.shift;
            }
            if(hasFlag(cm, ENHANCED_KEY))
            {
                fin |= SCK.enhanced;
            }
            if(hasFlag(cm, LEFT_ALT_PRESSED))
            {
                fin |= SCK.alt;
            }
            if(hasFlag(cm, RIGHT_ALT_PRESSED))
            {
                fin |= SCK.alt;
            }
            if(hasFlag(cm, LEFT_CTRL_PRESSED))
            {
                fin |= SCK.ctrl;
            }
            if(hasFlag(cm, RIGHT_CTRL_PRESSED))
            {
                fin |= SCK.ctrl;
            }
            if(hasFlag(cm, NUMLOCK_ON))
            {
                fin |= SCK.numlock;
            }

            return fin;
        }
    }

    version(Posix)
    static struct Posix
    {
        static:

        package(scone)
        auto init()
        {
            loadInputSequneces();

            //store the state of the terminal
            tcgetattr(1, &oldState);

            newState = oldState;
            cfmakeraw(&newState);
            tcsetattr(STDOUT_FILENO, TCSADRAIN, &newState);

            //begin polling
            spawn(&pollInputEvent, thisTid);
            stdout.flush();
        }

        package(scone)
        auto deinit()
        {
            tcsetattr(STDOUT_FILENO, TCSADRAIN, &oldState);
            resize(_initialSize[0], _initialSize[1]);
            writef("\033[0m\033[2J\033[H");
            stdout.flush();
            cursorVisible(true);
        }

        auto setCursor(in size_t x, in size_t y)
        {
            writef("\033[%d;%dH", y + 1, x);
            stdout.flush();
        }

        auto cursorVisible(in bool visible) @property
        {
            writef("\033[?25%s", visible ? "h" : "l");
            stdout.flush();
        }

        auto lineWrapping(in bool wrap) @property
        {
            writef("\033[?7%s", wrap ? "h" : "l");
            stdout.flush();
        }

        auto title(in string title) @property
        {
            writef("\033]0;%s\007", title);
            stdout.flush();
        }

        auto size() @property
        {
            winsize w;
            ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
            return [to!int(w.ws_col), to!int(w.ws_row)];
        }

        auto resize(in size_t width, in size_t height)
        {
            writef("\033[8;%s;%st", height, width);
            stdout.flush();
        }

        auto reposition(in size_t x, in size_t y)
        {
            writef("\033[3;%s;%st", x, y);
            stdout.flush();
        }

        ///get ansi color from Color
        auto ansiColor(in Color color)
        {
            //bright color index starts at 90,
            //dark color index starts at 30

            //checks if color is *_dark (value less than 8, check color enum),
            //and sets approproiate starting value. then offsets by the color
            //value. mod 8 is becuase the darker colors range from 8+0 to 8+7
            //and they represent the same color.
            return (color < 8 ? 90 : 30) + (color % 8);
        }

        private void pollInputEvent(Tid parentThreadID)
        {
            Thread.getThis.isDaemon = true;

            while(true)
            {
                pollfd ufds;
                ufds.fd = STDOUT_FILENO;
                ufds.events = POLLIN;

                uint input;
                enum timeout = 500;
                immutable bytesRead = poll(&ufds, 1, timeout);

                if(bytesRead == -1)
                {
                    //logf("(POSIX) ERROR: polling input returned -1");
                }
                else if(bytesRead == 0)
                {
                    //timeout!
                    //if no key was pressed within `timeout`,
                    //this happens. which is good!
                }
                else if(ufds.revents & POLLIN)
                {
                    //read from keyboard
                    read(STDOUT_FILENO, &input, 1);

                    //send ansi to main thread, where it will be handled.
                    send(parentThreadID, input);
                }
            }
        }

        package(scone)
        auto retreiveInputs()
        {
            //this is some spooky hooky code, dealing with
            //multi-thread and reading inputs with timeouts
            //from the terminal. then converting it to something
            //scone can understand.
            //
            //blesh...

            uint[] codes;
            bool receivedInput = true;

            while(receivedInput)
            {
                bool gotSomething = false;

                receiveTimeout
                (
                    1.msecs,
                    (uint code) { codes ~= code; gotSomething = true; },
                );

                if(!gotSomething)
                {
                    receivedInput = false;
                }
            }

            //if no keypresses, return null
            //otherwise, an unknown input will always be sent
            if(codes == null) return null;

            auto event = eventFromSequence(InputSequence(codes));
            event._keySequences = codes;

            return [event];
        }

        private termios oldState, newState;
    }
}
