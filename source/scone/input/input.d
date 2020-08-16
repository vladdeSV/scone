module scone.input.input;

import scone.os.input : OSInput = Input;
import scone.input.keyboard_event : KeyboardEvent;

class Input
{
    private OSInput input;

    this(OSInput input)
    {
        this.input = input;
        input.initializeInput();
    }

    ~this()
    {
        this.input.deinitializeInput();
    }

    KeyboardEvent[] latest()
    {
        return this.input.latestKeyboardEvents();
    }
}
