module scone.input.keyboard;

import scone.os.input : Input;
import scone.input.keyboard_event : KeyboardEvent;

class Keyboard
{
    private Input input;

    this(Input input)
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
