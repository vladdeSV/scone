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

unittest
{
    assert(KeyboardEvent(SK.a, SCK.none, true).key == SK.a);
    assert(KeyboardEvent(SK.a, SCK.ctrl, true).controlKey == SCK.ctrl);
    assert(KeyboardEvent(SK.a, SCK.none, false).pressed == false);

    auto keyboardEvent = KeyboardEvent(SK.a, SCK.ctrl | SCK.alt, true);
    assert(keyboardEvent.hasControlKey(SCK.ctrl));
    assert(keyboardEvent.hasControlKey(SCK.alt));
    assert(!keyboardEvent.hasControlKey(SCK.shift));
}
