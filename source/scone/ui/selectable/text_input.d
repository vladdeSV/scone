module scone.ui.selectable.text_input;

import std.conv;
import std.uni;
import std.format;
import std.algorithm;
import scone.ui.selectable;
import scone.locale;
import scone.keyboard;

/**
 * Different input types for UITextInput:
 *
 * ascii = Allow all ascii characters.
 * numeric = Allow 0-9.
 * alphabetical = Allow a-z and A-Z
 * password = Displays text with *. "foo" would be displayed as "***".
 *
 * Can be combined: `InputType.numeric | InputType.password`.
 * Note: Only using the password flag will not work.
 */
enum InputType
{
    ascii        = 1,  //00001
    numeric      = 2,  //00010
    alphabetical = 4,  //00100
    password     = 8,  //01000
    //hidden       = 16, //10000
}

/**
 * Text input.
 * Examples:
 * ---
 * auto idInput = new UITextInput("idInput", 1,1, "[id]", InputType.numeric);
 * auto nameInput = new UITextInput("nameInput", 1,2, "[name]", InputType.alphabetical | InputType.numeric);
 * auto passInput = new UITextInput("passInput", 1,3, "[pass]", InputType.alphabetical | InputType.numeric | InputType.password);
 * ---
 *
 * Note: Spaces are always allowed. Make sure to use something like std.string.strip() for actual storage, and sanitize it while you're at it.
 */
class UITextInput : UISelectable
{
    this(string id, int x, int y, string placeholder, InputType type = InputType.ascii, bool active = true)
    {
        //FIXME: placeholder should not be the label
        super(id, x, y, null, active);
        _inputType = type;
        _placeholder = placeholder;
    }


    auto input(ref KeyEvent input)
    {
        if(!input.pressed)
        {
            return;
        }

        if(input.key == SK.left)
        {
            if(_cursorPosition > 0)
            {
                --_cursorPosition;
            }
        }
        else if(input.key == SK.right)
        {
            if(_cursorPosition < _text.length)
            {
                ++_cursorPosition;
            }
        }
        else if(input.key == SK.backspace)
        {
            if(_text.length && _cursorPosition > 0)
            {
                _text = _text[0 .. _cursorPosition - 1] ~ _text[_cursorPosition .. $];
                --_cursorPosition;
            }
        }
        else
        {
            if(text.length < maxLength && keyIsValid(input.key) && inputTypeMatchesKeyEvent(_inputType, input))
            {
                _text =
                    _text[0 .. _cursorPosition]
                    ~ charFromKeyEvent(input)
                    ~_text[_cursorPosition .. $];

                ++_cursorPosition;
            }
        }
    }

    /**
     * Returns: string, of what should be displayed.
     */
    string displayable(bool withCursor = false)
    {
        auto ret = _text.dup;

        //If it's a password, replace all characters with *
        if(hasFlag(_inputType, InputType.password))
        {
            ret[] = '*';
        }

        //If withCursor, add the _caret at the cursor position, else just return the displayable string
        return withCursor ? to!string(ret[0 .. _cursorPosition] ~ _caret ~ ret[_cursorPosition .. $])
                          : to!string(ret);
    }

    /**
     * Returns: InputType.
     */
    auto inputType() @property
    {
        return _inputType;
    }

    /**
     * Set the input type.
     */
    auto inputType(InputType inputType) @property
    {
        return _inputType = inputType;
    }

    /**
     * Returns: string.
     */
    auto placeholder() @property
    {
        return _placeholder;
    }

    /**
     * Set the placeholder.
     */
    auto placeholder(string placeholder) @property
    {
        return _placeholder = placeholder;
    }

    /**
     * Returns: char.
     */
    auto caret() @property
    {
        return _caret;
    }

    /**
     * Set the caret.
     */
    auto caret(char caret) @property
    {
        return _caret = caret;
    }

    /**
     * Returns: uint.
     */
    auto maxLength() @property
    {
        return _maxLength;
    }

    /**
     * Set the max length.
     */
    auto maxLength(uint maxLength) @property
    {
        if(text.length > maxLength)
        {
            text = text[0 .. maxLength];
        }
        return _maxLength = maxLength;
    }

    private InputType _inputType;
    private string _placeholder;
    private char _caret = '_';
    private uint _cursorPosition, _maxLength = 20;
}

bool inputTypeMatchesKeyEvent(InputType type, KeyEvent ke)
{
    if(hasFlag(type, InputType.ascii))
    {
        return true;
    }

    char[2][] checks;

    if(hasFlag(type, InputType.numeric))
    {
        checks ~= ['0', '9'];
    }
    if(hasFlag(type, InputType.alphabetical))
    {
        checks ~= ['a', 'z'];
        checks ~= ['A', 'Z'];
    }

    char c = charFromKeyEvent(ke);
    foreach(ref check; checks)
    {
        if(c >= check[0] && c <= check[1] || c == ' ')
        {
            return true;
        }
    }

    return false;
}

private bool hasFlag(Type)(Type check, Type type)
{
    return ((check & type) == type);
}
