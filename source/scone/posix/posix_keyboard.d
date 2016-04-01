module scone.posix.posix_keyboard;

version(Posix):
package(scone):

import scone.keyboard;
import scone.utility : hasFlag;
import scone.core;

auto posix_initKeyboard()
{
    {
        import core.stdc.stdlib : getenv;
        import core.stdc.string : strcmp;
        auto tt = getenv("TERM");
        if (tt)
        {
            if (strcmp(tt, "rxvt") == 0) termType = TermType.rxvt;
            else if (strcmp(tt, "xterm") == 0) termType = TermType.xterm;
        }
    }
    import core.sys.posix.unistd : isatty, STDIN_FILENO, STDOUT_FILENO;
    import core.sys.posix.termios : tcgetattr;
    xlock = new XLock;
    if (isatty(STDIN_FILENO) && isatty(STDOUT_FILENO))
    {
        if (tcgetattr(STDIN_FILENO, &origMode) == 0)
        {
            redirected = false;
        }
    }
    initKeyTrans();
}

auto posix_exitKeyboard()
{
    ttySetNormal();
    if (xlock)
    {
        delete xlock;
        xlock = null;
    }
}

auto posix_getInput()
{

}

private:
KeyEvent[] _ke;

import core.sys.posix.termios : termios;
public import std.typecons : Flag, Yes, No;


private __gshared termios origMode;
private __gshared bool inRawMode = false;
private __gshared bool redirected = true; // can be used without synchronization

private class XLock {}
private shared XLock xlock;

version (OSX) enum TIOCGWINSZ = 0x40087468;

/// TTY mode
enum TTYMode
{
    BAD = -1, /// some error occured
    NORMAL, /// normal ('cooked') mode
    RAW /// 'raw' mode
}

enum TermType
{
    other,
    rxvt,
    xterm
}

__gshared TermType termType = TermType.other;


/// is TTY stdin or stdout redirected?
@property bool ttyIsRedirected () @trusted nothrow @nogc
{
    return redirected;
}


/// get current TTY mode
TTYMode ttyGetMode () @trusted nothrow @nogc
{
    return (inRawMode ? TTYMode.RAW : TTYMode.NORMAL);
}


/// returns previous mode or BAD
TTYMode ttySetNormal () @trusted @nogc
{
    synchronized(xlock)
    {
        if (inRawMode)
        {
            import core.sys.posix.termios : tcflush, tcsetattr;
            import core.sys.posix.termios : TCIOFLUSH, TCSAFLUSH;
            import core.sys.posix.unistd : STDIN_FILENO;
            tcflush(STDIN_FILENO, TCIOFLUSH);
            if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &origMode) < 0)
            {
                return TTYMode.BAD;
            }
            inRawMode = false;
            return TTYMode.RAW;
        }
        return TTYMode.NORMAL;
    }
}


/// returns previous mode or BAD
TTYMode ttySetRaw (Flag!"waitkey" waitKey=Yes.waitkey) @trusted @nogc
{
    if (redirected)
    {
        return TTYMode.BAD;
    }
    synchronized(xlock)
    {
        if (!inRawMode)
        {
            import core.sys.posix.termios : tcflush, tcsetattr;
            import core.sys.posix.termios : TCIOFLUSH, TCSAFLUSH;
            import core.sys.posix.termios : BRKINT, CS8, ECHO, ICANON, IEXTEN, INPCK, ISIG, ISTRIP, IXON, ONLCR, OPOST, VMIN, VTIME;
            import core.sys.posix.unistd : STDIN_FILENO;
            termios raw = origMode; // modify the original mode
            tcflush(STDIN_FILENO, TCIOFLUSH);
            // input modes: no break, no CR to NL, no parity check, no strip char, no start/stop output control
            //raw.c_iflag &= ~(BRKINT|ICRNL|INPCK|ISTRIP|IXON);
            // input modes: no break, no parity check, no strip char, no start/stop output control
            raw.c_iflag &= ~(BRKINT|INPCK|ISTRIP|IXON);
            // output modes: disable post processing
            raw.c_oflag &= ~OPOST;
            raw.c_oflag |= ONLCR;
            raw.c_oflag = OPOST|ONLCR;
            // control modes: set 8 bit chars
            raw.c_cflag |= CS8;
            // local modes: echoing off, canonical off, no extended functions, no signal chars (^Z,^C)
            raw.c_lflag &= ~(ECHO|ICANON|IEXTEN|ISIG);
            // control chars: set return condition: min number of bytes and timer; we want read to return every single byte, without timeout
            raw.c_cc[VMIN] = (waitKey ? 1 : 0); // wait/poll mode
            raw.c_cc[VTIME] = 0; // no timer
            // put terminal in raw mode after flushing
            if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw) < 0)
            {
                return TTYMode.BAD;
            }
            inRawMode = true;
            return TTYMode.NORMAL;
        }
        return TTYMode.RAW;
    }
}


