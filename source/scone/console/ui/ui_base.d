module scone.console.ui.base;

import scone;
import std.conv;

/**
 * UI, holds all UI elements.
 */
struct UI
{
    /**
     * Construct a UI
     * Example:
     * ---
     * auto nameLabel = new UILabel("nameLabel", 1,1, "THIS IS A LABEL");
     * nameLabel.color = Color.yellow;
     *
     * auto ui = UI(parent,
     *     [
     *         nameLabel,
     *         new UIOption("exitOption", 1,3, "Exit",
     *             {
     *                 mainLoop = false;
     *             }
     *         )
     *     ]
     * );
     *
     * ui.elementById("exitOption").color = Color.red;
     * ---
     */
    this(Frame frame, UIElement[] elements)
    in
    {
        //Make sure all elements have unique ids
        string[] ids = new string[](elements.length);
        import std.algorithm;
        foreach(n, ref e; elements)
        {
            if(ids.find(e.id) == [])
            {
                ids[n] = e.id;
            }
            else
            {
                assert(0, "Multiple id discrepancy: " ~ e.id);
            }
        }
    }
    body
    {
        _frame = frame;
        _elements = elements;

        foreach(n, element; elements)
        {
            if(typeid(element).base == typeid(UISelectable))
            {
                _selectedElement = n;
                break;
            }
        }
    }

    /**
     * Call with current keypress to update the UI
     *
     * Example:
     * ---
     * foreach(input; getInputs())
     * {
     *     //Optional check to see if input is pressed
     *     if(!input.pressed)
     *     {
     *         continue;
     *     }
     *
     *     //Manul check to terminate program
     *     if(input.key == SK.c && input.hasControlKey(SCK.ctrl))
     *     {
     *         run = false;
     *     }
     *
     *     ui.update(input);
     * }
     * ---
     */
    auto update(ref KeyEvent input)
    {
        if(input.key == SK.up)
        {
            prevSelected();
        }
        else if(input.key == SK.down)
        {
            nextSelected();
        }
        else if(input.key == SK.enter)
        {
            execute();
        }
        else if(typeid(_elements[this._selectedElement]) == typeid(UITextInput))
        {
            (cast(UITextInput) _elements[_selectedElement]).input(input);
        }
    }

    /**
     * Puts all elements onto the frame assigned.
     * Note: It is also needed to call the frame's print() method.
     *
     * Example:
     * ---
     * ui.display();
     * frame.print();
     * ---
     */
    auto display()
    {
        foreach(n, ref element; _elements)
        {
            bool selected = n == _selectedElement;
            string text;

            if(typeid(element) == typeid(UIOption))
            {
                if(selected)
                {
                    text = _selectedOptionPrefix ~ element.text;
                }
                else
                {
                    text = _unselectedOptionPrefix ~ element.text;
                }
            }
            else
            {
                text = element.text;
            }

            fg color = element.color;

            if(typeid(element) == typeid(UIOption) && (cast(UIOption) element).active == false)
            {
                color = _inactiveOptionColor;
            }
            else if(_highlightOption && selected)
            {
                color = _selectedOptionColor;
            }

            if(typeid(element) == typeid(UITextInput))
            {
                UITextInput e = cast(UITextInput) element;

                if(e.displayable() != [] || _selectedElement == n)
                {
                    text = e.displayable(_selectedElement == n);
                }
                else
                {
                    text = e.placeholder();
                }
            }

            _frame.write(element.x, element.y, color, element.backgroundColor, text);
        }
    }

    /**
     * Returns: UIElement with specified id. If not found, returns null.
     */
    auto elementById(string id)
    {
        //Loop through all elements, and if the element's id matches, return it
        foreach(ref element; _elements)
        {
            if(element.id == id)
            {
                return element;
            }
        }

        //If not found, return null
        return null;
    }

