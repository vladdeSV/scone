module ui;

public import ui.element;
public import ui.label;
public import ui.selectable;

import scone;
import std.conv;

struct UI
{
    bool inputting;

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
            //psudo code
            //elemnt is a selectable

            if(typeid(element).base == typeid(UISelectable))
            {
                _selectedElement = n;
                break;
            }
        }
    }

    //bool inputting;

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
        else if(input.key == SK.escape)
        {
            //break mainloop
            //run = false;
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

    //FIXME: Remove or change this one later on...
    auto execute()
    {
        auto element = _elements[_selectedElement];
        if(typeid(element) == typeid(UIOption))
        {
            (cast(UIOption) element).action();
        }
        else if(typeid(element) == typeid(UITextInput))
        {
            nextSelected();
        }
    }

    /**
     * Puts all elements onto the frame assigned.
     * Note: It is needed to call the frame's print() method.
     */
    auto display()
    {
        foreach(n, ref element; _elements)
        {
            bool selected = n == _selectedElement;

            //auto text = typeid(element) == typeid(UIOption) ? (selected ? selOpt ~ element.text : unselOpt ~ element.text) : element.text;

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

                if(e.content() != [] || _selectedElement == n)
                {
                    text = e.content(_selectedElement == n);
                }
            }

            _frame.write(element.x, element.y, color, element.backgroundColor, text);
        }
    }

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

    private void nextSelected()
    {
        //Get our current position in the list of elements
        uint currentPos = _selectedElement;

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

    private auto prevSelected()
    {
        //Get our current position in the list of elements
        uint currentPos = _selectedElement;

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

    private bool isElementSelectable(uint currentPos)
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

    private Frame _frame;
    private UIElement[] _elements;

    private string _selectedOptionPrefix = "> ", _unselectedOptionPrefix = " ";
    private Color _selectedOptionColor = Color.green, _inactiveOptionColor = Color.black;
    private bool _highlightOption = true;

    private uint _selectedElement = 0;
}
