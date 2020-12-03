module benchmark.bench_1;

import std.datetime.stopwatch : StopWatch;
import std.stdio : writeln, writef, stdout;
import std.conv : to, text;

void main()
{
    auto sw = StopWatch();
    sw.stop();
    sw.reset();

    immutable height = 60;
    immutable repeatMultiplier = 10_000;
    immutable repeat = (height * repeatMultiplier);

    string[] results;

    sw.start();
    foreach (i; 0 .. repeat)
    {
        auto pos = (i % 2) + 1;
        writef("\033[%d;%dH", pos, pos);
    }
    stdout.flush();
    sw.stop();
    results ~= to!string(sw.peek);
    sw.reset();

    sw.start();
    foreach (i; 0 .. repeat)
    {
        auto pos = (i % 2) + 1;
        writef("\033[%d;%dH", pos, pos);
        stdout.flush();
    }
    sw.stop();
    results ~= to!string(sw.peek);
    sw.reset();

    sw.start();
    foreach (i; 0 .. repeatMultiplier)
    {
        string data = "";

        foreach (j; 0 .. height)
        {
            auto pos = ((j * i) % 2) + 1;
            data ~= text("\033[", pos, ";", pos, "H");
        }

        writef(data);
    }
    stdout.flush();
    sw.stop();
    results ~= to!string(sw.peek);
    sw.reset();

    sw.start();
    foreach (i; 0 .. repeatMultiplier)
    {
        string data = "";

        foreach (j; 0 .. height)
        {
            auto pos = ((j * i) % 2) + 1;
            data ~= text("\033[", pos, ";", pos, "H");
        }

        writef(data);
        stdout.flush();
    }
    sw.stop();
    results ~= to!string(sw.peek);
    sw.reset();

    printResults(results);
}

void printResults(string[] results)
{
    writef("\033[2J");
    writef("\033[0;0H");
    stdout.flush();

    foreach (n, string result; results)
    {
        writeln(n + 1, ": ", result);
    }
}

/+ sample output on github codespaces

    1: 327 ms, 110 μs, and 7 hnsecs
    2: 5 secs, 931 ms, 412 μs, and 9 hnsecs
    3: 734 ms, 360 μs, and 3 hnsecs
    4: 597 ms, 116 μs, and 7 hnsecs

+/
