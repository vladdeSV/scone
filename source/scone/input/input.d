module scone.input.input;

import scone.os.input : OSInput = Input;
import scone.input.input_event : InputEvent;

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

    InputEvent[] latest()
    {
        return this.input.latestInputEvents();
    }
}
