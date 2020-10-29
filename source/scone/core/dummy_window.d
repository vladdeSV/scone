module scone.core.dummy_window;

import scone.output.types.buffer : Buffer;
import scone.output.types.size : Size;
import scone.input.keyboard_event : KeyboardEvent;
import scone.output.os.standard_output : StandardOutput;
import scone.input.os.standard_input : StandardInput;

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
        return this.currentSize;
    }

    void size(in Size size)
    {
        this.currentSize = size;
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

    private Size currentSize = Size(80, 24);
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
        scope(exit)
        {
            this.latestDummyEvents = [];
        }

        return this.latestDummyEvents;
    }

    void appendDummyKeyboardInput(KeyboardEvent event)
    {
        this.latestDummyEvents ~= event;
    }

    private KeyboardEvent[] latestDummyEvents;
}
