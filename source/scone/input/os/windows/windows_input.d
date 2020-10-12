module scone.os.windows.input.windows_input;

version (Windows)
{
    import scone.input.os.standard_input : StandardInput;
    import core.sys.windows.windows;
    import scone.output.types.size : Size;
    import scone.input.input : Input;
    import scone.input.keyboard_event : KeyboardEvent;
    import scone.input.scone_control_key : SCK;
    import scone.input.scone_key : SK;
    import scone.core.flags : hasFlag, withFlag;
    import scone.input.os.windows.input.key_event_record_converter : KeyEventRecordConverter;
    import std.conv : to;
    import std.experimental.logger;

    class WindowsInput : StandardInput
    {
        void initializeInput()
        {
            consoleInputHandle = GetStdHandle(STD_INPUT_HANDLE);
            if (consoleInputHandle == INVALID_HANDLE_VALUE)
            {
                throw new Exception("Cannot initialize input. Got INVALID_HANDLE_VALUE.");
            }
        }

        void deinitializeInput()
        {
        }

        KeyboardEvent[] latestKeyboardEvents()
        {
            INPUT_RECORD[16] inputRecordBuffer;
            DWORD read = 0;
            ReadConsoleInput(consoleInputHandle, inputRecordBuffer.ptr, 16, &read);

            KeyboardEvent[] keyboardEvents;

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
                    /+ console has been resized
                    COORD foo = inputRecordBuffer[e].WindowBufferSizeEvent.dwSize;
                    Size newSize = Size(foo.X, foo.Y);
                    +/
                    break;
                case  /* 0x0001 */ KEY_EVENT:
                    auto foo = new KeyEventRecordConverter(inputRecordBuffer[e].KeyEvent);
                    keyboardEvents ~= KeyboardEvent(foo.sconeKey, foo.sconeControlKey,
                            cast(bool) inputRecordBuffer[e].KeyEvent.bKeyDown);
                    break;
                }
            }

            return keyboardEvents;
        }

        private HANDLE consoleInputHandle;
    }
}
