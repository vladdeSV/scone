module scone.input.input_event;

import scone.input.scone_key : SK;
import scone.input.scone_control_key : SCK;
import scone.misc.flags : hasFlag;

struct InputEvent
{
    this(SK key, SCK controlKey, bool pressed)
    {
        _key = key;
        _controlKey = controlKey;
        _pressed = pressed;
    }

    auto key() @property
    {
        return _key;
    }

    auto pressed() @property
    {
        return _pressed;
    }

    auto hasControlKey(SCK ck)
    {
        return controlKey.hasFlag(ck);
    }

    auto controlKey() @property
    {
        return _controlKey;
    }

    private SK _key;
    private SCK _controlKey;
    private bool _pressed;

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
