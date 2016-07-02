module scone.ui.selectable_class;

import scone.ui.element;

/**
 * Parent of all selectable elements
 */
abstract class UISelectable : UIElement
{
    this(string id, int x, int y, string text, bool active)
    {
        super(id, x, y, text);
        _active = active;
        _action = {};
    }

    /**
     * Returns: bool, true if option is active (enabled)
     */
    auto active() @property
    {
        return _active;
    }

    /**
     * Set if option is active.
     */
    auto active(bool active) @property
    {
        return _active = active;
    }

    /**
     * Returns: void delegate()
     */
    auto execute() @property
    {
        return _action();
    }

    /**
     * Set action upon executing element.
     */
    auto onExecute(void delegate() action) @property
    {
        return _action = action;
    }

    private bool _active;
    protected void delegate() _action;
}
