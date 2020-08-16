module scone.os.input;

import scone.input.keyboard_event : KeyboardEvent;

interface Input
{
    public void initializeInput();
    public void deinitializeInput();
    public KeyboardEvent[] latestKeyboardEvents();
}
