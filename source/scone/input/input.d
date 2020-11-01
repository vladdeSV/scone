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

    stdin.appendDummyKeyboardInput(KeyboardEvent(SK.a, SCK.none, true));
    stdin.appendDummyKeyboardInput(KeyboardEvent(SK.b, SCK.none, true));
    assert(input.keyboard() == [KeyboardEvent(SK.a, SCK.none, true), KeyboardEvent(SK.b, SCK.none, true)]);
    assert(input.keyboard() == []);

    destroy(input);
}
