import java.util.List;
import java.util.Map;

List<Tensor> tensors;
List<Link> links;
Link curLink;
Tensor test;
int n;
boolean dragging = false;
boolean makeLine = false;
boolean clicking = false;
boolean cutting = false;
boolean flipConvention = false;
int gridx, gridy;
int nsites = 20;
static final int PORTSIZE = 10;

void setup()
{
  size(800,800);
  gridx = width/nsites; gridy = height/nsites;
  PFont f = createFont("Georgia", 24);
  textFont(f);
  tensors = new ArrayList<Tensor>();
  links = new ArrayList<Link>();

}

void draw()
{
  background(0);
  fill(255);
  //draw grid
  for(int i=0;i<nsites;i++)
  for(int j=0;j<nsites;j++)
    ellipse(i*gridx,j*gridy,gridx/8,gridy/8);
  if(cutting)
    text("CUT",50,50);
  
  //draw tensors
  for(Tensor cur : tensors)
  {
    cur.draw();
    if(mousePressed && makeLine && !clicking)
    {
      makeLine = cur.endLink();
      clicking = !makeLine;
    }
    if(mousePressed && !dragging && !makeLine && !clicking)
    {
      makeLine = cur.startLink();
      clicking = makeLine;
    }
    if(mousePressed && !dragging && !makeLine)
      dragging = cur.initDrag();
    if(cur.dragging)
      cur.drag();
    if(!mousePressed)
    {
      cur.dragging = false;
      dragging = false;
      clicking = false;
    }
      
  }
  //draw links
  int cutIndex = -1;
  for(Link link:links)
  {
    link.draw();
    if(cutting)
      if(cutIndex == -1)
        cutIndex = link.cut();
  }
  if(cutting)
  {
    
    if(cutIndex > -1)
    {
      println(cutIndex);
      links.get(cutIndex).kill();
    }
  }
   //display link convention
   fill(255);
   if(flipConvention)
   { 
     text("1 2",width-50,20);
     text("3 4",width-50,45);
   }else{
     text("3 4",width-50,20);
     text("1 2",width-50,45);
   }
  
}

boolean makeTensor(String name)
{
  if(name.compareTo("w")==0)
  {
   tensors.add(new Tensor(mouseX,mouseY,3,1));
   tensors.get(tensors.size()-1).name = "w";
   tensors.get(tensors.size()-1).fillColor = color(255,0,0);
   return true;
  }
  if(name.compareTo("wdag")==0)
  {
   tensors.add(new Tensor(mouseX,mouseY,3,1));
   tensors.get(tensors.size()-1).name = "wdag";
   tensors.get(tensors.size()-1).flip = true;
   tensors.get(tensors.size()-1).fillColor = color(255,0,0);
   return true;
  }
  if(name.compareTo("v")==0)
  {
   tensors.add(new Tensor(mouseX,mouseY,2,1));
   tensors.get(tensors.size()-1).name = "v";
   tensors.get(tensors.size()-1).fillColor = color(255,0,0);
   return true;
  }
  if(name.compareTo("vdag")==0)
  {
   tensors.add(new Tensor(mouseX,mouseY,2,1));
   tensors.get(tensors.size()-1).name = "vdag";
   tensors.get(tensors.size()-1).flip = true;
   tensors.get(tensors.size()-1).fillColor = color(255,0,0);
   return true;
  }
  if(name.compareTo("u")==0)
  {
   tensors.add(new Tensor(mouseX,mouseY,2,2));
   tensors.get(tensors.size()-1).name = "u";
   tensors.get(tensors.size()-1).fillColor = color(0,255,0);
   return true;
  }
  if(name.compareTo("udag")==0)
  {
   tensors.add(new Tensor(mouseX,mouseY,2,2));
   tensors.get(tensors.size()-1).name = "udag";
   tensors.get(tensors.size()-1).flip = true;
   tensors.get(tensors.size()-1).fillColor = color(0,255,255);
   return true;
  }
  if(name.compareTo("o")==0)
  {
   tensors.add(new Tensor(mouseX,mouseY,1,1));
   tensors.get(tensors.size()-1).name = "o";
   tensors.get(tensors.size()-1).fillColor = color(0,0,255);
   return true;
  }
  if(name.compareTo("h")==0)
  {
   tensors.add(new Tensor(mouseX,mouseY,2,2));
   tensors.get(tensors.size()-1).name = "h";
   tensors.get(tensors.size()-1).fillColor = color(0,0,255);
   return true;
  }
  if(name.compareTo("rho")==0)
  {
   tensors.add(new Tensor(mouseX,mouseY,2,2));
   tensors.get(tensors.size()-1).name = "rho";
   tensors.get(tensors.size()-1).fillColor = color(100,100,100);
   return true;
  }
  if(name.compareTo("three")==0)
  {
   tensors.add(new Tensor(mouseX,mouseY,3,3));
   tensors.get(tensors.size()-1).name = "three";
   tensors.get(tensors.size()-1).fillColor = color(255,200,100);
   return true;
  }
  return false;
}

void keyReleased()
{
  if(key == 'c')
    cutting = false;
}

