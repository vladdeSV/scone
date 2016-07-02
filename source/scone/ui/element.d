module ui.element;

import scone.color;

/**
 * Parent of all elements. Comes with a variety of
 */
abstract class UIElement
{
    this(string id, int x, int y, string text)
    {
        _id = id;
        _x = x;
        _y = y;
        _text = text;
    }

    auto id() @property
    {
        return _id;
    }

    auto id(string id) @property
    {
        return _id = id;
    }

    auto x() @property
    {
        return _x;
    }

    auto x(int x) @property
    {
        return _x = x;
    }

    auto y() @property
    {
        return _y;
    }

    auto y(int y) @property
    {
        return _y = y;
    }

    auto text() @property
    {
        return _text;
    }

    auto text(string text) @property
    {
        _text = text;
    }

    auto color() @property
    {
        return _color;
    }

    auto color(Color color) @property
    {
        return _color = color;
    }

    auto backgroundColor() @property
    {
        return _backgroundColor;
    }

    auto backgroundColor(Color backgroundColor) @property
    {
        return _backgroundColor = backgroundColor;
    }

    private int _x, _y;
    private string _id;
    private fg _color = Color.white_dark;

    protected string _text;
    protected bg _backgroundColor = Color.black_dark;
}
