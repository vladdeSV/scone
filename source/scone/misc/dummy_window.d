module scone.misc.dummy_window;

import scone.core.types.buffer : Buffer;
import scone.core.types.size : Size;
import scone.input.keyboard_event : KeyboardEvent;
import scone.os.standard_output : StandardOutput;
import scone.os.standard_input : StandardInput;

class DummyOutput : StandardOutput
{
    void initializeOutput()
    {
    }   

    void deinitializeOutput()
    {
    }

    Size size()
    {
        return Size(80, 24);
    }

    void size(in Size size)
    {
    }

    void title(in string title)
    {
    }

    void cursorVisible(in bool visible)
    {
    }

    void renderBuffer(Buffer buffer)
    {
    }
}

class DummyInput : StandardInput
{
    void initializeInput()
    {
    }

    void deinitializeInput()
    {
    }

    KeyboardEvent[] latestKeyboardEvents()
    {
        return [];
    }
}
