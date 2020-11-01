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
