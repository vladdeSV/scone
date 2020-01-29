module scone.os.os_window;

import scone.window.buffer : Buffer;
import scone.input.input_event : InputEvent;
import scone.window.types.size : Size;

interface OSWindow
{
    public void renderBuffer(Buffer buffer);
    public Size windowSize();
    public InputEvent[] latestInputEvents();
}
