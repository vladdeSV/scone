module scone.default;

import scone.console.frame;
private Frame _frame;
Frame frame()
{
    return _frame;
}


//will run on program execution
static shared this()
{
    _frame = new Frame(80, 24);
}
