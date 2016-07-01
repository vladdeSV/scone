module ui.selectable.option;

import ui.selectable;

class UIOption : UISelectable
{
    this(string id, int x, int y, string text, void delegate() action, bool active = true)
    {
        super(id, x, y, text, active);
        _action = action;
    }

    auto action() @property
    {
        return _action();
    }

    auto action(void delegate() action) @property
    {
        return _action = action;
    }

    private void delegate() _action;
}
