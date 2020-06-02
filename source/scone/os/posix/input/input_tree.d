module scone.os.posix.input.input_tree;

import scone.input.scone_control_key : SCK;
import scone.input.scone_key : SK;
import std.typecons : Nullable;

private struct Data
{
    SK key;
    SCK controlKey;
}

class Node
{
    Node[uint] children;
    Nullable!Data value;
}

Nullable!Data find(Node root, in uint[] sequence)
{
    Node node = root;

    foreach (number; sequence)
    {
        if ((number in root.children) !is null)
        {
            node = root.children[number];
        }
        else
        {
            return (Nullable!Data).init;
        }
    }

    return node.value;
}

void insert(Node root, in uint[] sequence, Data data)
{
    Node node = root;
    foreach (number; sequence)
    {
        if ((number in node.children) is null)
        {
            node.children[number] = new Node();
        }

        node = node.children[number];
    }

    node.value = data;
}

unittest
{
    auto root = new Node();
    root.insert([1], Data(SK.a, SCK.none));
    root.insert([2, 3, 4], Data(SK.b, SCK.none));
    root.insert([2, 3, 5], Data(SK.b, SCK.none));

    assert(SK.a == root.children[1].value.get.key);
    assert(SK.b == root.children[2].children[3].children[4].value.get.key);
    assert(SK.b == root.children[2].children[3].children[5].value.get.key);
}
