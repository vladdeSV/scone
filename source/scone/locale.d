module scone.locale;

import std.csv;
import std.conv;
import std.typecons;
import std.file;

import scone.keyboard;

private char[2][SK] _locale;

void setLocale(string locale)
{
    _locale = null;

    string s = readText("locale/" ~ locale ~ ".locale");
    foreach(record; csvReader!(Tuple!(string, ubyte, ubyte))(s, '\t', char.init))
    {
        SK key = to!SK(record[0]);
        _locale[key] = [char(record[1]), char(record[2])];
    }

    _locale.rehash();
}

bool keyIsValid(SK key)
{
    return (key in _locale) !is null;
}

char charFromKeyEvent(KeyEvent ke)
{
    bool switched = ke.hasControlKey(SCK.shift) && !ke.hasControlKey(SCK.capslock) || ke.hasControlKey(SCK.capslock) && !ke.hasControlKey(SCK.shift);
    return !switched ? _locale[ke.key][0]
                     : _locale[ke.key][1];
}
