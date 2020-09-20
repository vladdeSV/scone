module scone.input.input;

import scone.input.os.standard_input : StandardInput;
import scone.input.keyboard_event : KeyboardEvent;

class Input
{
    private StandardInput input;

    this(StandardInput input)
    {
        this.input = input;
        input.initializeInput();
    }

    ~this()
    {
        this.input.deinitializeInput();
    }

    KeyboardEvent[] keyboard()
    {
        return this.input.latestKeyboardEvents();
    }
}
