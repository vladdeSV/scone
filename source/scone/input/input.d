module scone.input.input;

import scone.os.window : Window;
import scone.input.input_event : InputEvent;

class Input
{
    private Window window;

    this(Window window)
    {
        this.window = window;
        window.initializeInput();
    }

    InputEvent[] latest()
    {
        return this.window.latestInputEvents();
    }
}
