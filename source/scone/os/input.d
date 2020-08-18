module scone.os.input;

import scone.input.input_event : InputEvent;

interface Input
{
    public void initializeInput();
    public void deinitializeInput();
    public InputEvent[] latestInputEvents();
}
