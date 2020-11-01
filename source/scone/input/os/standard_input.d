module scone.input.os.standard_input;

import scone.input.keyboard_event : KeyboardEvent;

interface StandardInput
{
    public void initialize();
    public void deinitialize();
    public KeyboardEvent[] latestKeyboardEvents();
}
