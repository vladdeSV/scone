module scone.misc.core;

import scone.console.frame;
import scone.misc.utility;
import scone.console.window;
import scone.input.keyboard;
import scone.misc.locale;
import std.experimental.logger;

/**
 * Initializes scone.
 * Must be run only once in order to use scone's features.
 */
auto sconeOpen()
{
    openWindow();
    openKeyboard();
    //openAudio();

    setLocale("en_US");
}

/**
 * Closes scone.
 * Recommended to be run at end of program.
 */
auto sconeClose()
{
    closeWindow();
    closeKeyboard();
    //closeAudio();
}

static FileLogger sconeLog;
