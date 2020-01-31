module scone.os.os_window;

import scone.window.buffer : Buffer;
import scone.input.input_event : InputEvent;
import scone.window.types.size : Size;

interface OSWindow
{
    public Size windowSize();
    public void clearWindow();

    public void renderBuffer(Buffer buffer);
    public InputEvent[] latestInputEvents();

}
