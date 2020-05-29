module scone.os.posix.input.input_tree;

import scone.input.scone_key : SK;
import scone.input.scone_control_key : SCK;
import std.typecons : Nullable;
import std.range.primitives : popFront;
import std.experimental.logger : sharedLog;

class InputTree
{
    InputNode root = new InputNode();

    void addInputActionForSequence(InputAction inputAction, uint[] seq)
    {
        assert(seq.length);

        sharedLog.log("tree: starting to add ", inputAction, " for seq ", seq);
        root.f(inputAction, seq);
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

    void f(InputAction inputAction, uint[] seq)
    {
        sharedLog.log("seq: ", seq, " for action ", inputAction);

        if (seq.length == 0)
        {
            if (!this.input.isNull)
            {
                assert(false, "trying to redefine input");
            }

            input = inputAction;
            return;
        }

        uint value = seq[0];
        seq.popFront;

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

        node.f(inputAction, seq);
    }
}

private struct InputAction
{
    SK key;
    SCK controlKey;
}
