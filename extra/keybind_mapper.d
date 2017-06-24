/+ This application gathers the ASCII-code sequences for some of scone's available keys. +/

void main()
{
    writeln("\n\n== scone Key Mapper ==\n");
    writeln("Press appropriate key when asked.\n");
    writeln("HELP:\nESC - Exit application\nBACKSPACE - Redo key/move back\nENTER - Skip\n\n");

    //prepare the terminal input (lots of crap)
    prepareInputPolling();
    beginPolling();

    //store all ascii-friendly keys in array
    auto sks = [EnumMembers!SK];
    //where all codes will be stored
    uint[][4][EnumMembers!(SK).length] store;

    main_loop:
    for(int aaa = 0; aaa < sks.length; ++aaa)
    {
        //get current key in SK
        auto sk = sks[aaa];

        //temporary storage. has four slots with dynamic uint arrays
        uint[][4] c;

        //iterate over all modifier-keys
        foreach(n, sck; ["none","shift","control","alt"])
        {
            if(sck == "none")
            {
                write("Please press ", sk, ".                             ");
            }
            else
            {
                write("Please press ", sk, " while holding the ", sck, "-key.");
            }

            //properly displays current line
            std.stdio.stdout.flush();

            //i = input sequences
            uint[] i = null;

            while(i == null)
            {
                //continously get a sequence
                i = getInputs();

                //sleep to not burn the CPU
                Thread.sleep(30.msecs);
            }

            //hacky way of checking for specific key in code below
            uint first = i.length == 1 ? i[0] : 0;

            //esc, stop program and output currently stored inputs
            if(first == 27)
            {
                writeln("\r");
                break main_loop;
            }
            //enter, skips an input
            else if(first == 13)
            {
                writeln("\n\r  SKIPPING\r");
                continue;
            }
            //backspace, redo/move back
            else if(first == 127)
            {
                //basically, redo input if something for key was entered. otherwise move back
                if(n == 0)
                {
                    writeln("\n\r  MOVING BACK\r");
                    aaa -= 2;
                    if(aaa < -1) aaa = -1;
                }
                else
                {
                    writeln("\n\r  REDO INPUT\r");
                    aaa -= 1;
                }

                continue main_loop;
            }

            //check if the same keybind exists with another modifier key.
            //if not found, store it
            if(!c[0 .. n].canFind(i))
            {
                c[n] = i;
                writeln("\t :)   Mapped ", i, " to ", (sck == "none" ? text(sk) : text(sk, " (", sck, ')')), '\r');
            }
            else
            {
                c[n] = null;
                writeln("\t :(   Keybind already present, setting blank.\r");
            }
        }

        //store the ASCII-codes
        store[aaa] = c;
    }

    //open a file and store all codes
    auto f = File("input_sequences.scone.txt", "w");
    foreach(n, k; sks)
    {
        string line = text(k, '\t');

        if(store[n] == [null, null, null, null]) continue;
        foreach(m; 0 .. 4)
        {
            line ~= (((store[n][m] is null) ? "-" : text(store[n][m])[1 .. $ - 1]) ~ (m == 4 ? "" : "\t"));
        }

        f.writeln(line);
    }

    //properly exit
    inited = false;
    tcsetattr(STDOUT_FILENO, TCSADRAIN, &oldState);
}

//all code below was yanked from scone

import core.stdc.stdio;
import core.sys.posix.fcntl;
import core.sys.posix.poll;
import core.sys.posix.sys.ioctl;
import core.sys.posix.unistd : read;
import core.sys.posix.unistd : STDOUT_FILENO;
import core.thread;
import std.concurrency : spawn, Tid, thisTid, send;
import std.concurrency;
import std.conv : to, text;
import std.datetime : Duration, msecs;
import std.process : execute;
import std.stdio : write, writef;
import std.stdio;
import std.traits : EnumMembers;
import std.algorithm;
extern(C)
{
    import core.sys.posix.termios;
    void cfmakeraw(termios *termios_p);
}

static __gshared bool inited = true;
static __gshared termios oldState, newState;
version (OSX) enum TIOCGWINSZ = 0x40087468;

uint[] getInputs()
{
    uint[] codes;
    bool receivedInput = true;

    while(receivedInput)
    {
        bool gotSomething = false;

        receiveTimeout
        (
            1.msecs,
            (uint code) { codes ~= code; gotSomething = true; },
        );

        if(!gotSomething)
        {
            receivedInput = false;
        }
    }

    return codes;
}

