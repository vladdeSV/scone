module scone.os.posix.posix_terminal;

import scone.input.input_event : InputEvent;
import scone.input.scone_key : SK;
import scone.input.scone_control_key : SCK;
import scone.os.os_window : OSWindow;
import scone.window.buffer : Buffer;
import scone.window.types.size : Size;

class PosixTerminal : OSWindow
{
    this()
    {

    }

    public void renderBuffer(Buffer buffer)
    {

    }

    public Size windowSize()
    {
        return Size(80, 24);
    }

    public InputEvent[] latestInputEvents()
    {
        return [InputEvent(SK.a, SCK.none, true)];
    }
}
