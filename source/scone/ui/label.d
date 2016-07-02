module ui.label;

import ui.element;

/**
 * A label.
 */
class UILabel : UIElement
{
    this(string id, int x, int y, string text)
    {
        super(id, x, y, text);
    }
}
