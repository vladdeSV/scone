module scone.logger;

import std.stdio : writefln, File;

///log to logfile
static void logf(Args...)(string str, Args args)
{
    logfile.writefln(str, args);
}

//logfile (duh)
package(scone) static File logfile;