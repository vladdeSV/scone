module scone.os.windows.input.windows_input;

version (Windows)
{
    import scone.os.input : Input_ = Input;
    import core.sys.windows.windows;
    import scone.core.types.size : Size;
    import scone.input.input : Input;
    import scone.input.input_event : InputEvent;
    import scone.input.scone_control_key : SCK;
    import scone.input.scone_key : SK;
    import scone.misc.flags : hasFlag, withFlag;
    import scone.os.windows.input.key_event_record_converter : KeyEventRecordConverter;
    import std.conv : to;
    import std.experimental.logger;

    class WindowsInput : Input_
    {
        void initializeInput()
        {
            consoleInputHandle = GetStdHandle(STD_INPUT_HANDLE);
            if (consoleInputHandle == INVALID_HANDLE_VALUE)
            {
                //todo
            }
        }

        void deinitializeInput()
        {

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
                    COORD foo = inputRecordBuffer[e].WindowBufferSizeEvent.dwSize;
                    Size newSize = Size(foo.X, foo.Y);
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

        private HANDLE consoleInputHandle;
    }
}
