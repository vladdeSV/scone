module ui.selectable.text_input;

import std.conv;
import std.uni;
import std.format;
import std.algorithm;
import ui.selectable;
import scone.locale;
import scone.keyboard;

enum InputType
{
    // 2^n
    none         = 0,  //00000
    ascii        = 1,  //00001
    numeric      = 2,  //00010
    alphabetical = 4,  //00100
    password     = 8,  //01000
    //hidden       = 16, //10000
}

class UITextInput : UISelectable
{
    private uint _cursorPosition;

    this(string id, int x, int y, string placeholder, InputType type = InputType.ascii, bool active = true)
    {
        //FIXME: placeholder should not be the label
        super(id, x, y, placeholder, active);
        _inputType = type;
        _cursorPosition = _stored.length;
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
            if(_cursorPosition < _stored.length)
            {
                ++_cursorPosition;
            }
        }
        else if(input.key == SK.backspace)
        {
            if(_stored.length && _cursorPosition > 0)
            {
                _stored = _stored[0 .. _cursorPosition - 1] ~ _stored[_cursorPosition .. $];
                --_cursorPosition;
            }
        }
        else
        {
            if(keyIsValid(input.key) && inputTypeMatchesKeyEvent(_inputType, input))
            {
                _stored =
                    _stored[0 .. _cursorPosition]
                    ~ charFromKeyEvent(input)
                    ~_stored[_cursorPosition .. $];

                ++_cursorPosition;
            }
        }
    }

    //TODO: Isn't there a better way to get the content with and without the cursor?
    string content(bool withCursor = false)
    {
        auto ret = _stored;

        //If it's a password, replace all characters with *
        if(hasFlag(_inputType, InputType.password))
        {
            ret[] = '*';
        }

        return withCursor ? to!string(ret[0 .. _cursorPosition] ~ caret ~ ret[_cursorPosition .. $])
                          : to!string(ret);
    }

    private InputType _inputType;
    private char[] _stored;
    public char caret = '_';
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
        if(c >= check[0] && c <= check[1])
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
