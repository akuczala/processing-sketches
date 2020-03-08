class Tensor
{
  int x,y;
  //int xSize = 100;int ySize = 50;
  int xSize = 70;int ySize = gridy;
  int inputs, outputs; //number of inputs and outputs (determining tensor rank)
  String name;
  color fillColor;
  Link[] portlinks;
  boolean makeLine = false; //flag for currently adding a link
  boolean killMe = false;
  int linePort = 0;
  boolean dragging = false; //flag for currently being dragged by mouse
  boolean flip = false; //tensor should behave as its conjugate transpose
  
  Tensor(int x,int y)
  {
    this.x = x; this.y = y;
    inputs = 2; outputs = 2;
    xSize = gridx;
    name = "u";
    this.portlinks = new Link[inputs+outputs];
  }
  Tensor(int x, int y, int inputs, int outputs)
  {
    this.x = x; this.y = y;
    this.xSize = gridx*(max(inputs,outputs)-1);
    
    this.inputs = inputs; this.outputs = outputs;
    this.portlinks = new Link[inputs+outputs];
    fillColor = color(100,100,100);
  }
  void kill() //destroy tensor
  {
    //kill attached links
    for(int i=0;i<inputs+outputs;i++)
      if(portlinks[i] != null)
        portlinks[i].kill();
    //remove tensor
    tensors.remove(tensors.indexOf(this));
  }
  void draw()
  {
    fill(fillColor);
    if(outputs == 1) //draw tensors with one output as a triangle
    {
      
      if(!flip)
      {
      triangle(x,y+ySize,x+xSize/2,y,x+xSize,y+ySize);
      }else{
      triangle(x,y,x+xSize/2,y+ySize,x+xSize,y);
      }
    }
    //draw tensors with more than one input and output as a rectangle
    if( !((outputs == 1)^(inputs == 1)))
    {
      //fill(0,255,0);
    rect(x,y,xSize,ySize);
    }
    
    //draw tensor ports
    fill(255);
    text(name,x+xSize/2.5,y+ySize/2);
    for(int i=0;i<inputs+outputs;i++)
    {
      fill(100,100,100);
      PVector loc = portLoc(i);
      ellipse(loc.x,loc.y,PORTSIZE,PORTSIZE);
    }
  }
  //compute location of each port
  PVector portLoc(int portNum)
  {
    int iny; int outy;
    if(!flip)
    {
      iny = y+ySize; outy = y;
    }else{
      iny = y; outy = y+ySize;
    }
    if(portNum < inputs)
    {
      if(inputs == 1)
      return new PVector(x + xSize/2,iny);
      else
      return new PVector(x + xSize/(inputs-1)*portNum,iny);
    }
    if(portNum >= inputs)
    {
      if(outputs == 1)
      return new PVector(x + xSize/2,outy);
      else
      return new PVector(x + xSize/(outputs-1)*(portNum-inputs),outy);
    }
    return new PVector(0,0);
  }
  //start dragging
  boolean initDrag()
  {
    if(mouseX < x+xSize && mouseX > x 
      && mouseY < y+ySize && mouseY > y)
      {
        dragging = true;
        //println("DRAG");
        return true;
      }
      return false;
      
  }
  //detect mouse hover
  boolean hoverOver()
  {
    if(mouseX < x+xSize && mouseX > x 
      && mouseY < y+ySize && mouseY > y)
      {
        return true;
      }
      return false;
      
  }
  void drag()
  {
    this.x = ((mouseX - xSize/2)/gridx)*gridx;
    this.y = ((mouseY - ySize/2)/gridy)*gridy;
  }
  boolean startLink()
  {
    for(int i=0;i<inputs+outputs;i++)
    {
      PVector loc = portLoc(i);
      int Dx = mouseX-(int)(loc.x);
      int Dy = mouseY-(int)(loc.y);
      if(Dx*Dx+Dy*Dy < PORTSIZE*PORTSIZE)
      {
        if(portlinks[i] == null)
        {
          links.add(new Link(this,i));
          portlinks[i] = links.get(links.size()-1);
          return true;
        }
      }
    }
    return false;
  }
  boolean endLink()
  {
    for(int i=0;i<inputs+outputs;i++)
    {
      PVector loc = portLoc(i);
      int Dx = mouseX-(int)(loc.x);
      int Dy = mouseY-(int)(loc.y);
      if(Dx*Dx+Dy*Dy < PORTSIZE*PORTSIZE)
      {
        if(portlinks[i] == null)
        {
        links.get(links.size()-1).B = this;
        links.get(links.size()-1).portB = i;
        portlinks[i] = links.get(links.size()-1);
        return false;
        }
        
      }
    }
    
    return true;
    
  }
}
