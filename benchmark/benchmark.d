module benchmark.benchmark;

import std.stdio : writef, writeln, stdout;
import std.conv : to, text;

void main()
{
    writef("\033[2J");
    writef("\033[1;1H");
    stdout.flush();

    immutable height = 60;
    immutable repeatMultiplier = 10_000;
    immutable repeat = (height * repeatMultiplier);

    void delegate()[] benchmarks;

    string[][] results;

/+
    benchmarks = [
        () {
            foreach (i; 0 .. repeat)
            {
                auto pos = (i % 2) + 1;
                writef("\033[%d;%dH", pos, pos);
            }

            stdout.flush();
        }, () {
            foreach (i; 0 .. repeat)
            {
                auto pos = (i % 2) + 1;
                writef("\033[%d;%dH", pos, pos);
                stdout.flush();
            }
        }, () {
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
        }, () {
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
        }
    ];
    +/
    

    results ~= benchmark(benchmarks);

    /+ sample output on github codespaces

        1: 327 ms, 110 μs, and 7 hnsecs
        2: 5 secs, 931 ms, 412 μs, and 9 hnsecs
        3: 734 ms, 360 μs, and 3 hnsecs
        4: 597 ms, 116 μs, and 7 hnsecs

    +/

    benchmarks = [
        () {
            foreach (i; 0 .. repeat)
            {
                auto character = ['1', '2'][i % 2];
                writef("\033[1;1H%s                                                                              %s",
                        character, character);
            }
        }, () {
            foreach (i; 0 .. repeat)
            {
                auto character = ['1', '2'][i % 2];
                writef("\033[1;1H%s\033[1;80H%s", character, character);
            }
        }, () {
            foreach (i; 0 .. repeat)
            {
                auto character = ['1', '2'][i % 2];
                writef("\033[1;1H%s %s", character, character);
            }
        }, () {
            foreach (i; 0 .. repeat)
            {
                auto character = ['1', '2'][i % 2];
                writef("\033[1;1H%s\033[1;3H%s", character, character);
            }
        }, () {
            foreach (i; 0 .. repeat)
            {
                // 10 changed characters
                auto character = ['1', '2'][i % 2];
                writef("\033[1;1H%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
                        character, " ", character, " ", character, " ",
                        character, " ", character, " ", character, " ", character,
                        " ", character, " ", character, " ", character);
            }
        }, () {
            foreach (i; 0 .. repeat)
            {
                // 10 changed characters
                auto character = ['1', '2'][i % 2];
                writef("\033[1;1H%s\033[1;3H%s\033[1;5H%s\033[1;7H%s\033[1;9H%s\033[1;11H%s\033[1;13H%s\033[1;15H%s\033[1;17H%s\033[1;19H%s",
                        character, character, character, character, character,
                        character, character, character, character, character);
            }
        },
    ];

    results ~= benchmark(benchmarks);

    printResults(results);
}

auto benchmark(void delegate()[] benchmarks)
{
    import std.datetime.stopwatch : StopWatch;

    auto sw = StopWatch();
    sw.stop();
    sw.reset();

    string[] results;
    foreach (benchmark; benchmarks)
    {
        sw.reset();
        sw.start();
        benchmark();
        sw.stop();
        stdout.flush();
        results ~= to!string(sw.peek);
    }

    return results;
}

void printResults(string[][] results)
{
    writef("\033[2J");
    writef("\033[1;1H");
    stdout.flush();
    
    foreach (r; results)
    {
        writeln;
        foreach (n, string result; r)
        {
            writeln(n + 1, ": ", result);
        }
    }
}
