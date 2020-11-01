module scone.core.dummy;

import scone.output.buffer : Buffer;
import scone.output.types.size : Size;
import scone.input.keyboard_event : KeyboardEvent;
import scone.output.os.standard_output : StandardOutput;
import scone.input.os.standard_input : StandardInput;

class DummyOutput : StandardOutput
{
    void initialize()
    {
    }

    void deinitialize()
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

unittest
{
    auto output = new DummyOutput();
    assert(output.size == Size(80, 24));

    output.size = Size(10, 10);
    assert(output.size == Size(10, 10));
}

class DummyInput : StandardInput
{
    void initialize()
    {
    }

    void deinitialize()
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

unittest
{
    import scone.input.scone_key : SK;
    import scone.input.scone_control_key : SCK;

    auto input = new DummyInput();
    assert(input.latestKeyboardEvents == []);

    input.appendDummyKeyboardInput(KeyboardEvent(SK.a, SCK.none, true));
    input.appendDummyKeyboardInput(KeyboardEvent(SK.b, SCK.none, true));
    assert(input.latestKeyboardEvents == [KeyboardEvent(SK.a, SCK.none, true), KeyboardEvent(SK.b, SCK.none, true)]);
    assert(input.latestKeyboardEvents == []);
}
