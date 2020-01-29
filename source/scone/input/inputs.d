module scone.input.inputs;

import scone.os.os_window : OSWindow;
import scone.input.input_event : InputEvent;

class Inputs
{
    private OSWindow osWindow;

    this(OSWindow osWindow)
    {
        this.osWindow = osWindow;
    }

    InputEvent[] inputs()
    {
        return this.osWindow.latestInputEvents;
    }
}