void prepareInputPolling()
{
    tcgetattr(1, &oldState);
    newState = oldState;
    cfmakeraw(&newState);
    tcsetattr(STDOUT_FILENO, TCSADRAIN, &newState);
}

void beginPolling()
{
    spawn(&pollInputEvent, thisTid);
}

void pollInputEvent(Tid parentThreadID)
{
    while(inited)
    {
        pollfd ufds;
        ufds.fd = STDOUT_FILENO;
        ufds.events = POLLIN;

        uint input;
        enum timeout = 1000;
        immutable bytesRead = poll(&ufds, 1, timeout);

        if(bytesRead == -1)
        {
            //logf("(POSIX) ERROR: polling input returned -1");
        }
        else if(bytesRead == 0)
        {
            //timeout!
            //if no key was pressed within `timeout`,
            //this happens. which is good!
        }
        else if(ufds.revents & POLLIN)
        {
            //read from keyboard
            read(STDOUT_FILENO, &input, 1);

            //send ansi to main thread, where it will be handled.
            send(parentThreadID, input);
        }
    }
}

///Some keys which scone can handle
enum SK
{
    ///A key
    a,

    ///B key
    b,

    ///C key
    c,

    ///D key
    d,

    ///E key
    e,

    ///F key
    f,

    ///G key
    g,

    ///H key
    h,

    ///I key
    i,

    ///J key
    j,

    ///K key
    k,

    ///L key
    l,

    ///M key
    m,

    ///N key
    n,

    ///O key
    o,

    ///P key
    p,

    ///Q key
    q,

    ///R key
    r,

    ///S key
    s,

    ///T key
    t,

    ///U key
    u,

    ///V key
    v,

    ///W key
    w,

    ///X key
    x,

    ///Y key
    y,

    ///Z key
    z,

    ///LEFT ARROW key
    left,

    ///UP ARROW key
    up,

    ///RIGHT ARROW key
    right,

    ///DOWN ARROW key
    down,

    ///0 key
    key_0,

    ///1 key
    key_1,

    ///2 key
    key_2,

    ///3 key
    key_3,

    ///4 key
    key_4,

    ///5 key
    key_5,

    ///6 key
    key_6,

    ///7 key
    key_7,

    ///8 key
    key_8,

    ///9 key
    key_9,

    ///TAB key
    tab,

    ///SPACEBAR
    space,

    ///PAGE UP key
    page_up,

    ///PAGE DOWN key
    page_down,

    ///END key
    end,

    ///HOME key
    home,

    ///DEL key
    del,

    ///Numeric keypad 0 key
    numpad_0,

    ///Numeric keypad 1 key
    numpad_1,

    ///Numeric keypad 2 key
    numpad_2,

    ///Numeric keypad 3 key
    numpad_3,

    ///Numeric keypad 4 key
    numpad_4,

    ///Numeric keypad 5 key
    numpad_5,

    ///Numeric keypad 6 key
    numpad_6,

    ///Numeric keypad 7 key
    numpad_7,

    ///Numeric keypad 8 key
    numpad_8,

    ///Numeric keypad 9 key
    numpad_9,

    ///Multiply key
    multiply,

    ///Add key
    add,

    ///Separator key
    separator,

    ///Subtract key
    subtract,

    ///Decimal key
    decimal,

    ///Divide key
    divide,

    ///F1 key
    f1,

    ///F2 key
    f2,

    ///F3 key
    f3,

    ///F4 key
    f4,

    ///F5 key
    f5,

    ///F6 key
    f6,

    ///F7 key
    f7,

    ///F8 key
    f8,

    ///F9 key
    f9,

    ///F10 key
    f10,

    ///F11 key
    f11,

    ///F12 key
    f12,

    ///For any country/region, the '+' key
    plus,

    ///For any country/region, the ',' key
    comma,

    ///For any country/region, the '-' key
    minus,

    ///For any country/region, the '.' key
    period,

    ///Used for miscellaneous characters; it can vary by keyboard.
    oem_1,

    ///Used for miscellaneous characters; it can vary by keyboard.
    oem_2,

    ///Used for miscellaneous characters; it can vary by keyboard.
    oem_3,

    ///Used for miscellaneous characters; it can vary by keyboard.
    oem_4,

    ///Used for miscellaneous characters; it can vary by keyboard.
    oem_5,

    ///Used for miscellaneous characters; it can vary by keyboard.
    oem_6,

    ///Used for miscellaneous characters; it can vary by keyboard.
    oem_7,

    ///Used for miscellaneous characters; it can vary by keyboard.
    oem_8,

    ///Either the angle bracket key or the backslash key on the RT 102-key
    ///keyboard
    oem_102,
}
