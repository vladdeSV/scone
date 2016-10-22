module scone.console.ui.progress_bar;

import std.conv;
import std.format : format;
import scone.console.ui.element;

class UIProgressBar : UIElement
{
    this(string id, int x, int y, int length, int max, bool showValue = false)
    {
        this.length = length;
        this.max = max;
        this.showValue = showValue;

        _lengthChanged = true;

        super(id, x, y, null);
    }

    private char[] _bar;
    private bool _lengthChanged;
    /**
     * Gives back a string of the bar
     * Returns: char[]
     */
    override string text() @property
    {
        if(_lengthChanged)
        {
            _lengthChanged = false;
            _bar.length = _length;
        }

        _bar[] = emptySlot;

        foreach(n, ref slot; _bar)
        {
            if(n <= length * (value / cast(float) max ) - 1)
            {
                slot = fillSlot;
                continue;
            }
            break;
        }

        if(showValue)
        {
            auto minimumLength = to!string(value).length + spacing * 2 + openValue.length + closeValue.length;
            if(showMaxValue)
            {
                minimumLength += to!string(max).length + divider.length;
            }

            if(_bar.length > minimumLength)
            {
                string str = "%s%s%s".format(openValue, showValue ? "%s%s%s".format(value, divider, max) : "%s".format(value), closeValue);
                auto x1 = (_bar.length / 2) - (str.length / 2);
                auto x2 = (_bar.length / 2) - (str.length / 2) + str.length;
                _bar[x1 .. x2] = str;
            }
        }

        return std.conv.text(_openBar, _bar, _closeBar);
    }

    auto value() @property
    {
        return _value;
    }

    auto value(float value) @property
    {
        _value = value;
    }

    auto length() @property
    {
        return _length;
    }

    auto length(int length) @property
    {
        _length = length;
    }

    auto max() @property
    {
        return _max;
    }

    auto max(int max) @property
    {
        _max = max;
    }

    auto fillSlot() @property
    {
        return _fillSlot;
    }

    auto fillSlot(char fillSlot) @property
    {
        _fillSlot = fillSlot;
    }

    auto emptySlot() @property
    {
        return _emptySlot;
    }

    auto emptySlot(char emptySlot) @property
    {
        _emptySlot = emptySlot;
    }

    auto showValue() @property
    {
        return _showValue;
    }

    auto showValue(bool showValue) @property
    {
        _showValue = showValue;
    }

    auto showMaxValue() @property
    {
        return _showMaxValue;
    }

    auto showMaxValue(bool showMaxValue) @property
    {
        _showMaxValue = showMaxValue;
    }

    auto divider() @property
    {
        return _divider;
    }

    auto divider(string divider) @property
    {
        _divider = divider;
    }

    auto openValue() @property
    {
        return _openValue;
    }

    auto openValue(string openValue) @property
    {
        _openValue = openValue;
    }

    auto closeValue() @property
    {
        return _closeValue;
    }

    auto closeValue(string closeValue) @property
    {
        _closeValue = closeValue;
    }

    auto openBar() @property
    {
        return _openBar;
    }

    auto openBar(typeof(_openBar) openBar) @property
    {
        return _openBar = openBar;
    }

    auto closeBar() @property
    {
        return _closeBar;
    }

    auto closeBar(typeof(_closeBar) closeBar) @property
    {
        return _closeBar = closeBar;
    }

    auto spacing() @property
    {
        return _spacing;
    }

    auto spacing(int spacing) @property
    {
        _spacing = spacing;
    }

    auto opAssign(float value)
    {
        _value = value;
    }

    auto opUnary(string s)()
    if(s == "++")
    {
        return _value += 1;
    }

    auto opUnary(string s)()
    if(s == "--")
    {
        return _value -= 1;
    }

    void opOpAssign(string op)(float value)
    {
        mixin("_value" ~ op ~ "=value;");
    }

    /+
    import std.math : approxEqual;
    import std.traits : isImplicitlyConvertible;

    override bool opEquals(Object)(Object o)
    if(isImplicitlyConvertible!(Object, float))
    {
        return approxEqual(_value, t);
    }
    +/

    /**
     * The value of the status bar
     */
    private float _value = 0;

    /**
     * The amount of slots the entire bar should be
     */
    private int _length;

    /**
     * The maximum value that `value` can be
     * Note: `value` can be bigger than bax, however the bar will not grow more
     */
    private int _max;

    /**
     * The character that the bar will be filled with
     */
    private char _fillSlot = '#';

    /**
     * How the empty slots in the bar will be displayed
     */
    private char _emptySlot = ' ';

    /**
     * If the value of the should be visible on top of the bar
     */
    private bool _showValue = false;

    /**
     * If the maximum value of the should be visible ontop of the bar.
     * Should be on by default, set to false only if maximum value should be hidden
     */
    private bool _showMaxValue = true;

    /**
     * Character(s) that separates the value and maximum value ontop of the bar
     */
    private string _divider = "/";

    /**
     * Character(s) that appears before the value and max value
     */
    private string _openValue = "[";

    /**
     * Character(s) that appears after the value and max value
     */
    private string _closeValue = "]";

    /**
     * Character(s) that appears before the bar.
     * NOTE: Adds to the total length of the bar.
     */
    private string _openBar = "[";

    /**
     * Character(s) that appears after the bar.
     * NOTE: Adds to the total length of the bar.
     */
    private string _closeBar = "]";

    /**
     * Spacing is the minimum space needed around the shown value
     * Eg. "[10/20]" with spacing of 2 = "  [10/20]  " (Two spaces to the left and right)
     * This is to make sure it's possible to show some of the bar. Set to 0 if you don't like it >:(
     */
    private int _spacing = 1;
}