void keyPressed()
{
  //tensor creation
  if(key == 'w')
    makeTensor("w");
  if(key == 'W')
    makeTensor("wdag");
  if(key == 'v')
    makeTensor("v");
  if(key == 'V')
    makeTensor("vdag");
  if(key == 'u')
    makeTensor("u");
  if(key == 'U')
    makeTensor("udag");
  if(key == 'o')
    makeTensor("o");
  if(key == 'h')
    makeTensor("h");
  if(key == 'r')
    makeTensor("rho");
  if(key == '3')
    makeTensor("three");
  //kill current link
  if(key == 'c')
  {
    if(makeLine == true)
    {
      links.get(links.size()-1).kill();
    
    makeLine = false;
    }else{
      cutting = true;
    }
  }
  //kill tensor
  if(key == 'k')
  {
    int killIndex = -1;
    for(int t=0;t<tensors.size();t++)
    {
      if(killIndex == -1)
        if(tensors.get(t).hoverOver())
          killIndex = t;
    }
    if(killIndex>-1)
      tensors.get(killIndex).kill();
  }
  //save (print positions of tensors)
  if(key == 's')
  {
    for(int t=0;t<tensors.size();t++)
    {
      print(tensors.get(t).x + "," + tensors.get(t).y + ";");
    }
    println("");
  }
  //load
  if(key == 'l')
  {
    selectInput("Select a file to process:", "fileSelected");
  }
  //print links
  if(key == 'p')
  {
    print("{");
    for(int t=0;t<tensors.size();t++)
    {
     print(tensors.get(t).name); 
     if(t < tensors.size() -1)
       print(",");
    }
    println("}");
    print("{");
    int freeIndex = -1;
    for(int t=0;t<tensors.size();t++)
    {
      Tensor cur = tensors.get(t);
      print("[");
      for(int l=0; l < cur.portlinks.length;l++)
      {
        Link curLink = cur.portlinks[l];
        if(curLink == null)
        {
          print(freeIndex);
          freeIndex --;
        }else{
        print((links.indexOf(curLink)+1));
        }
        if(l < cur.portlinks.length-1)
          print(" ");
      }
      print("]");
      if(t < tensors.size()-1)
        print(",");
    }
    println("}");
  }
}
//build tensor network from file
void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    //clear all
    tensors = new ArrayList<Tensor>();
    links = new ArrayList<Link>();
    int index =0;
    String fileName = selection.getAbsolutePath();
    String[] lines = loadStrings(fileName);
    while(index < lines.length)
    {
      String line = lines[index];
      if(index == 0)
      {
        println("read tensors");
         String[] curt = splitTokens(lines[index],"{},;");
         for(int t=0;t<curt.length;t++)
         { 
           boolean made = makeTensor(curt[t]);
           if(made)
           {
             Tensor cur = tensors.get(tensors.size()-1);
             cur.x = (int)(random(0,width-20));cur.y = (int)(random(0,height-20));
           }
         }
         println(tensors.size() + " tensors");
      }
      
      if(index == 1)
      {
        println("read links");
        links = new ArrayList<Link>();
        String[] allLinks = splitTokens(lines[index],"{}[], ");
        int maxLink = 0;
        for(int i=0;i<allLinks.length;i++)
        {
          int cur = int(allLinks[i]);
          if(cur > maxLink)
            maxLink = cur;
        }
        println(maxLink + " links");
        //make approx correct number of links
        for(int i=0;i<maxLink;i++)
          links.add(new Link());
        String[] curt = splitTokens(lines[index],"{}[],");
        for(int t=0;t<curt.length;t++)
        {
          Tensor curTensor = tensors.get(t);
          String[] curL = split(curt[t]," ");
          println(curL);
          if(curL.length != curTensor.inputs + curTensor.outputs)
            println("Wrong tensor length");
          for(int j=0;j<curL.length;j++)
          {
            int linknum = int(curL[j]);
            if(linknum > -1)
            {
              Link thislink = links.get(linknum-1);
              if(thislink.A == null)
              {
                thislink.A = curTensor;
                thislink.portA = j;
              }else{
                if(thislink.B == null)
                {
                  thislink.B = curTensor;
                  thislink.portB = j;
                } 
              }
              curTensor.portlinks[j] = thislink;
            }
          }
        }
        //kill other links
        int killIndex = -1;
        do{
          killIndex = -1;
          for(int l=0;l<links.size();l++)
          {
            if(links.get(l).A == null)
              killIndex = l;
          }
          if(killIndex != -1)
            links.get(killIndex).kill();
        }while(killIndex != -1);
        //print(links.size());
      }
      //place tensors at recorded positions
      if(index==2)
      {
        String[] curt = split(lines[index],";");
        if(curt.length > 1)
          for(int t=0;t<curt.length;t++)
          {
            String[] coord = split(curt[t],",");
            if(coord.length == 2)
            {
              Tensor curTensor = tensors.get(t);
              curTensor.x = int(coord[0]);
              curTensor.y = int(coord[1]);
            }
          }
      }
      index ++;
    }
  }
}
