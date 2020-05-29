module scone.os.posix.input.input_tree;

import scone.input.scone_control_key : SCK;
import scone.input.scone_key : SK;
import std.experimental.logger : sharedLog;
import std.typecons : Nullable;

class InputTree
{
    InputNode root = new InputNode();
    
    void addInputActionForSequence(InputAction inputAction, uint[] seq)
    {
        assert(seq.length);
        root.mapInputEvent(inputAction, seq);
    }
}

unittest
{
    auto tree = new InputTree();
    tree.addInputActionForSequence(InputAction(SK.a, SCK.none), [1]);
    tree.addInputActionForSequence(InputAction(SK.b, SCK.none), [2, 3, 4]);
    tree.addInputActionForSequence(InputAction(SK.b, SCK.none), [2, 3, 5]);

    assert(SK.a == tree.root.children[1].input.get.key);
    assert(SK.b == tree.root.children[2].children[3].children[4].input.get.key);
    assert(SK.b == tree.root.children[2].children[3].children[5].input.get.key);
}

private class InputNode
{
    Nullable!InputAction input;
    InputNode[uint] children;

    void mapInputEvent(InputAction inputAction, uint[] sequence)
    {
        if (sequence.length == 0)
        {
            this.setInputEvent(inputAction);
            return;
        }

        auto value = sequence.popFrontValue;
        auto node = this.getOrCreateChildNodeForValue(value);

        node.mapInputEvent(inputAction, sequence);
    }

    private void setInputEvent(InputAction ia)
    {
        if (!this.input.isNull)
        {
            assert(0, "trying to redefine input");
        }

        this.input = ia;
    }

    private InputNode getOrCreateChildNodeForValue(uint value)
    {
        InputNode node;
        if ((value in this.children) is null)
        {
            node = new InputNode();
            this.children[value] = node;
        }
        else
        {
            node = this.children[value];
        }

        return node;
    }
}

private struct InputAction
{
    SK key;
    SCK controlKey;
}

private uint popFrontValue(ref uint[] array) pure
{
    auto value = array[0];

    import std.range.primitives : popFront;    
    popFront(array);

    return value;
}
