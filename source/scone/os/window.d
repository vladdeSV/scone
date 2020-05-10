module scone.os.window;

import scone.core.types.buffer : Buffer;
import scone.core.types.coordinate : Coordinate;
import scone.core.types.size : Size;
import scone.input.input_event : InputEvent;

interface Window
{
    void initializeOutput();
    void deinitializeOutput();

    void initializeInput();
    void deinitializeInput();

    Size size();
    void size(in Size size);
    void title(in string title);
    void cursorVisible(in bool visible);

    void renderBuffer(Buffer buffer);
    InputEvent[] latestInputEvents();
}