/// set wait/poll mode
bool ttySetWaitKey (bool doWait) @trusted @nogc
{
    if (redirected)
    {
        return false;
    }
    synchronized(xlock)
    {
        if (inRawMode)
        {
            import core.sys.posix.termios : tcflush, tcgetattr, tcsetattr;
            import core.sys.posix.termios : TCIOFLUSH, TCSAFLUSH;
            import core.sys.posix.termios : VMIN;
            import core.sys.posix.unistd : STDIN_FILENO;
            termios raw;
            tcflush(STDIN_FILENO, TCIOFLUSH);
            if (tcgetattr(STDIN_FILENO, &raw) == 0)
            {
                redirected = false;
            }
            raw.c_cc[VMIN] = (doWait ? 1 : 0); // wait/poll mode
            if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw) < 0)
            {
                return false;
            }
            return true;
        }
    }
    return false;
}


/// change TTY mode if possible
/// returns previous mode or BAD
TTYMode ttySetMode (TTYMode mode) @trusted @nogc
{
    // check what we can without locking
    if (mode == TTYMode.BAD)
    {
        return TTYMode.BAD;
    }
    if (redirected)
    {
        return (mode == TTYMode.NORMAL ? TTYMode.NORMAL : TTYMode.BAD);
    }
    synchronized(xlock)
    {
        return (mode == TTYMode.NORMAL ? ttySetNormal() : ttySetRaw());
    }
}


/// return TTY width
@property int ttyWidth () @trusted nothrow @nogc
{
    if (!redirected)
    {
        import core.sys.posix.sys.ioctl : ioctl, winsize;
        winsize sz = void;
        if (ioctl(1, TIOCGWINSZ, &sz) != -1)
        {
            return sz.ws_col;
        }
    }
    return 80;
}


/// return TTY height
@property int ttyHeight () @trusted nothrow @nogc
{
    if (!redirected)
    {
        import core.sys.posix.sys.ioctl : ioctl, winsize;
        winsize sz = void;
        if (ioctl(1, TIOCGWINSZ, &sz) != -1)
        {
            return sz.ws_row;
        }
        return sz.ws_row;
    }
    return 25;
}


/**
 * Wait for keypress.
 *
 * Params:
 *    toMSec = timeout in milliseconds; < 0: infinite; 0: don't wait; default is -1
 *
 * Returns:
 *    true if key was pressed, false if no key was pressed in the given time
 */
bool ttyWaitKey (long toMSec=-1) @trusted nothrow @nogc
{
    if (!redirected)
    {
        import core.sys.posix.sys.select : fd_set, select, timeval, FD_ISSET, FD_SET, FD_ZERO;
        import core.sys.posix.unistd : STDIN_FILENO;
        timeval tv;
        fd_set fds;
        FD_ZERO(&fds);
        FD_SET(STDIN_FILENO, &fds); //STDIN_FILENO is 0
        if (toMSec <= 0)
        {
            tv.tv_sec = 0;
            tv.tv_usec = 0;
        }
        else
        {
            tv.tv_sec = cast(int)(toMSec/1000);
            tv.tv_usec = (toMSec%1000)*1000;
        }
        select(STDIN_FILENO+1, &fds, null, null, (toMSec < 0 ? null : &tv));
        return FD_ISSET(STDIN_FILENO, &fds);
    }
    return false;
}


/**
 * Check if key was pressed. Don't block.
 *
 * Returns:
 *    true if key was pressed, false if no key was pressed
 */
bool ttyIsKeyHit () @trusted nothrow @nogc
{
    return ttyWaitKey(0);
}


/**
 * Read one byte from stdin.
 *
 * Params:
 *    toMSec = timeout in milliseconds; < 0: infinite; 0: don't wait; default is -1
 *
 * Returns:
 *    read byte or -1 on error/timeout
 */
