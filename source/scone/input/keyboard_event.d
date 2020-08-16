module scone.input.keyboard_event;

import scone.input.scone_key : SK;
import scone.input.scone_control_key : SCK;
import scone.misc.flags : hasFlag;

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

    /+
    version (Posix)
    {
        /**
         * Get the ASCII-code sequence returned from the keypress on POSIX
         * systems
         * Returns: uint[]
         */
        auto keySequences() @property
        {
            return _keySequences;
        }

        package(scone) uint[] _keySequences;
    }

    version (Windows)
    {
        import core.sys.windows.wincon : INPUT_RECORD;

        /**
         * Get the Windows input record representing the keypress
         * Returns: INPUT_RECORD
         */
        auto inputRecord() @property
        {
            return _inputRecord;
        }

        package(scone) INPUT_RECORD _inputRecord;
    }
    +/
}
