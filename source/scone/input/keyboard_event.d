module scone.input.keyboard_event;

import scone.input.scone_key : SK;
import scone.input.scone_control_key : SCK;
import scone.core.flags : hasFlag;

struct KeyboardEvent
{
    this(SK key, SCK controlKey, bool pressed)
    {
        this.key = key;
        this.controlKey = controlKey;
        this.pressed = pressed;
    }

    auto hasControlKey(SCK ck)
    {
        return controlKey.hasFlag(ck);
    }

    public SK key;
    public SCK controlKey;
    public bool pressed;
}
