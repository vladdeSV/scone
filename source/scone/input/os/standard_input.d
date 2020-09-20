module scone.os.standard_input;

import scone.input.keyboard_event : KeyboardEvent;

interface StandardInput
{
    public void initializeInput();
    public void deinitializeInput();
    public KeyboardEvent[] latestKeyboardEvents();
}
