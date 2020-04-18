module scone.misc.dummy_window;

import scone.frame.buffer : Buffer;
import scone.frame.size : Size;
import scone.input.input_event : InputEvent;
import scone.os.window : Window;

class DummyWindow : Window
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
