import 'dart:html';
import 'dart:convert';
import 'dart:async';
class rectangle
{
  int xmin;
  int xmax;
  int ymin;
  int ymax;
  rectangle():xmin=-1,xmax=-1,ymin=-1,ymax=-1;
  draw(context)
  {
    context.beginPath();
    context.moveTo(xmin, ymax);
    context.lineTo(xmax, ymax);
    context.lineTo(xmax, ymin);
    context.lineTo(xmin, ymin);
    context.lineTo(xmin, ymax);
    context.lineWidth = 2;
    context.stroke();
  }
}


class treenode extends rectangle
{
    String id;
    List<String> children;
    bool show;
    treenode(this.id,this.children);
    expand(context)
    {
      var xcenter = (xmin+xmax)/2;
      var ycenter = (ymin+ymax)/2;
      context.beginPath();
      context.moveTo(xmin+2, ycenter);
      context.lineTo(xmax-2, ycenter);
      context.lineWidth = 1;
      context.stroke();

      context.beginPath();
      context.moveTo(xcenter, ymin+2);
      context.lineTo(xcenter, ymax-2);
      context.lineWidth = 1;
      context.stroke();
    }
    collapse(context)
    {
      context.beginPath();
      var center = (ymin+ymax)/2;
      context.moveTo(xmin+2, center);
      context.lineTo(xmax-2, center);
      context.lineWidth = 1;
      context.stroke();
    }
}



class tree
{
   treenode root;
   List<treenode> nodes;
   int ypos;
   int rootx;
   int rooty;
   var context;
   var canvas;
   List<List<String>> paths;
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
     paths = new List<pathNode>();
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
      if(node.id.length < 14) {
        for (int i = 0;i < 3;i++) {
          node.children.add(node.id + i.toString());
          treenode childnode = new treenode(node.id + i.toString(), []);
          generate(childnode);
        }
      }

   }
   void writetext()
   {
      ypos = rooty;
      //root.show=true;
      writetexthelper(root,rootx,rooty);
   }

   void writetexthelper(treenode node,int x,int y)
   {

       context.font = 'thin 17pt RobotoDraft';
       context.fillText(node.id, x, y);
       int boxsize = 5;
       int xbox = x - boxsize-boxsize;
       int ybox = y - 3;


       node.xmin = xbox - boxsize;
       node.xmax = xbox + boxsize;
       node.ymin = ybox - boxsize;
       node.ymax = ybox + boxsize;

       if(node.children.length > 0)
       {
         node.draw(context);
         if(node.show)
         {
           node.collapse(context);
         }
         else
         {
           node.expand(context);
         }
       }
       if(node.show)
       {

         for (String id in node.children)
         {
           ypos = ypos + 14;
           treenode childnode = nodes.firstWhere((treenode i) => i.id == id);
           writetexthelper(childnode, x + 10,ypos);
         }
       }

   }

   void searchTreeHelp(treenode node,List<String> currpath)
   {
     List<treenode> parents = nodes.where((treenode i) => i.children.contains(node.id)).toList();
     currpath.add(node.id);
     if(parents.length == 0)
     {
       paths.add(currpath);
     }
     else
     {
       searchTreeHelp(parents[0],currpath);
       for (var i = 1;i < parents.length;i++)
       {
         List<String> newpath = new List<String>();
         newpath.addAll(currpath);
         searchTreeHelp(parents[i],newpath);
       }
     }
   }
   void searchTree(String searchText)
   {
     paths.clear();
     //paths.pathList.add(new List<string>());
     treenode start =  nodes.firstWhere((treenode i) => i.id.startsWith(searchText),orElse:()=>null);
     if(start!=null)
     {
       searchTreeHelp(start,new List<String>());
     }
   }
}