import 'dart:convert';
class treenode
{
  String id;
  List<String> children;
  bool show;
  treenode(this.id, this.children);
}

class tree {
  treenode root;
  List<treenode> nodes;
  int ypos;
  int rootx;
  int rooty;
  tree.fromJson(String json)
  {

    nodes = new List<treenode>();
    Map jsonnodes = JSON.decode(json);
    for(var jsonnode in jsonnodes["nodes"])
    {
      treenode node = new treenode(jsonnode["id"],jsonnode["children"]);
      node.show=false;
      nodes.add(node);
    }
    root = nodes[0];
    rootx = 20;
    rooty = 10;
  }

  tree.gen()
  {
    autogenerate();
  }

  void autogenerate()
  {
    nodes = new List<treenode>();
    treenode myroot = new treenode("0",[]);
    generate(myroot);
    root = myroot;
    root = nodes[0];
    rootx = 20;
    rooty = 10;
  }

  void generate(treenode node)
  {
    node.show=false;
    nodes.add(node);
    if(node.id.length < 8)
    {
      for (int i = 0;i < 3;i++)
      {
        node.children.add(node.id + i.toString());
        treenode childnode = new treenode(node.id + i.toString(), []);
        generate(childnode);
      }
    }
  }
}