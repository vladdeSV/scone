module scone.os.posix.input.keypress_tree;

import scone.input.scone_control_key : SCK;
import scone.input.scone_key : SK;
import std.typecons : Nullable;

class KeypressTree
{
    public Nullable!Keypress find(in uint[] sequence)
    {
        auto node = this.root;

        foreach (number; sequence)
        {
            if ((number in node.children) !is null)
            {
                node = node.children[number];
            }
            else
            {
                return (Nullable!Keypress).init;
            }
        }

        return node.value;
    }

    public void insert(in uint[] sequence, Keypress data)
    {
        auto node = this.root;

        foreach (number; sequence)
        {
            if ((number in node.children) is null)
            {
                import std.conv : text;

                assert(node.value.isNull(), text("trying to create child tree from node with value. in sequence ",
                        sequence, " at number ", number, "."));

                node.children[number] = new KeypressNode();
            }

            node = node.children[number];
        }

        node.value = data;
    }

    private KeypressNode root = new KeypressNode();
}

unittest
{
    auto tree = new KeypressTree();
    tree.insert([1], Keypress(SK.a, SCK.none));
    tree.insert([2, 3, 4], Keypress(SK.b, SCK.none));
    tree.insert([2, 3, 5], Keypress(SK.b, SCK.none));

    assert(SK.a == tree.find([1]).get.key, "expected to find SK.a from seq [1].");
    assert(SK.b == tree.find([2, 3, 4]).get.key, "expected to find SK.b from seq [2, 3, 4].");
    assert(SK.b == tree.find([2, 3, 5]).get.key, "expected to find SK.b from seq [2, 3, 5].");
}


private struct Keypress
{
    SK key;
    SCK controlKey;
}

private class KeypressNode
{
    KeypressNode[uint] children;
    Nullable!Keypress value;
}
