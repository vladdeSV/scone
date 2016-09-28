module scone.console.ui.selectable.option;

import scone.console.ui.selectable;

/**
 * Selectable option.
 * Example:
 * ---
 * auto termOption = new UIOption
 * ("termOption", 1,1, "Terminate application",
 *     {
 *         assert(0, "Application terminated.");
 *     }
 * );
 * ---
 */
class UIOption : UISelectable
{
    this(string id, int x, int y, string text, void delegate() action, bool active = true)
    {
        super(id, x, y, text, active);
        _action = action;
    }
}
