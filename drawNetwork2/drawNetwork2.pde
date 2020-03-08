import java.util.List;
import java.util.Collections;

List<Tensor> tensors;
List<Link> links;
Link curLink;
Tensor test;
Grid grid;
//hotkeys gklLpoOs
String tensorKeys = "wuvbhr"; //square MERA
//String tensorKeys = "dcfv"; //cnot MERA
//String tensorKeys = "abchzx";
boolean dragging = false;
boolean makeLine = false;
boolean clicking = false;
boolean cutting = false;
boolean threeD = false;
boolean pause = false;
boolean debug = false;
int countD = 0;
int generateIndex = 7; int opPosIndex =0; int opRotIndex = 0;
int layer;
int z, dz;
int camr;
float phView = 0; float thView = 0;
int lastMouseX = 0; int lastMouseY = 0;
String lastFile = "~/sketchbook/testreduce";
//PImage img;
void settings() {
  if(threeD) {
    size(700,700,P3D);
  }else{
    size(700,700,P3D);
  }
}
void setup()
{
  
  PFont f = createFont("Georgia", 48);
  textFont(f);
  grid = new Grid(4,4,200,.5,true);
  camr = grid.dz*5;
  //dz = 200;
  layer = 0;
  tensors = new ArrayList<Tensor>();
  links = new ArrayList<Link>();
  //tensors.add(new Tensor("u",grid.xo,grid.yo,0,false));
  //tensors.add(new Tensor("vv",grid.xo,grid.yo,0));
  //img = loadImage("metal.jpg");
  selectInput("Select a file to process:", "loadTensorsDialogue");
  //loadTensors(lastFile);
}
void draw()
{
  background(0);
  //draw grid
  if(!threeD)
    grid.draw();
  //camera controls
  if(threeD)
  {
     if(mousePressed)
     {
       updateCamera();
     }else{
       lastMouseX = mouseX; lastMouseY = mouseY;
     }
  }
  for(Tensor tensor : tensors)
  {
    if(threeD)
    {
      tensor.draw3D(z);
    }else{
      tensor.draw(z);
      if(mousePressed && !dragging && !makeLine)
        if(tensor.z == z)
          dragging = tensor.initDrag();
      if(tensor.dragging)
        tensor.drag();
      if(!mousePressed)
      {
        tensor.dragging = false;
        dragging = false;
        clicking = false;
      }
    }
  }
  if(threeD)
    for(Link link : links)
      link.draw3D();
  text(layer,50,50);
}
void makeLinks()
{
  while(links.size() > 0)
    links.get(0).kill();
  links = new ArrayList<Link>();
  for(Tensor tensor : tensors)
  {
    int t0 = (tensors.indexOf(tensor) + 1)%tensors.size();
   
    for(int outi=0;outi<tensor.outputs;outi++)
    {
      boolean linkFound = false;
      int t=t0;
      while(!linkFound)
      {
        Tensor tensor2 = tensors.get(t);
        //check tensors above starting tensor
        //if(tensor2.z > tensor.z)
        if(true);
        {
          //loop through second tensor's inputs
          for(int ini = 0;ini<tensor2.inputs && !linkFound;ini++)
          {
            //check if input and output overlap
            PVector outloc = tensor.outlocs[outi].get();
            outloc.add(new PVector(tensor.x,tensor.y));
            PVector inloc = tensor2.inlocs[ini].get();
            inloc.add(new PVector(tensor2.x,tensor2.y));
            //if input and output locations are smaller than
            //this number, consider them to be overlapping
              if(grid.distance(inloc,outloc)<sqrt(2)/4)
              {
                links.add(new Link(tensor2,tensor,ini,outi));
                linkFound = true;
              }
           }
        }
        t++;
        t = t%tensors.size(); //loop in z
        if(t == t0)
          break;
      }
    }
  }
}
void printNames()
{
  print("{");
  for(int t=0;t<tensors.size();t++)
  {
   if(!tensors.get(t).outTensor) //don't print output tensor
   {
     print(tensors.get(t).name); 
     if(t < tensors.size() -1)
       print(",");
   }
  }
  println("};");
}
//needs to be rewritten to be comprehensible
void printNetwork()
{ 
  print("{");
  int freeIndex = -1;
  for(int t=0;t<tensors.size();t++)
  {
    Tensor cur = tensors.get(t);
    if(!cur.outTensor) //don't print output tensor
    {
      print("[");
      String inString = "";
      for(Link curLink : cur.inlinks)
      {
        //this should be phased out
        if(curLink == null) //if link isn't attached to anything, it's free
        {
          println("This is bad!");
          inString += freeIndex + " ";
          freeIndex --;
        }else{
          //enumerate network outputs
          if(curLink.B.outTensor)
          {
            
            //interchange link order for flipped tensors
            if(curLink.B.name.endsWith("conj"))
              inString += "-" + (curLink.portB+1) + " ";
            else
              inString += "-" + (curLink.portB+curLink.B.inputs+1) + " ";
          }else{ //display link #
            inString +=(links.indexOf(curLink)+1) + " ";
          }
        }
      }
      String outString = "";
      for(Link curLink : cur.outlinks)
      {
        if(curLink == null)
        {
          println("This is bad!");
          outString += freeIndex + " ";
          freeIndex --;
        }else{
          //enumerate network outputs
          if(curLink.A.outTensor)
          {
            //interchange link order for flipped tensors
            if(curLink.A.name.endsWith("conj"))
              outString += "-" + (curLink.portA+curLink.A.outputs+1) + " ";
            else
              outString += "-" + (curLink.portA+1) + " ";
          }else{ //display link #
            outString += (links.indexOf(curLink)+1) + " ";
          }
        }
      }
      if(cur.name.endsWith("conj")) //if conjugated flip input, outputs
        print(outString + inString.trim()); //trim removes last unnecessary space
      else
        print(inString + outString.trim());  
      print("]");
      if(t < tensors.size()-1)
        print(",");
    }
  }
  print("}");
}
//Remove tensor/conjugate pairs
void reduceDiagram()
{
  if(debug)
    println("Reduce");
  boolean kill = false;
  do{
    kill = false;
  for(Tensor tensor : tensors)
  {
    Tensor killTarget = null;
    //loop over links connected to inputs
    if(!tensor.name.endsWith("conj"))
    {
      int nMatches = 0;
      for(int input=0; input< tensor.inputs;input++)
      {
        //count number of matching inputs/outputs
        if(tensor.inlinks[input] != null)
        {
          Link curLink = tensor.inlinks[input];
          Tensor connectedTensor = curLink.B;
          //if input port number matches output port number
          //print(curLink.portB + " " + input + " ");
          //print(curLink.B.name);
          if(curLink.portB == input &&
            connectedTensor.name.equals(tensor.name + "conj"))
          {
           // print(" match");
            nMatches ++;
            killTarget = connectedTensor;
          }
          //println("");
        }
      }
      if(nMatches == tensor.inputs)
        {
          kill = true;
          if(debug)
            println("Removed " + tensor.name + " and " + killTarget.name);
          tensor.kill();
          killTarget.kill();
          makeLinks();
          break;
        }
    }
  }}while(kill);
  
}
void insertTensor(Tensor tensor, int zpos)
{
  int t=0;
  for(t = 0;t < tensors.size();t++)
  {
    if(zpos < tensors.get(t).z)
      break;
  }
   tensors.add(t,tensor);
}
void generateDiagram(int i, int j,int rot)
{
  if(debug)
    println("index " + i + "," + j);
  loadTensors(lastFile);
  
  //do nothing if i exceeds tensor list length
  if(i >= tensors.size())
    return;
  Tensor tensor = tensors.get(i);
  float xpos = j%4 - 2;
  float ypos = j/4 - 2;
  String isometryNames = "abc";
  if(isometryNames.indexOf(tensor.name)!= -1)
  {
    tensor.outTensor = true;
    int t=0;
    for(t = 0;t < tensors.size();t++)
    {
      if(z < tensors.get(t).z)
        break;
    }
    //Tensor operator =new Tensor("z",xpos,ypos,0,false); 
    Tensor operator = new Tensor("x",xpos,ypos,0,false);
    insertTensor(operator,0);
    //if(rot == 1)
    //  operator.rotate(PI/2);
    makeLinks();
    reduceDiagram();
    //check if the output tensor is still in the diagram
    if(tensors.contains(tensor))
    {
      //printNames();
      printNetwork();
      countD ++;
      //println(countD);
      println("");
    }
    opPosIndex ++;
    if(opPosIndex < grid.nx*grid.ny)
      return;
    //if(rot == 0)
    //{
    //  opRotIndex = 1; opPosIndex = 0; return;
    //}
  }
  opPosIndex = 0;
  opRotIndex = 0;
  generateIndex ++;
}
void generateDiagrams()
{
  generateDiagram(generateIndex,opPosIndex,opRotIndex);
}
void generateDiagramsSquareMERA()
{
  Tensor h = tensors.get(0); //for initialization only
  Tensor rho = tensors.get(0);
  //find tensors
  for(Tensor tensor : tensors)
  {
    if(tensor.name.equals("h"))
      h = tensor;
    if(tensor.name.equals("r"))
      rho = tensor;
    tensor.outTensor = false;
  }
  float xo = h.x; float yo = h.y;
  //ascender (need to flip outputs or replace rho with flipped)
  // ...or not? get correct eigenvalues for ascender with unflipped rho
  int rhoIndex = tensors.indexOf(rho);
  int hIndex = tensors.indexOf(h);
  tensors.set(rhoIndex,new Tensor("r",rho.x,rho.y,rho.z,true)); 
  rho = tensors.get(rhoIndex);
  rho.outTensor = true;
  //println(rho.name);
  println("%Ascender");
  printNames();
  println("{ ...");
  moveHPrint(h,xo,yo);
  println("};");
  //unflip rho
  tensors.set(rhoIndex,new Tensor("r",rho.x,rho.y,rho.z,false)); 
  rho = tensors.get(rhoIndex);
  //flip h
  tensors.set(hIndex,new Tensor("h",h.x,h.y,h.z,true)); 
  h = tensors.get(hIndex);
  //descender
  rho.outTensor = false;
  h.outTensor = true;
  println("%Descender");
  printNames();
  println("{ ...");
  moveHPrint(h,xo,yo);
  println("};");
  //unflip h
  tensors.set(hIndex,new Tensor("h",h.x,h.y,h.z,false)); 
  h = tensors.get(hIndex);
  h.outTensor = false;
  boolean startu = false;
  boolean startw = false;
  boolean startv = false;
  moveHPrint(h,xo,yo);
  //environments
//  for (Tensor tensor: tensors)
//  {
//    if(tensor.name.equals("u") || tensor.name.equals("w"))
//    {
//      tensor.outTensor = true;
//      if(tensor.name.equals("u") && !startu)
//      {
//        println("%" + tensor.name + " environment");
//        printNames();
//        startu = true;
//      }
//      if(tensor.name.equals("w") && !startw)
//      {
//        println("%" + tensor.name + " environment");
//        printNames();
//        startw = true;
//      }
//      println("{ ...");
//      moveHPrint(h,xo,yo);
//      println("};");
//      tensor.outTensor = false;
//    }
//    if(tensor.name.equals("vh") || tensor.name.equals("vv"))
//    {
//      tensor.outTensor = true;
//      if(!startv)
//      {
//        println("%" + tensor.name + " environment");
//        printNames();
//        startv = true;
//      }
//      println("{ ...");
//      moveHPrint(h,xo,yo);
//      println("};");
//      tensor.outTensor = false;
//    }
//  }
}
void moveHPrint(Tensor h, float xo, float yo)
{
  for(int sx = -1; sx <= 1; sx++)
  for(int sy = -1; sy <= 1; sy++)
  {
    h.x = xo + sx;
    h.y = yo + sy;
    makeLinks(); 
    printNetwork();
    if(sx < 1 || sy < 1)
      println(", ...");
  }
}
void updateCamera()
{
  float th = 1.*mouseX/200;
   float ph = 1.*mouseY/200;
   //camera location vector
//   PVector cloc = new PVector(0,0,camr);
//   PVector locxz = new PVector(cloc.x,cloc.z);
//   locxz.rotate(ph);
//   cloc = new PVector(locxz.x,cloc.y,locxz.y);
//   PVector locxy = new PVector(cloc.x,cloc.y);
//   locxy.rotate(th);
//   cloc = new PVector(locxy.x,locxy.y,cloc.z);
  //composed xz.yz rotations
   PVector cloc = new PVector(camr*cos(th)*sin(ph),camr*cos(ph),camr*sin(ph)*sin(th));
   camera(grid.xo+cloc.x,grid.yo+cloc.y,cloc.z,
     grid.xo,grid.yo,0,0,1,0);
   thView = th; phView = ph;
   
}
void waitForEnter()
{
  println("pause");
  pause = true;
  while(!mousePressed)
  {
    
  }
  pause = false;
  println("unpause");
}
void keyPressed()
{
  //add tensor if key pressed is a valid key
  char keylow = Character.toLowerCase(key);
  if(tensorKeys.indexOf(keylow) != -1)
  {
    String name = String.valueOf(keylow);
    //flip tensor if upper case key is used
    boolean flip = !Character.isLowerCase(key);
    /* rework this to be more natural
    if(keylow == 'v')
      name = "vh";
    if(keylow =='b')
      name = "vv";
    */
    int t=0;
    for(t = 0;t < tensors.size();t++)
    {
      if(z < tensors.get(t).z)
        break;
    }
    tensors.add(t,
      new Tensor(name,grid.toGridSnap(mouseX,mouseY).x,
        grid.toGridSnap(mouseX,mouseY).y,z,flip));
  }
  //rotate dragged tensor
  if(key == ']' || key == '[')
  {
    for(Tensor tensor : tensors)
    {
      if(tensor.dragging)
      {
        float angle=0;
        if(key == '[')
          angle = -PI/4;
        if(key == ']')
          angle = PI/4;
        tensor.rotate(angle);
      }
    }
  }
  //kill tensor
  if(key == 'k')
  {
    for(Tensor tensor : tensors)
     if(z == tensor.z)
       if(tensor.checkHover())
         {
           tensor.kill();
           break;
         }
  }
  if(key == 'O')
  {
    for(Tensor tensor : tensors)
    {
      tensor.outTensor = false;
      if(z == tensor.z)
        if(tensor.checkHover())
        {
          tensor.outTensor = true;
        }
    }
  }
  if(key == 'l')
    makeLinks();
  if(key == 'p')
  {
    printNames();
    printNetwork();
  }
  if(key == 'g')
    generateDiagrams();
  //load
  if(key == 'o')
  {
    selectInput("Select tensor file:", "loadTensorsDialogue");
  }
  if(key == '0')
  {
    loadTensors(lastFile);
  }
  if(key == 'L')
  {
    selectInput("Select link file:", "loadLinks");
  }
  //save (print positions of tensors)
  if(key == 's')
  {
    for(Tensor tensor : tensors)
    {
      print(tensor.x + "," + tensor.y + "," + tensor.z + ";");
    }
    println("");
    //print orientations of tensors
    for(Tensor tensor : tensors)
    {
      print(tensor.orientation + ";");
    }
    println("");
  }
  if(key == 'r')
    reduceDiagram();
  if(keyCode == UP)
  {
    layer ++;
    z = layer;
  }
  if(keyCode == DOWN)
  {
    layer --;
    z = layer;
  }
  if(keyCode == '3')
  {
    threeD = true;
    //setup();
  }
  if(keyCode == '2')
  {
    threeD = false;
    camera();
    //setup();
  }
  if(keyCode == ENTER)
  {
    println("enter");
    pause = false;
  }
}
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if(e > 0)
    camr += grid.dz/10;
  else
    camr -= grid.dz/10;
  updateCamera();
}

