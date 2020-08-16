module scone.input.keyboard;

import scone.os.input : OSInput = Input;
import scone.input.keyboard_event : KeyboardEvent;

class Keyboard
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
