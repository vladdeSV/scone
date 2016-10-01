module scone.console.ui.element;

import scone.console.color;

/**
 * Parent of all elements. Comes with a variety of options.
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

    /**
     * Returns: string.
     */
    auto id() @property
    {
        return _id;
    }

    /**
     * Set the id.
     */
    auto id(string id) @property
    {
        return _id = id;
    }

    /**
     * Returns: int.
     */
    auto x() @property
    {
        return _x;
    }

    /**
     * Set the x.
     */
    auto x(int x) @property
    {
        return _x = x;
    }

    /**
     * Returns: int.
     */
    auto y() @property
    {
        return _y;
    }

    /**
     * Set the y.
     */
    auto y(int y) @property
    {
        return _y = y;
    }

    /**
     * Returns: string.
     */
    auto text() @property
    {
        return _text;
    }

    /**
     * Set the text.
     */
    void text(string text) @property
    {
        _text = text;
    }

    /**
     * Returns: Color
     */
    auto color() @property
    {
        return _color;
    }

    /**
     * Set the color.
     */
    auto color(Color color) @property
    {
        return _color = color;
    }

    /**
     * Returns: Color
     */
    auto backgroundColor() @property
    {
        return _backgroundColor;
    }

    /**
     * Set the backgroundColor.
     */
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
