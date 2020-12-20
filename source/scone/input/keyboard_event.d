module scone.input.keyboard_event;

import scone.input.scone_key : SK;
import scone.input.scone_control_key : SCK;
import scone.core.flags : hasFlag;

struct KeyboardEvent
{
    auto hasControlKey(SCK ck)
    {
        return controlKey.hasFlag(ck);
    }

    public SK key;
    public SCK controlKey;
    version (Windows) public bool pressed = true;
}

unittest
{
    assert(KeyboardEvent(SK.a, SCK.none).key == SK.a);
    assert(KeyboardEvent(SK.a, SCK.ctrl).controlKey == SCK.ctrl);

    version (Windows)
    {
        assert(KeyboardEvent(SK.a, SCK.none, false).pressed == false);
        assert(KeyboardEvent(SK.a, SCK.none, true).pressed == true);
    }

    auto keyboardEvent = KeyboardEvent(SK.a, SCK.ctrl | SCK.alt);
    assert(keyboardEvent.hasControlKey(SCK.ctrl));
    assert(keyboardEvent.hasControlKey(SCK.alt));
    assert(!keyboardEvent.hasControlKey(SCK.shift));
}
