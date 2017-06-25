module scone.misc.ticker;

import std.conv : to;
import core.time : MonoTime, Duration;

/**
 * A general ticker, intended for games. Used to count how many times the game should update per second.
 *
 * Example:
 * ---
 * auto ticker = Ticker(60); // update 60 times per second
 * foreach(tick; 0 .. ticker.ticks) // `ticker.ticks` returns how many time to ticks since last call
 * {
 *     // update logic, and only be run 60 times per second
 * }
 *
 * window.clear();
 * window.write(...);
 * window.print();
 * ---
 */
struct Ticker
{
    /**
     * Set custom ticks per second.
     */
    this(uint ticksPerSecond)
    {
        _interval = 10^^9/double(ticksPerSecond);
        reset();
    }

    /**
     * Returns: int, how many ticks that should be run since last call.
     */
    auto ticks() @property
    {
        /* Kudos to @Yepoleb who helped me with this */
        immutable newtime = MonoTime.currTime();
        immutable duration = newtime - _lasttime;

        import scone.os;

        _lasttime = newtime;
        _nsecs += duration.total!"nsecs";
        int ticksOccured = cast(int)(_nsecs / _interval);

        _nsecs -= cast(int)(ticksOccured * _interval);

        return ticksOccured;
    }

    /**
     * Resets the ticks since last call `ticks()`
     */
    void reset()
    {
        _lasttime = MonoTime.currTime();
    }

    private MonoTime _lasttime;
    private double _interval;
    private long _nsecs = 0;
}
