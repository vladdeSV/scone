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
        scope (exit)
        {
            this.latestDummyEvents = [];
        }

        return this.latestDummyEvents;
    }

    void appendDummyKeyboardEvent(KeyboardEvent event)
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

    // dfmt off
    version (Windows)
    {
        input.appendDummyKeyboardEvent(KeyboardEvent(SK.a, SCK.none, true));
        input.appendDummyKeyboardEvent(KeyboardEvent(SK.b, SCK.none, true));
        assert(input.latestKeyboardEvents == [KeyboardEvent(SK.a, SCK.none, true), KeyboardEvent(SK.b, SCK.none, true)]);
        assert(input.latestKeyboardEvents == []);
    }
    else
    {
        input.appendDummyKeyboardEvent(KeyboardEvent(SK.a, SCK.none));
        input.appendDummyKeyboardEvent(KeyboardEvent(SK.b, SCK.none));
        assert(input.latestKeyboardEvents == [KeyboardEvent(SK.a, SCK.none), KeyboardEvent(SK.b, SCK.none)]);
        assert(input.latestKeyboardEvents == []);
    }
    // dfmt on
}
