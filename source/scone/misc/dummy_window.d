module scone.misc.dummy_window;

import scone.core.types.buffer : Buffer;
import scone.core.types.size : Size;
import scone.input.input_event : InputEvent;
import scone.os.output : Output;
import scone.os.input : Input;

class DummyOutput : Output
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

class DummyInput : Input
{
    void initializeInput()
    {
    }

    void deinitializeInput()
    {
    }

    InputEvent[] latestInputEvents()
    {
        return [];
    }
}
