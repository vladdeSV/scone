module scone.os.posix_os;
version (Posix):

import scone.color;
import scone.input;
import scone.os;

/// needs to be specifically set, otherwise ioctl crashes D:
version (OSX) { enum TIOCGWINSZ = 0x40087468; }

import core.stdc.stdio;
import core.sys.posix.fcntl;
import core.sys.posix.poll;
import core.sys.posix.sys.ioctl;
import core.sys.posix.unistd : read;
import core.sys.posix.unistd : STDOUT_FILENO;
import core.thread : Thread;
import std.concurrency : spawn, Tid, thisTid, send, receiveTimeout, ownerTid;
import std.conv : to, text;
import std.datetime : Duration, msecs;
import std.stdio : writef, stdout;

extern (C)
{
    import core.sys.posix.termios;

    void cfmakeraw(termios* termios_p);
}

abstract class PosixOS : OS
{
static:

    package(scone) auto init()
    {
        _initialSize = size();
        cursorVisible(false);

        loadInputSequneces();

        // store the state of the terminal
        tcgetattr(1, &oldState);

        newState = oldState;
        cfmakeraw(&newState);
        tcsetattr(STDOUT_FILENO, TCSADRAIN, &newState);

        // begin polling
        spawn(&pollInputEvent);
        stdout.flush();
    }

    package(scone) auto deinit()
    {
        tcsetattr(STDOUT_FILENO, TCSADRAIN, &oldState);
        resize(_initialSize[0], _initialSize[1]);
        writef("\033[0m\033[2J\033[H");
        stdout.flush();
        cursorVisible(true);
        setCursor(0, 0);
    }

    auto setCursor(in uint x, in uint y)
    {
        writef("\033[%d;%dH", y + 1, x);
        stdout.flush();
    }

    auto cursorVisible(in bool visible)
    {
        writef("\033[?25%s", visible ? "h" : "l");
        stdout.flush();
    }

    auto lineWrapping(in bool wrap)
    {
        writef("\033[?7%s", wrap ? "h" : "l");
        stdout.flush();
    }

    auto title(in string title)
    {
        writef("\033]0;%s\007", title);
        stdout.flush();
    }

    auto size()
    {
        winsize w;
        ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
        return [to!uint(w.ws_col), to!uint(w.ws_row)];
    }

    auto resize(in uint width, in uint height)
    {
        writef("\033[8;%s;%st", height, width);
        stdout.flush();
    }

    auto reposition(in uint x, in uint y)
    {
        writef("\033[3;%s;%st", x, y);
        stdout.flush();
    }

    /// ANSI color code from enum Color
    auto ansiColor(in Color color)
    {
        if(color == Color.initial)
        {
            return 39;
        }

        // Authors note, May 10th 2018:
        // legit, what is this even?
        //
        // On a more serious note, I believe 90 and 30 are switched on OSX (macOS).
        // Meaning, on OSX light colors begin at 90, while in Ubunut they begin at 30.
        // todo: above --------------------------^

        // bright color index starts at 90 (90 = light black, 91 = light red, etc...)
        // dark color index starts at 30 (30 = dark black, 31 = drak red, etc...)
        //
        // checks if color is *Dark (value less than 8, check color enum),
        // and sets approproiate starting value. then offsets by the color
        // value. mod 8 is becuase the darker colors range from 8+0 to 8+7
        // and they represent the same color.

        return (color < 8 ? 90 : 30) + (color % 8);
    }

    package(scone) auto retreiveInputs()
    {
        // this is some spooky hooky code, dealing with
        // multi-thread and reading inputs with timeouts
        // from the terminal. then converting it to something
        // scone can understand.
        //
        // blesh...

        uint[] codes;

        while (true)
        {
            bool receivedSequence = false;

            receiveTimeout(1.msecs, (uint code) { codes ~= code; receivedSequence = true; },);

            if (!receivedSequence)
            {
                break;
            }
        }

        // if no keypresses, return null
        // otherwise, an unknown input will always be sent
        if (codes == null)
        {
            return null;
        }

        auto events = eventsFromSequence(codes);
        return events;
    }

    /// This method is run on a separate thread, meaning it can block
    private void pollInputEvent()
    {
        /*
         * Basically, a daemon thread doesn't need to finish in order for scone to exit.
         * This means we can have an endless loop here without worrying the program won't exit properly
         */
        Thread.getThis.isDaemon = true;

        // This loop polls input, and sends them to the main thread
        while (true)
        {
            pollfd ufds;
            ufds.fd = STDOUT_FILENO;
            ufds.events = POLLIN;

            uint input;
            immutable bytesRead = poll(&ufds, 1, -1);

            if (bytesRead == -1)
            {
                // error :(
                // logf("(POSIX) ERROR: polling input returned -1");
            }
            else if (bytesRead == 0)
            {
                // If no key was pressed within `timeout`
            }
            else if (ufds.revents & POLLIN)
            {
                // Read input from keyboard
                read(STDOUT_FILENO, &input, 1);

                // Send key code to main thread (where it will be handled).
                send(ownerTid, input);
            }
        }
    }

    private termios oldState, newState;
    private uint[2] _initialSize;
}
