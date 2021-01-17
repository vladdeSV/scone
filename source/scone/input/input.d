module scone.input.input;

import scone.input.os.standard_input : StandardInput;
import scone.input.keyboard_event : KeyboardEvent;

class Input
{
    this(StandardInput input)
    {
        this.input = input;
        input.initialize();
    }

    ~this()
    {
        this.input.deinitialize();
    }

    KeyboardEvent[] keyboard()
    {
        return this.input.latestKeyboardEvents();
    }

    private StandardInput input;
}

unittest
{
    import scone.core.dummy : DummyInput;
    import scone.input.keyboard_event : KeyboardEvent;
    import scone.input.scone_control_key : SCK;
    import scone.input.scone_key : SK;

    auto stdin = new DummyInput();

    auto input = new Input(stdin);
    assert(input.keyboard() == []);

    stdin.appendDummyKeyboardEvent(KeyboardEvent(SK.a, SCK.none));
    stdin.appendDummyKeyboardEvent(KeyboardEvent(SK.b, SCK.none));
    assert(input.keyboard() == [KeyboardEvent(SK.a, SCK.none), KeyboardEvent(SK.b, SCK.none)]);
    assert(input.keyboard() == []);

    destroy(input);
}