void readTensor(String name)
{
  boolean flip = false;
  //String validNames = "wuvhvvhrcd";
  if(name.endsWith("conj"))
    {
    flip = true;
    name = name.substring(0,name.length() - 4);
    }
  tensors.add(new Tensor(name,0,0,0,flip));
}
void loadTensorsDialogue(File selection)
{
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    String fileName = selection.getAbsolutePath();
    loadTensors(fileName);
    lastFile = fileName;
  }
}
void loadTensors(String fileName) {

  //clear all
  tensors = new ArrayList<Tensor>();
  links = new ArrayList<Link>();
  int index =0;
  
  String[] lines = loadStrings(fileName);
  while(index < lines.length)
  {
    String line = lines[index];
    if(index == 0)
    {
      if(debug)
        println("read tensors");
     String[] curt = splitTokens(lines[index],"{},;");
     for(int t=0;t<curt.length;t++)
     { 
       //boolean made = makeTensor(curt[t]);
       readTensor(curt[t]);
     }
     if(debug)
       println(tensors.size() + " tensors");
    }
    //place tensors at recorded positions
    if(index==2)
    {
      if(debug)
        println("Placing tensors");
      String[] curt = split(lines[index],";");
      if(curt.length - 1 != tensors.size())
        println("ERROR: " + tensors.size() + " tensors found but " + (curt.length-1) + " positions found");
      if(curt.length > 1)
        for(int t=0;t<curt.length;t++)
        {
          String[] coord = split(curt[t],",");
          if(coord.length == 3)
          {
            Tensor curTensor = tensors.get(t);
            curTensor.x = float(coord[0]);
            curTensor.y = float(coord[1]);
            curTensor.z = int(coord[2]);
          }
        }
    }
    //rotate tensors to specified orientations
    if(index == 3)
    {
      if(debug)
        println("Rotating tensors");
      String[] curt = split(lines[index],";");
      if(curt.length - 1 != tensors.size())
        println("ERROR: " + tensors.size() + " tensors found but " + (curt.length-1) + " orientations found");
      if(curt.length > 1)
        for(int t=0;t<curt.length-1;t++)
        {
          Tensor curTensor = tensors.get(t);
          curTensor.orientation = float(curt[t]);
          curTensor.rotate(curTensor.orientation*PI);
        }
    }
    index ++;
  }
}