    /**
     * Goes to the next selectable element.
     * Note: Only use this if you really need to manually change the selected element. Otherwise use `update(KeyEvent input)`.
     */
    void nextSelected()
    {
        //Get our current position in the list of elements
        auto currentPos = _selectedElement;

        do
        {
            //Move one step forward to the next element
            currentPos = (currentPos + 1) % _elements.length;

            //If we've looped around there are no other selectable elements. Stop
            if(currentPos == _selectedElement)
            {
                return;
            }
        }
        //If the current element isn't selectable, continue...
        while(isElementSelectable(currentPos));

        //Once we reach a selectable element, set our current element to this newly found one
        _selectedElement = currentPos;
    }

    /**
     * Goes to the previous selectable element.
     * Note: Only use this if you really need to manually change the selected element. Otherwise use `update(KeyEvent input)`.
     */
    auto prevSelected()
    {
        //Get our current position in the list of elements
        auto currentPos = _selectedElement;

        do
        {
            //Move one step back to the previous element
            currentPos = (currentPos - 1 + _elements.length) % _elements.length;

            //If we've looped around there are no other selectable elements. Stop
            if(currentPos == _selectedElement)
            {
                return;
            }
        }
        //If the current element isn't selectable, continue...
        while(isElementSelectable(currentPos));

        //Once we reach a selectable element, set our current element to this newly found one
        _selectedElement = currentPos;
    }

    /**
     * When `executeKey` is sent in via update, this function gets called.
     */
    auto execute()
    {
        //Should never evaluate to true, but just in case the current selected element is not a child of UISelectable
        if(typeid(_elements[this._selectedElement]).base != typeid(UISelectable))
        {
            return;
        }

        //Cast current element to a UISelectable
        auto element = cast(UISelectable)(_elements[_selectedElement]);

        //Execute by default. (Note: UITextInput has it's default action to `{}`, meaning nothing will happen)
        element.action();

        //If we're a text input, move to the next element.
        if(typeid(element) == typeid(UITextInput))
        {
            nextSelected();
        }
    }

    private bool isElementSelectable(size_t currentPos)
    {
        return typeid(_elements[currentPos]).base != typeid(UISelectable) || (typeid(_elements[currentPos]).base == typeid(UISelectable) && (cast(UISelectable) _elements[currentPos]).active == false);
    }

    auto selectedOptionPrefix() @property
    {
        return _selectedOptionPrefix;
    }

    auto selectedOptionPrefix(string selectedOptionPrefix) @property
    {
        return _selectedOptionPrefix = selectedOptionPrefix;
    }

    auto unselectedOptionPrefix() @property
    {
        return _unselectedOptionPrefix;
    }

    auto unselectedOptionPrefix(string unselectedOptionPrefix) @property
    {
        return _unselectedOptionPrefix = unselectedOptionPrefix;
    }

    auto selectedOptionColor() @property
    {
        return _selectedOptionColor;
    }

    auto selectedOptionColor(Color selectedOptionColor) @property
    {
        return _selectedOptionColor = selectedOptionColor;
    }

    auto inactiveOptionColor() @property
    {
        return _inactiveOptionColor;
    }

    auto inactiveOptionColor(Color inactiveOptionColor) @property
    {
        return _inactiveOptionColor = inactiveOptionColor;
    }

    auto highlightOption() @property
    {
        return _highlightOption;
    }

    auto highlightOption(bool highlightOption) @property
    {
        return _highlightOption = highlightOption;
    }

    auto nextKey() @property
    {
        return _nextKey;
    }

    auto nextKey(SK nextKey) @property
    {
        return _nextKey = nextKey;
    }

    auto prevKey() @property
    {
        return _prevKey;
    }

    auto prevKey(SK prevKey) @property
    {
        return _prevKey = prevKey;
    }

    auto executeKey() @property
    {
        return _executeKey;
    }

    auto executeKey(SK executeKey) @property
    {
        return _executeKey = executeKey;
    }

    private Frame _frame;
    private UIElement[] _elements;

    private SK _nextKey = SK.right, _prevKey = SK.left, _executeKey = SK.enter;
    private string _selectedOptionPrefix = "> ", _unselectedOptionPrefix = " ";
    private Color _selectedOptionColor = Color.green, _inactiveOptionColor = Color.black;
    private bool _highlightOption = true;

    private size_t _selectedElement = 0;
}
