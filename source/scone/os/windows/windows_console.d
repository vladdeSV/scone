module scone.os.windows.windows_console;

version (Windows)
{
    import core.sys.windows.windows;
    import scone.input.input_event : InputEvent;
    import scone.input.inputs : Inputs;
    import scone.input.scone_control_key : SCK;
    import scone.input.scone_key : SK;
    import scone.misc;
    import scone.os.window : Window;
    import scone.frame.buffer : Buffer;
    import scone.frame.types.cell : Cell;
    import scone.frame.types.color;
    import scone.frame.types.coordinate : Coordinate;
    import scone.frame.types.size : Size;

    class WindowsConsole : Window
    {
        this()
        {
            consoleOutputHandle = GetStdHandle(STD_OUTPUT_HANDLE);
            if (consoleOutputHandle == INVALID_HANDLE_VALUE)
            {
                //todo
            }

            consoleInputHandle = GetStdHandle(STD_INPUT_HANDLE);
            if (consoleInputHandle == INVALID_HANDLE_VALUE)
            {
                //todo
            }
        }

        void renderBuffer(Buffer buffer)
        {
            foreach (Coordinate coordinate; buffer.changedCellCoordinates)
            {
                Cell cell = buffer.cellAt(coordinate);
                this.writeCellAt(cell, coordinate);
            }
        }

        InputEvent[] latestInputEvents()
        {
            INPUT_RECORD[16] inputRecordBuffer;
            DWORD read = 0;
            ReadConsoleInput(consoleInputHandle, inputRecordBuffer.ptr, 16, &read);

            InputEvent[] inputEvents;

            for (size_t e = 0; e < read; ++e)
            {
                switch (inputRecordBuffer[e].EventType)
                {
                default:
                    break;
                case  /* 0x0002 */ MOUSE_EVENT:
                    // mouse has been clicked/moved
                    break;
                case  /* 0x0004 */ WINDOW_BUFFER_SIZE_EVENT:
                    // console has been resized
                    // todo notify scone that the window should be cleared and redrawn
                    break;
                case  /* 0x0001 */ KEY_EVENT:
                    auto foo = new KeyEventRecordConverter(inputRecordBuffer[e].KeyEvent);
                    inputEvents ~= InputEvent(foo.sconeKey, foo.sconeControlKey,
                            cast(bool) inputRecordBuffer[e].KeyEvent.bKeyDown);
                    break;
                }
            }

            return inputEvents;
        }

        Size size()
        {
            CONSOLE_SCREEN_BUFFER_INFO csbi;
            GetConsoleScreenBufferInfo(consoleOutputHandle, &csbi);

            return Size(cast(size_t) csbi.srWindow.Right - csbi.srWindow.Left + 1,
                    cast(size_t) csbi.srWindow.Bottom - csbi.srWindow.Top + 1);
        }

        void clear() {
            // todo
        }

        private void writeCellAt(Cell cell, Coordinate coordinate)
        {
            CHAR_INFO[] charBuffer = [CellConverter.toCharInfo(cell)];
            COORD bufferSize = {1, 1};
            COORD bufferCoord = {0, 0};
            SMALL_RECT writeRegion = {
                cast(SHORT) coordinate.x, cast(SHORT) coordinate.y,
                    cast(SHORT)(coordinate.x + 1), cast(SHORT)(coordinate.y + 1)
            };

            WriteConsoleOutput(consoleOutputHandle, charBuffer.ptr, bufferSize,
                    bufferCoord, &writeRegion);
        }

        //private HANDLE windowHandle;
        private HANDLE consoleOutputHandle;
        private HANDLE consoleInputHandle;
    }

    abstract final class CellConverter
    {
        static CHAR_INFO toCharInfo(Cell cell)
        {
            CHAR_INFO character;
            character.AsciiChar = cell.character;
            character.UnicodeChar = cell.character;
            character.Attributes = typeof(this).attributesFromCell(cell);

            return character;
        }

        private static WORD attributesFromCell(Cell cell)
        {
            WORD attributes;

            switch (cell.foreground)
            {
            case Color.initial:
                // take the inital colors, and filter out all flags except the foreground ones
                //attributes |= (initialColors & (FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE));

                //todo
                attributes = FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
                break;
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
                attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED
                    | FOREGROUND_GREEN | FOREGROUND_BLUE;
                break;
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
            case Color.initial:
                // take the inital colors, and filter out all flags except the background ones
                //attributes |= (initialColors & (BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE));

                //todo
                attributes = 0;
                break;
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
                attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED
                    | BACKGROUND_GREEN | BACKGROUND_BLUE;
                break;
            case Color.whiteDark:
                attributes |= BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE;
                break;
            case Color.black:
                attributes |= BACKGROUND_INTENSITY;
                break;
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
    }

    final class KeyEventRecordConverter
    {
        private KEY_EVENT_RECORD keyEventRecord;

        this(KEY_EVENT_RECORD keyEventRecord)
        {
            this.keyEventRecord = keyEventRecord;
        }

        SK sconeKey()
        {
            switch (this.keyEventRecord.wVirtualKeyCode)
            {
            default:
                return SK.unknown;
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
            }
        }

        SCK sconeControlKey()
        {
            SCK sck;

            DWORD controlKeyState = this.keyEventRecord.dwControlKeyState;

            if (controlKeyState.hasFlag(CAPSLOCK_ON))
            {
                sck = sck.withFlag(SCK.capslock);
            }
            if (controlKeyState.hasFlag(SCROLLLOCK_ON))
            {
                sck = sck.withFlag(SCK.scrolllock);
            }
            if (controlKeyState.hasFlag(SHIFT_PRESSED))
            {
                sck = sck.withFlag(SCK.shift);
            }
            if (controlKeyState.hasFlag(ENHANCED_KEY))
            {
                sck = sck.withFlag(SCK.enhanced);
            }
            if (controlKeyState.hasFlag(LEFT_ALT_PRESSED))
            {
                sck = sck.withFlag(SCK.alt);
            }
            if (controlKeyState.hasFlag(RIGHT_ALT_PRESSED))
            {
                sck = sck.withFlag(SCK.alt);
            }
            if (controlKeyState.hasFlag(LEFT_CTRL_PRESSED))
            {
                sck = sck.withFlag(SCK.ctrl);
            }
            if (controlKeyState.hasFlag(RIGHT_CTRL_PRESSED))
            {
                sck = sck.withFlag(SCK.ctrl);
            }
            if (controlKeyState.hasFlag(NUMLOCK_ON))
            {
                sck = sck.withFlag(SCK.numlock);
            }

            return sck;
        }

        bool pressed()
        {
            cast(bool) keyEventRecord.bKeyDown;
        }

        private enum WindowsKeyCode
        {
            K_0 = 0x30,
            K_1 = 0x31,
            K_2 = 0x32,
            K_3 = 0x33,
            K_4 = 0x34,
            K_5 = 0x35,
            K_6 = 0x36,
            K_7 = 0x37,
            K_8 = 0x38,
            K_9 = 0x39,
            K_A = 0x41,
            K_B = 0x42,
            K_C = 0x43,
            K_D = 0x44,
            K_E = 0x45,
            K_F = 0x46,
            K_G = 0x47,
            K_H = 0x48,
            K_I = 0x49,
            K_J = 0x4A,
            K_K = 0x4B,
            K_L = 0x4C,
            K_M = 0x4D,
            K_N = 0x4E,
            K_O = 0x4F,
            K_P = 0x50,
            K_Q = 0x51,
            K_R = 0x52,
            K_S = 0x53,
            K_T = 0x54,
            K_U = 0x55,
            K_V = 0x56,
            K_W = 0x57,
            K_X = 0x58,
            K_Y = 0x59,
            K_Z = 0x5A,
        }
    }
}