void loadLinks(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    int index =0;
    String fileName = selection.getAbsolutePath();
    String[] lines = loadStrings(fileName);
    while(index < lines.length)
    {
      String line = lines[index];
      if(index == 1)
        readLinks(line);
      index ++;
    }
  }
}
void readLinks(String line)
{
    println("read links");
     //clear all links
    links = new ArrayList<Link>();
    String[] allLinks = splitTokens(line,"{}[], ");
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
    //declare lists for output tensor
    List<PVector> Oinlocs = new ArrayList<PVector>(); List <PVector> Ooutlocs = new ArrayList<PVector>();
    List<Link> Oinlinks = new ArrayList<Link>(); List<Link> Ooutlinks =  new ArrayList<Link>();
    List<Integer> Oinlabels = new ArrayList<Integer>(); List<Integer> Ooutlabels = new ArrayList<Integer>();
    int zLower = -99999;
    String[] curt = splitTokens(line,"{}[],"); //split string into lists of links
    //loop through each list of tensor links, [a b c d]
    println("curt lenghth: " + curt.length);
    for(int t=0;t<curt.length;t++)
    {
      Tensor curTensor = tensors.get(t);
      boolean curFlipped = curTensor.name.endsWith("conj");
      String[] curL = split(curt[t]," ");
      println(curL);
      if(curL.length != curTensor.inputs + curTensor.outputs)
        println("Wrong tensor length");
      //loop through links attached to inputs
      int j0=0;
      if(curFlipped) j0 = curTensor.outputs; else j0 = 0;
      for(int j = j0; j < j0 + curTensor.inputs; j++)
      {
        int linknum = int(curL[j]);
        if(linknum > -1)
        {
          Link thislink = links.get(linknum-1); //index of link = # of link in string - 1
          if(thislink.A == null)
          {
            thislink.A = curTensor;
            thislink.portA = j-j0;
            curTensor.inlinks[thislink.portA] = thislink;
          }
        }else{ //if this is a negative number, add output to construction of output tensor
          int label = -int(curL[j])-1;
          Link thislink = new Link();
          links.add(thislink); //make new link to connect to output tensor
          
          thislink.A = curTensor; thislink.portA = j - j0;
          curTensor.inlinks[thislink.portA] = thislink;
          
          Ooutlabels.add(label); Ooutlinks.add(thislink);
          PVector loc = curTensor.inlocs[thislink.portA].get();
          loc.add(new PVector(curTensor.x,curTensor.y));
          Ooutlocs.add(loc);
          println("TEST");
          println(curTensor.name);
          println(curTensor.inlocs[thislink.portA].x);
        }
      }
      println("outputs");
      //loop through links attached to outputs
      if(!curFlipped) j0 = curTensor.inputs; else j0 = 0;
      for(int j = j0; j < j0 + curTensor.outputs; j++)
      {
        int linknum = int(curL[j]);
        if(linknum > -1)
        {
            Link thislink = links.get(linknum-1);
            if(thislink.B == null)
            {
              thislink.B = curTensor;
              thislink.portB = j-j0;
              curTensor.outlinks[thislink.portB] = thislink;
            } 
        }else{ //add input to construction of output tensor
          int label = -int(curL[j])-1;
          Link thislink = new Link();
          links.add(thislink); //make new links to connect to output tensor
          
          thislink.B = curTensor; thislink.portB = j - j0;
          curTensor.outlinks[thislink.portB] = thislink;
          
          Oinlabels.add(label); Oinlinks.add(thislink);
          PVector loc = curTensor.outlocs[thislink.portB].get();
          loc.add(new PVector(curTensor.x,curTensor.y));
          Oinlocs.add(loc);
          if(curTensor.z > zLower)
            zLower = curTensor.z;
        }
      }
    }
    //construct output tensor, if applicable
    if(Oinlabels.size() > 0)
    {
      println("build output tensor");
      int inputs = Oinlabels.size();
      int outputs = Ooutlabels.size();
      String name;
      if(Collections.min(Oinlabels) == 0)//regular ordering (input labels are smaller)
      { 
        name = "out";
        for(int i=0;i<outputs;i++)
          Ooutlabels.set(i,Ooutlabels.get(i) - inputs);
      }
      else //conjugate ordering (output labels are smaller)
      {
        name = "outconj";
        for(int i=0;i<inputs;i++)
          Oinlabels.set(i,Oinlabels.get(i) - outputs);
      }
      //debug
      println("inlabel");
      for(int l: Oinlabels)
        println(l);
      println("outlabel");
      for(int l: Ooutlabels)
        println(l);
      println("unsorted inlocs");
      for(PVector p : Oinlocs)
        println(p.x);
      println("unsorted outlocs");
      for(PVector p : Ooutlocs)
        println(p.x);
      //sort links by label
      List<PVector> inlocs = new ArrayList<PVector>(); List <PVector> outlocs = new ArrayList<PVector>();
      List<Link> inlinks = new ArrayList<Link>(); List<Link> outlinks =  new ArrayList<Link>();
      println("inlocs");
      for(int i=0; i< inputs;i++)
      {
        inlocs.add(Oinlocs.get(Oinlabels.indexOf(i)));
        inlinks.add(Oinlinks.get(Oinlabels.indexOf(i)));
        println(Oinlocs.get(Oinlabels.indexOf(i)).x);
      }
      println("outlocs");
      for(int i=0; i< outputs;i++)
      {
        outlocs.add(Ooutlocs.get(Ooutlabels.indexOf(i)));
        outlinks.add(Ooutlinks.get(Ooutlabels.indexOf(i)));
        println(Oinlocs.get(Oinlabels.indexOf(i)).x);
      }
      Tensor outputTensor = new Tensor(inlinks,outlinks,inlocs,outlocs,zLower,name);
      outputTensor.outTensor = true;
      int t=0;
      for(t = 0;t < tensors.size();t++)
      {
        if(outputTensor.z < tensors.get(t).z)
          break;
      }
      tensors.add(t,outputTensor);
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
