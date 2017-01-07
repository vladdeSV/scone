module scone.misc.ticker;

import std.conv : to;
import core.time : MonoTime, Duration;

/**
 * A general ticker, intended for games. Used to count how many times the game should update.
 *
 * Example:
 * ---
 * auto ticker = Ticker(60); // update 60 times per second
 * foreach(tick; 0 .. ticker.ticks) // `ticker.ticks` returns how many time to ticks since last call
 * {
 *     // update logic, and only be run 60 times per second
 * }
 * ---
 */
struct Ticker
{
    /**
     * Set custom ticks per second.
     */
    this(uint ticksPerSecond)
    {
        _interval = 1000.0/double(ticksPerSecond);
        reset();
    }

    /**
     * Returns: int, how many ticks that should be run since last call.
     */
    auto ticks() @property
    {
        /* Kudos to Yepoleb who helped me with this */
        MonoTime newtime = MonoTime.currTime();
        Duration duration = newtime - _lasttime;
        long durationmsec = duration.total!"msecs";

        _lasttime = newtime;
        _msecs += durationmsec;
        int ticksOccured = cast(int)(_msecs / _interval);
        _msecs -= cast(int)(ticksOccured * _interval);

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
    private long _msecs = 60;
}
