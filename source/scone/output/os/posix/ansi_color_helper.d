module scone.output.os.posix.ansi_color_helper;

import scone.output.types.color : AnsiColor, ColorState;

enum AnsiColorType
{
    foreground,
    background,
}

auto ansiNumber(AnsiColor ansi, AnsiColorType type)
{
    int number = 0;

    switch (ansi)
    {
    default:
        assert(0);
    case AnsiColor.initial:
        number = 99;
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
    assert(ansiNumber(AnsiColor.initial, AnsiColorType.foreground) == 39);

    assert(ansiNumber(AnsiColor.blackDark, AnsiColorType.foreground) == 30);
    assert(ansiNumber(AnsiColor.redDark, AnsiColorType.foreground) == 31);
    assert(ansiNumber(AnsiColor.greenDark, AnsiColorType.foreground) == 32);
    assert(ansiNumber(AnsiColor.yellowDark, AnsiColorType.foreground) == 33);
    assert(ansiNumber(AnsiColor.blueDark, AnsiColorType.foreground) == 34);
    assert(ansiNumber(AnsiColor.magentaDark, AnsiColorType.foreground) == 35);
    assert(ansiNumber(AnsiColor.cyanDark, AnsiColorType.foreground) == 36);
    assert(ansiNumber(AnsiColor.whiteDark, AnsiColorType.foreground) == 37);

    assert(ansiNumber(AnsiColor.black, AnsiColorType.foreground) == 90);
    assert(ansiNumber(AnsiColor.red, AnsiColorType.foreground) == 91);
    assert(ansiNumber(AnsiColor.green, AnsiColorType.foreground) == 92);
    assert(ansiNumber(AnsiColor.yellow, AnsiColorType.foreground) == 93);
    assert(ansiNumber(AnsiColor.blue, AnsiColorType.foreground) == 94);
    assert(ansiNumber(AnsiColor.magenta, AnsiColorType.foreground) == 95);
    assert(ansiNumber(AnsiColor.cyan, AnsiColorType.foreground) == 96);
    assert(ansiNumber(AnsiColor.white, AnsiColorType.foreground) == 97);
}
///
unittest
{
    assert(ansiNumber(AnsiColor.initial, AnsiColorType.background) == 49);

    assert(ansiNumber(AnsiColor.blackDark, AnsiColorType.background) == 40);
    assert(ansiNumber(AnsiColor.redDark, AnsiColorType.background) == 41);
    assert(ansiNumber(AnsiColor.greenDark, AnsiColorType.background) == 42);
    assert(ansiNumber(AnsiColor.yellowDark, AnsiColorType.background) == 43);
    assert(ansiNumber(AnsiColor.blueDark, AnsiColorType.background) == 44);
    assert(ansiNumber(AnsiColor.magentaDark, AnsiColorType.background) == 45);
    assert(ansiNumber(AnsiColor.cyanDark, AnsiColorType.background) == 46);
    assert(ansiNumber(AnsiColor.whiteDark, AnsiColorType.background) == 47);

    assert(ansiNumber(AnsiColor.black, AnsiColorType.background) == 100);
    assert(ansiNumber(AnsiColor.red, AnsiColorType.background) == 101);
    assert(ansiNumber(AnsiColor.green, AnsiColorType.background) == 102);
    assert(ansiNumber(AnsiColor.yellow, AnsiColorType.background) == 103);
    assert(ansiNumber(AnsiColor.blue, AnsiColorType.background) == 104);
    assert(ansiNumber(AnsiColor.magenta, AnsiColorType.background) == 105);
    assert(ansiNumber(AnsiColor.cyan, AnsiColorType.background) == 106);
    assert(ansiNumber(AnsiColor.white, AnsiColorType.background) == 107);
}
