module scone.input.os.posix.background_thread;

version (Posix)
{
    import core.sys.posix.fcntl;
    import core.sys.posix.poll;
    import core.sys.posix.sys.ioctl : ioctl, winsize, TIOCGWINSZ;
    import core.sys.posix.unistd : read, STDOUT_FILENO;
    import core.thread : Thread;
    import scone.output.types.size : Size;
    import std.concurrency : thisTid, send, ownerTid;
    import std.datetime : Duration, msecs;

    static void pollKeyboardEvent()
    {
        Thread.getThis.isDaemon = true;

        while (true)
        {
            pollfd ufds;
            ufds.fd = STDOUT_FILENO;
            ufds.events = POLLIN;

            uint input;
            auto bytesRead = poll(&ufds, 1, -1);

            if (bytesRead == -1)
            {
                // error
            }
            else if (bytesRead == 0)
            {
                // no key was pressed within `timeout`. this is normal
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
}
