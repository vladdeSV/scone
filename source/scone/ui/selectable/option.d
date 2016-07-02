module ui.selectable.option;

import ui.selectable;

class UIOption : UISelectable
{
    this(string id, int x, int y, string text, void delegate() action, bool active = true)
    {
        super(id, x, y, text, active);
        _action = action;
    }
}
