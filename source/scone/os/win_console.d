import scone.window;

import core.sys.windows.windows;
import color;

ushort attributesFromSlot(Cell cell)
{
    ushort attributes;

    switch(cell.foreground)
    {
    case Color.blue:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_BLUE;
        break;
    case Color.blue_dark:
        attributes |= FOREGROUND_BLUE;
        break;
    case Color.cyan:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_GREEN | FOREGROUND_BLUE;
        break;
    case Color.cyan_dark:
        attributes |= FOREGROUND_GREEN | FOREGROUND_BLUE;
        break;
    case Color.white:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
        break;
    case Color.white_dark:
        attributes |= FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
        break;
    case Color.black:
        attributes |= FOREGROUND_INTENSITY;
        break;
    case Color.black_dark:
        attributes |= 0;
        break;
    case Color.green:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_GREEN;
        break;
    case Color.green_dark:
        attributes |= FOREGROUND_GREEN;
        break;
    case Color.magenta:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_BLUE;
        break;
    case Color.magenta_dark:
        attributes |= FOREGROUND_RED | FOREGROUND_BLUE;
        break;
    case Color.red:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED;
        break;
    case Color.red_dark:
        attributes |= FOREGROUND_RED;
        break;
    case Color.yellow:
        attributes |= FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN;
        break;
    case Color.yellow_dark:
        attributes |= FOREGROUND_RED | FOREGROUND_GREEN;
        break;
    default:
        break;
    }

    switch(cell.background)
    {
    case Color.blue:
        attributes |= BACKGROUND_INTENSITY | BACKGROUND_BLUE;
        break;
    case Color.blue_dark:
        attributes |= BACKGROUND_BLUE;
        break;
    case Color.cyan:
        attributes |= BACKGROUND_INTENSITY | BACKGROUND_GREEN | BACKGROUND_BLUE;
        break;
    case Color.cyan_dark:
        attributes |= BACKGROUND_GREEN | BACKGROUND_BLUE;
        break;
    case Color.white:
        attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE;
        break;
    case Color.white_dark:
        attributes |= BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE;
        break;
    case Color.black:
        attributes |= BACKGROUND_INTENSITY;
        break;
    case Color.black_dark:
        attributes |= 0;
        break;
    case Color.green:
        attributes |= BACKGROUND_INTENSITY | BACKGROUND_GREEN;
        break;
    case Color.green_dark:
        attributes |= BACKGROUND_GREEN;
        break;
    case Color.magenta:
        attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_BLUE;
        break;
    case Color.magenta_dark:
        attributes |= BACKGROUND_RED | BACKGROUND_BLUE;
        break;
    case Color.red:
        attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED;
        break;
    case Color.red_dark:
        attributes |= BACKGROUND_RED;
        break;
    case Color.yellow:
        attributes |= BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN;
        break;
    case Color.yellow_dark:
        attributes |= BACKGROUND_RED | BACKGROUND_GREEN;
        break;
    default:
        break;
    }

    return attributes;
}