int ttyReadKeyByte (long toMSec=-1) @trusted @nogc
{
    if (!redirected)
    {
        import core.sys.posix.unistd : read, STDIN_FILENO;
        ubyte res;
        if (toMSec >= 0)
        {
            synchronized(xlock) if (ttyWaitKey(toMSec) && read(STDIN_FILENO, &res, 1) == 1)
            {
                return res;
            }
        }
        else
        {
            if (read(STDIN_FILENO, &res, 1) == 1)
            {
                return res;
            }
        }
    }
    return -1;
}


/// escape sequences --> key names
__gshared string[string] ttyKeyTrans;


/**
 * Read key from stdin.
 *
 * WARNING! no utf-8 support yet!
 *
 * Params:
 *    toMSec = timeout in milliseconds; < 0: infinite; 0: don't wait; default is -1
 *    toEscMSec = timeout in milliseconds for escape sequences
 *
 * Returns:
 *    null on error or keyname
 */
KeyEvent ttyReadKey (long toMSec=-1, long toEscMSec=300) @trusted
{
    import std.string : format;
    int ch = ttyReadKeyByte(toMSec);
    if (ch < 0)
    {
        return null; // error
    }
    if (ch == 8 || ch == 127)
    {
        return SK.backspace;
    }
    if (ch == 9)
    {
        return SK.tab;
    }
    if (ch == 10)
    {
        return SK.enter;
    }
    // escape?
    if (ch == 27)
    {
        ch = ttyReadKeyByte(toEscMSec);
        if (ch < 0 || ch == 27)
        {
            return SK.escape;
        }
        string kk;
        if (termType != TermType.rxvt && ch == 'O')
        {
            ch = ttyReadKeyByte(toEscMSec);
            if (ch < 0)
            {
                return SK.escape;
            }
            if (ch >= 'A' && ch <= 'Z') kk = "O%c".format(cast(dchar)ch);
        }
        else if (ch == '[')
        {
            kk = "[";
            for (;;)
            {
                ch = ttyReadKeyByte(toEscMSec);
                if (ch < 0 || ch == 27)
                {
                    return SK.escape;
                }
                kk ~= ch;
                if (ch != ';' && (ch < '0' || ch > '9')) break;
            }
        }
        else if (ch == 9)
        {
            return "alt+tab";
        }
        else if (ch >= 1 && ch <= 26)
        {
            return "alt+^%c".format(cast(dchar)(ch+64));
        }
        else if ((ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z') || (ch >= '0' && ch <= '9'))
        {
            return "alt+%c".format(cast(dchar)ch);
        }
        if (kk.length)
        {
            auto kn = kk in ttyKeyTrans;
            return (kn ? *kn : "unknown");
        }
        return "unknown";
    }
    if (ch < 32)
    {
        return "^%c".format(cast(dchar)(ch+64)); // ^X
    }
    // normal
    return "%c".format(cast(dchar)ch);
}


private void initKeyTrans () @trusted
{
    import std.string : format;
    // RXVT
    // arrows, specials
    ttyKeyTrans["[A"] = "up";
    ttyKeyTrans["[B"] = "down";
    ttyKeyTrans["[C"] = "right";
    ttyKeyTrans["[D"] = "left";
    ttyKeyTrans["[2~"] = "insert";
    ttyKeyTrans["[3~"] = "delete";
    ttyKeyTrans["[5~"] = "pageup";
    ttyKeyTrans["[6~"] = "pagedown";
    ttyKeyTrans["[7~"] = "home";
    ttyKeyTrans["[8~"] = "end";
    ttyKeyTrans["[1~"] = "home";
    ttyKeyTrans["[4~"] = "end";
    // xterm
    ttyKeyTrans["OA"] = "up";
    ttyKeyTrans["OB"] = "down";
    ttyKeyTrans["OC"] = "right";
    ttyKeyTrans["OD"] = "left";
    ttyKeyTrans["[H"] = "home";
    ttyKeyTrans["[F"] = "end";
    // arrows and specials with modifiers
    foreach (immutable i, immutable c; ["shift+", "alt+", "alt+shift+", "ctrl+", "ctrl+shift+", "alt+ctrl+", "alt+ctrl+shift+"])
    {
        string t = "[1;%d".format(i+2);
        ttyKeyTrans[t~"A"] = c~"up";
        ttyKeyTrans[t~"B"] = c~"down";
        ttyKeyTrans[t~"C"] = c~"right";
        ttyKeyTrans[t~"D"] = c~"left";
        //
        string t1 = ";%d~".format(i+2);
        ttyKeyTrans["[2"~t1] = c~"insert";
        ttyKeyTrans["[3"~t1] = c~"delete";
        // xterm, spec+f1..f4
        ttyKeyTrans[t~"P"] = c~"f1";
        ttyKeyTrans[t~"Q"] = c~"f2";
        ttyKeyTrans[t~"R"] = c~"f3";
        ttyKeyTrans[t~"S"] = c~"f4";
        // xterm, spec+f5..f12
        foreach (immutable idx, immutable fn; [15, 17, 18, 19, 20, 21, 23, 24])
        {
            string fs = "[%d".format(fn);
            ttyKeyTrans[fs~t1] = c~format("f%d", idx+5);
        }
        // xterm
        ttyKeyTrans["[5"~t1] = c~"pageup";
        ttyKeyTrans["[6"~t1] = c~"pagedown";
        ttyKeyTrans[t~"H"] = c~"home";
        ttyKeyTrans[t~"F"] = c~"end";
    }
    ttyKeyTrans["[2^"] = "ctrl+insert";
    ttyKeyTrans["[3^"] = "ctrl+delete";
    ttyKeyTrans["[5^"] = "ctrl+pageup";
    ttyKeyTrans["[6^"] = "ctrl+pagedown";
    ttyKeyTrans["[7^"] = "ctrl+home";
    ttyKeyTrans["[8^"] = "ctrl+end";
    ttyKeyTrans["[1^"] = "ctrl+home";
    ttyKeyTrans["[4^"] = "ctrl+end";
    ttyKeyTrans["[2$"] = "shift+insert";
    ttyKeyTrans["[3$"] = "shift+delete";
    ttyKeyTrans["[5$"] = "shift+pageup";
    ttyKeyTrans["[6$"] = "shift+pagedown";
    ttyKeyTrans["[7$"] = "shift+home";
    ttyKeyTrans["[8$"] = "shift+end";
    ttyKeyTrans["[1$"] = "shift+home";
    ttyKeyTrans["[4$"] = "shift+end";
    //
    ttyKeyTrans["[E"] = "num5"; // xterm
    // fx, ctrl+fx
    foreach (immutable i; 1..6)
    {
        ttyKeyTrans["[%d~".format(i+10)] = "f%d".format(i);
        ttyKeyTrans["[%d^".format(i+10)] = "ctrl+f%d".format(i);
        ttyKeyTrans["[%d@".format(i+10)] = "ctrl+shift+f%d".format(i);
    }
    foreach (immutable i; 6..11)
    {
        ttyKeyTrans["[%d~".format(i+11)] = "f%d".format(i);
        ttyKeyTrans["[%d^".format(i+11)] = "ctrl+f%d".format(i);
        ttyKeyTrans["[%d@".format(i+11)] = "ctrl+shift+f%d".format(i);
    }
    foreach (immutable i; 11..15)
    {
        ttyKeyTrans["[%d~".format(i+12)] = "f%d".format(i);
        ttyKeyTrans["[%d^".format(i+12)] = "ctrl+f%d".format(i);
        ttyKeyTrans["[%d@".format(i+12)] = "ctrl+shift+f%d".format(i);
    }
    foreach (immutable i; 15..17)
    {
        ttyKeyTrans["[%d~".format(i+13)] = "f%d".format(i);
        ttyKeyTrans["[%d^".format(i+13)] = "ctrl+f%d".format(i);
        ttyKeyTrans["[%d@".format(i+13)] = "ctrl+shift+f%d".format(i);
    }
    foreach (immutable i; 17..21)
    {
        ttyKeyTrans["[%d~".format(i+14)] = "f%d".format(i);
        ttyKeyTrans["[%d^".format(i+14)] = "ctrl+f%d".format(i);
        ttyKeyTrans["[%d@".format(i+14)] = "ctrl+shift+f%d".format(i);
    }
    // xterm
    // f1..f4
    ttyKeyTrans["OP"] = "f1";
    ttyKeyTrans["OQ"] = "f2";
    ttyKeyTrans["OR"] = "f3";
    ttyKeyTrans["OS"] = "f4";
}


shared static this ()
{

}


shared static ~this ()
{

}
