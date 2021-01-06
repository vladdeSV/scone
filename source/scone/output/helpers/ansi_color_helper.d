module scone.output.helpers.ansi_color_helper;

import scone.output.types.color : Color, AnsiColor, ColorState;

enum AnsiColorType
{
    foreground,
    background,
}

auto ansi16ColorNumber(AnsiColor ansi, AnsiColorType type)
{
    int number = 0;

    switch (ansi)
    {
    default:
        assert(0);
    case AnsiColor.initial:
        number = 39;
        break;
    case AnsiColor.black:
        number = 90;
        break;
    case AnsiColor.red:
        number = 91;
        break;
    case AnsiColor.green:
        number = 92;
        break;
    case AnsiColor.yellow:
        number = 93;
        break;
    case AnsiColor.blue:
        number = 94;
        break;
    case AnsiColor.magenta:
        number = 95;
        break;
    case AnsiColor.cyan:
        number = 96;
        break;
    case AnsiColor.white:
        number = 97;
        break;
    case AnsiColor.blackDark:
        number = 30;
        break;
    case AnsiColor.redDark:
        number = 31;
        break;
    case AnsiColor.greenDark:
        number = 32;
        break;
    case AnsiColor.yellowDark:
        number = 33;
        break;
    case AnsiColor.blueDark:
        number = 34;
        break;
    case AnsiColor.magentaDark:
        number = 35;
        break;
    case AnsiColor.cyanDark:
        number = 36;
        break;
    case AnsiColor.whiteDark:
        number = 37;
        break;
    }

    if (type == AnsiColorType.background)
    {
        number += 10;
    }

    return number;
}
///
unittest
{
    assert(ansi16ColorNumber(AnsiColor.initial, AnsiColorType.foreground) == 39);

    assert(ansi16ColorNumber(AnsiColor.blackDark, AnsiColorType.foreground) == 30);
    assert(ansi16ColorNumber(AnsiColor.redDark, AnsiColorType.foreground) == 31);
    assert(ansi16ColorNumber(AnsiColor.greenDark, AnsiColorType.foreground) == 32);
    assert(ansi16ColorNumber(AnsiColor.yellowDark, AnsiColorType.foreground) == 33);
    assert(ansi16ColorNumber(AnsiColor.blueDark, AnsiColorType.foreground) == 34);
    assert(ansi16ColorNumber(AnsiColor.magentaDark, AnsiColorType.foreground) == 35);
    assert(ansi16ColorNumber(AnsiColor.cyanDark, AnsiColorType.foreground) == 36);
    assert(ansi16ColorNumber(AnsiColor.whiteDark, AnsiColorType.foreground) == 37);

    assert(ansi16ColorNumber(AnsiColor.black, AnsiColorType.foreground) == 90);
    assert(ansi16ColorNumber(AnsiColor.red, AnsiColorType.foreground) == 91);
    assert(ansi16ColorNumber(AnsiColor.green, AnsiColorType.foreground) == 92);
    assert(ansi16ColorNumber(AnsiColor.yellow, AnsiColorType.foreground) == 93);
    assert(ansi16ColorNumber(AnsiColor.blue, AnsiColorType.foreground) == 94);
    assert(ansi16ColorNumber(AnsiColor.magenta, AnsiColorType.foreground) == 95);
    assert(ansi16ColorNumber(AnsiColor.cyan, AnsiColorType.foreground) == 96);
    assert(ansi16ColorNumber(AnsiColor.white, AnsiColorType.foreground) == 97);
}
///
unittest
{
    assert(ansi16ColorNumber(AnsiColor.initial, AnsiColorType.background) == 49);

    assert(ansi16ColorNumber(AnsiColor.blackDark, AnsiColorType.background) == 40);
    assert(ansi16ColorNumber(AnsiColor.redDark, AnsiColorType.background) == 41);
    assert(ansi16ColorNumber(AnsiColor.greenDark, AnsiColorType.background) == 42);
    assert(ansi16ColorNumber(AnsiColor.yellowDark, AnsiColorType.background) == 43);
    assert(ansi16ColorNumber(AnsiColor.blueDark, AnsiColorType.background) == 44);
    assert(ansi16ColorNumber(AnsiColor.magentaDark, AnsiColorType.background) == 45);
    assert(ansi16ColorNumber(AnsiColor.cyanDark, AnsiColorType.background) == 46);
    assert(ansi16ColorNumber(AnsiColor.whiteDark, AnsiColorType.background) == 47);

    assert(ansi16ColorNumber(AnsiColor.black, AnsiColorType.background) == 100);
    assert(ansi16ColorNumber(AnsiColor.red, AnsiColorType.background) == 101);
    assert(ansi16ColorNumber(AnsiColor.green, AnsiColorType.background) == 102);
    assert(ansi16ColorNumber(AnsiColor.yellow, AnsiColorType.background) == 103);
    assert(ansi16ColorNumber(AnsiColor.blue, AnsiColorType.background) == 104);
    assert(ansi16ColorNumber(AnsiColor.magenta, AnsiColorType.background) == 105);
    assert(ansi16ColorNumber(AnsiColor.cyan, AnsiColorType.background) == 106);
    assert(ansi16ColorNumber(AnsiColor.white, AnsiColorType.background) == 107);
}

string ansiColorString(Color foreground, Color background)
{
    //dfmt off
    import std.conv : text;

    assert(!foreground.state != ColorState.same);
    assert(!background.state != ColorState.same);

    if (foreground.state == ColorState.ansi && background.state == ColorState.ansi)
    {
        auto foregroundNumber = ansi16ColorNumber(foreground.ansi, AnsiColorType.foreground);
        auto backgroundNumber = ansi16ColorNumber(background.ansi, AnsiColorType.background);
        return text("\033[0;", foregroundNumber, ";", backgroundNumber, "m",);
    }

    string ret;
    if (foreground.state == ColorState.ansi)
    {
        ret ~= text("\033[", ansi16ColorNumber(foreground.ansi, AnsiColorType.foreground), "m");
    }
    else if (foreground.state == ColorState.rgb)
    {
        version(Posix) {
            ret ~= text("\033[38;2;", foreground.rgb.r, ";", foreground.rgb.g, ";", foreground.rgb.b, "m");
        } else {
            // warning: rgb not available on windows
        }
    }

    if (background.state == ColorState.ansi)
    {
        ret ~= text("\033[", ansi16ColorNumber(background.ansi, AnsiColorType.background), "m");
    }
    else if (background.state == ColorState.rgb)
    {
        version(Posix) {
            ret ~= text("\033[48;2;", background.rgb.r, ";", background.rgb.g, ";", background.rgb.b, "m");
        } else {
            // warning: rgb not available on windows
        }
    }

    return ret;
    //dfmt on
}
///
unittest
{
    //dfmt off
    assert(ansiColorString(Color.initial, Color.initial) == "\033[0;39;49m");
    assert(ansiColorString(Color.red, Color.red) == "\033[0;91;101m");
    assert(ansiColorString(Color.red, Color.green) == "\033[0;91;102m");

    version(Posix)
    {
        assert(ansiColorString(Color.red, Color.rgb(10, 20, 30)) == "\033[91m\033[48;2;10;20;30m");
        assert(ansiColorString(Color.rgb(10, 20, 30), Color.green) == "\033[38;2;10;20;30m\033[102m");
        assert(ansiColorString(Color.rgb(10, 20, 30), Color.rgb(40, 50, 60)) == "\033[38;2;10;20;30m\033[48;2;40;50;60m");
    }
    //dfmt on
}
