module ui.selectable;

public import ui.selectable.option;
public import ui.selectable.text_input;

import ui.element;

abstract class UISelectable : UIElement
{
    this(string id, int x, int y, string text, bool active)
    {
        super(id, x, y, text);
        _active = active;
        _action = {};
    }

    auto active() @property
    {
        return _active;
    }

    auto active(bool active) @property
    {
        return _active = active;
    }

    auto execute() @property
    {
        return _action();
    }

    auto onExecute(void delegate() action) @property
    {
        return _action = action;
    }

    private bool _active;
    protected void delegate() _action;
}
