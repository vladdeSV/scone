module scone.misc.dummy_window;

import scone.core.types.buffer : Buffer;
import scone.core.types.size : Size;
import scone.input.input_event : InputEvent;

class DummyWindow
{
    void initializeOutput()
    {
    }

    void deinitializeOutput()
    {
    }

    void initializeInput()
    {
    }

    void deinitializeInput()
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

    InputEvent[] latestInputEvents()
    {
        return [];
    }
}
