module scone.os.posix.input.keypress_tree;

import scone.input.scone_control_key : SCK;
import scone.input.scone_key : SK;
import std.typecons : Nullable;

// todo this logic for inserting values has some problems
// i believe it does not safeguard a node from having both children and a value
// also, getting multiple inputs from a sequence is not 100% reliable. it should work for known sequences, but i would not consider this reliable yet.
class KeypressTree
{
    public Keypress[] find(in uint[] sequence)
    {
        assert(sequence.length);

        Keypress[] keypresses = [];
        auto node = this.root;

        foreach (number; sequence)
        {
            if ((number in node.children) !is null)
            {
                node = node.children[number];
            }
            else
            {
                if (node.value.isNull())
                {
                    if (!(keypresses.length && keypresses[$ - 1].key == SK.unknown))
                    {
                        keypresses ~= Keypress(SK.unknown, SCK.none);
                    }
                }

                node = this.root;
            }

            if (!node.value.isNull())
            {
                //assert node.children is empty
                keypresses ~= node.value.get();
                node = this.root;
            }
        }

        return keypresses;
    }

    public bool insert(in uint[] sequence, Keypress data)
    {
        auto node = this.root;

        foreach (number; sequence)
        {
            if ((number in node.children) is null)
            {
                if(!node.value.isNull())
                {
                    return false;
                }

                node.children[number] = new KeypressNode();
            }

            node = node.children[number];
        }

        node.value = data;

        return true;
    }

    private KeypressNode root = new KeypressNode();
}

unittest
{
    auto tree = new KeypressTree();
    tree.insert([27, 91, 67], Keypress(SK.right, SCK.none));
    tree.insert([27, 91, 66], Keypress(SK.down, SCK.none));
    tree.insert([48], Keypress(SK.key_0, SCK.none));

    assert(SK.unknown == tree.find([1])[0].key);
    assert(SK.key_0 == tree.find([48])[0].key);
    assert(SK.right == tree.find([27, 91, 67])[0].key);
    assert(SK.down == tree.find([27, 91, 66])[0].key);

    auto x = tree.find([27, 91, 67, 27, 91, 66]);
    assert(SK.right == x[0].key);
    assert(SK.down == x[1].key);

    auto y = tree.find([27, 6, 67, 27, 91, 66]);
    assert(SK.unknown == y[0].key);
    assert(SK.down == y[1].key);
}

/// todo move to own file. it is being used in multiple places
struct Keypress
{
    SK key;
    SCK controlKey;
}

private class KeypressNode
{
    KeypressNode[uint] children;
    Nullable!Keypress value;
}
