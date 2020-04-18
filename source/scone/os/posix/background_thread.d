module scone.os.posix.background_thread;

version (Posix)
{
    import core.sys.posix.fcntl;
    import core.sys.posix.poll;
    import core.sys.posix.sys.ioctl : ioctl, winsize, TIOCGWINSZ;
    import core.sys.posix.unistd : read, STDOUT_FILENO;
    import core.thread : Thread;
    import scone.frame.size : Size;
    import scone.os.window : ResizeEvent;
    import std.concurrency : thisTid, send, ownerTid;
    import std.datetime : Duration, msecs;

    static void pollTerminalResize(Size initialSize)
    {
        Thread.getThis.isDaemon = true;

        Size previousSize = initialSize;

        while (true)
        {
            Thread.sleep(250.msecs); //todo check for appropriate number

            winsize winsz;
            ioctl(STDOUT_FILENO, TIOCGWINSZ, &winsz);
            Size currentSize = Size(winsz.ws_col, winsz.ws_row);

            if (currentSize != previousSize)
            {
                previousSize = currentSize;
                send(ownerTid, ResizeEvent(currentSize));
            }
        }
    }

    static void pollInputEvent()
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
