module scone.os.output;

import scone.core.types.buffer : Buffer;
import scone.core.types.coordinate : Coordinate;
import scone.core.types.size : Size;
import scone.input.keyboard_event : KeyboardEvent;

interface Output
{
    void initializeOutput();
    void deinitializeOutput();

    Size size();
    void size(in Size size);
    void title(in string title);
    void cursorVisible(in bool visible);

    void renderBuffer(Buffer buffer);
}
