class Tensor
{
  float x,y; int z;
  int inputs, outputs;
  PVector[] inlocs, outlocs;
  Link[] inlinks, outlinks;
  PVector[] shapeVerts;
  String name;
  boolean dragging = false;
  float h = 0.5;
  float orientation = 0;
  // specifies if tensor should be treated as output
  boolean outTensor = false;
  color fillColor;
  
  Tensor(String name,float x, float y, int z,boolean flip)
  { 
    if(name.equals("w"))
    {
        //centered on center site
        fillColor = color(255,0,0);
        inputs = 5; outputs = 1;
        inlocs = new PVector[inputs];
        outlocs = new PVector[outputs];
        inlocs[0] = new PVector(-1,0);
        inlocs[1] = new PVector(1,0);
        inlocs[2] = new PVector(0,-1);
        inlocs[3] = new PVector(0,1);
        inlocs[4] = new PVector(0,0);
        outlocs[0] = inlocs[4];
        
        shapeVerts = crossShape();
    }
    if(name.equals("u"))
    {
        //centered on top left vertex
        fillColor = color(0,255,0);
        inputs = 4; outputs = 4;
        inlocs = new PVector[inputs];
        outlocs = new PVector[outputs];
        int dx = grid.dx; int dy = grid.dy;
        inlocs[0] = new PVector(0,0);
        inlocs[1] = new PVector(1,0);
        inlocs[2] = new PVector(0,1);
        inlocs[3] = new PVector(1,1);
        outlocs[0] = new PVector(0.5,0);
        outlocs[1] = new PVector(0,0.5);
        outlocs[2] = new PVector(0.5,1);
        outlocs[3] = new PVector(1,0.5);
        
        shapeVerts = boxShape(1);
        
    }
    if(name.equals("h"))
    {
        //centered on top left vertex
        fillColor = color(0,0,255);
        inputs = 4; outputs = 4;
        inlocs = new PVector[inputs];
        outlocs = new PVector[outputs];
        int dx = grid.dx; int dy = grid.dy;
        inlocs[0] = new PVector(0,0);
        inlocs[1] = new PVector(1,0);
        inlocs[2] = new PVector(0,1);
        inlocs[3] = new PVector(1,1);
        outlocs = inlocs;
        
        shapeVerts = boxShape(1);
    }
    if(name.equals("r"))
    {
        //centered on top left vertex
        fillColor = color(200,100,10);
        inputs = 4; outputs = 4;
        inlocs = new PVector[inputs];
        outlocs = new PVector[outputs];
        int dx = grid.dx; int dy = grid.dy;
        inlocs[0] = new PVector(0,0);
        inlocs[1] = new PVector(3,0);
        inlocs[2] = new PVector(0,3);
        inlocs[3] = new PVector(3,3);
        outlocs = inlocs;
        
        shapeVerts = boxShape(3);
    }
    if(name.equals("vh") || name.equals("vv"))
    {
        //centered on top onsite vertex (for horizontal one)
        fillColor = color(0,255,255);
        inputs = 4; outputs = 2;
        inlocs = new PVector[inputs];
        outlocs = new PVector[outputs];
        int dx = grid.dx; int dy = grid.dy;
        
        inlocs[0] = new PVector(0,0);
        inlocs[1] = new PVector(0,1);
        inlocs[2] = new PVector(-1,0.5);
        inlocs[3] = new PVector(1,0.5);
        outlocs[0] = inlocs[0].get();
        outlocs[1] = inlocs[1].get();
        
        shapeVerts = diamondShape();
        //rotate vectors to get the vertical tensor
        if(name.equals("vv"))
        {
          this.rotate(-PI/2);
        }
    }
    if(name.equals("a"))
    {
      //centered on top onsite vertex (for horizontal one)
      fillColor = color(255,0,0);
      inputs = 2; outputs = 0;
      inlocs = new PVector[inputs];
      outlocs = new PVector[outputs];
      int dx = grid.dx; int dy = grid.dy;
      
      inlocs[0] = new PVector(0.5,0.5);
      inlocs[1] = new PVector(2.5,0.5);
      //outlocs[0] = inlocs[0].get();
      //outlocs[1] = inlocs[1].get();
      
      shapeVerts = rectShape(2);
      //rotate vectors to get the vertical tensor
    }
    if(name.equals("c"))
    {
        //centered on top left vertex
        fillColor = color(0,255,0);
        inputs = 4; outputs = 1;
        inlocs = new PVector[inputs];
        outlocs = new PVector[outputs];
        inlocs[0] = new PVector(0,0);
        inlocs[1] = new PVector(1,0);
        inlocs[2] = new PVector(0,1);
        inlocs[3] = new PVector(1,1);
        outlocs[0] = new PVector(0.5,0.5);
        
        shapeVerts = boxShape(1);
    }
    if(name.equals("b"))
    {
        //centered on top left vertex
        fillColor = color(255,150,0);
        inputs = 2; outputs = 1;
        inlocs = new PVector[inputs];
        outlocs = new PVector[outputs];
        inlocs[0] = new PVector(0.5,0.5);
        inlocs[1] = new PVector(2.5,0.5);
        outlocs[0] = new PVector(1.5,0.5);
        
        shapeVerts = rectShape(3);
    }
    if(name.equals("x"))
    {
        //centered on top left vertex
        fillColor = color(100,0,255);
        inputs = 1; outputs = 1;
        inlocs = new PVector[inputs];
        outlocs = new PVector[outputs];
        inlocs[0] = new PVector(0,0);
        outlocs[0] = new PVector(0,0);
        
        shapeVerts = boxShape(0);
    }
    if(name.equals("z"))
    {
        //centered on top left vertex
        fillColor = color(255,150,0);
        inputs = 2; outputs = 2;
        inlocs = new PVector[inputs];
        outlocs = new PVector[outputs];
        inlocs[0] = new PVector(0,0);
        inlocs[1] = new PVector(1,0);
        outlocs[0] = new PVector(0,0);
        outlocs[1] = new PVector(1,0);
        
        shapeVerts = rectShape(1);
    }
    if(tensorKeys.indexOf(name) != -1 && false)
    {
        //centered on left vertex
        fillColor = color(200,0,300);
        inputs = 2; outputs = 1;
        inlocs = new PVector[inputs];
        outlocs = new PVector[outputs];
        float len;
        if(name.equals("d") || name.equals("c")) 
          len = 1;
        else
          len = sqrt(2);
        //int dx = grid.dx; int dy = grid.dy;
        inlocs[0] = new PVector(0,0);
        inlocs[1] = new PVector(len,0);
        if(name.equals("d") || name.equals("f"))
        {
          outlocs[0] = new PVector(0,0);
        }
        else
        {
          outlocs[0] = new PVector(0.5,0);
        }
        
        shapeVerts = rectShape(len);
        
        //float colScale = (2*PI)*rotAngle+1;
        //fillColor = color(255*colScale,255-255*colScale,255);
        
    }
    this.name = name;
    this.x = x; this.y = y; this.z = z;
    //if flipped, swap inputs and outputs
    if(flip)
    {
      int oldinputs = inputs; int oldoutputs = outputs;
      PVector[] oldinlocs = inlocs; PVector[] oldoutlocs = outlocs;
      inputs = oldoutputs; outputs = oldinputs;
      inlocs = oldoutlocs; outlocs = oldinlocs;
      this.name = name + "conj";
    }
    inlinks = new Link[inputs];
    outlinks = new Link[outputs];
  }
  //construct from links
  Tensor(List<Link> inlinks, List<Link> outlinks, List<PVector> inlocs, List<PVector> outlocs, int zLower, String name)
  {
    //pass lists of links to arrays
    this.inputs = inlinks.size();
    this.outputs = outlinks.size();
    this.inlinks = inlinks.toArray(new Link[this.inputs]);
    this.outlinks = outlinks.toArray(new Link[this.outputs]);
    
    this.inlocs = inlocs.toArray(new PVector[this.inputs]);
    this.outlocs = outlocs.toArray(new PVector[this.outputs]);
    //attach links
    for(int i=0;i<inputs;i++)
    {
      inlinks.get(i).A = this;
      inlinks.get(i).portA = i; 
    }
    for(int i=0;i<outputs;i++)
    {
      outlinks.get(i).B = this;
      outlinks.get(i).portB = i; 
    }
    //find x,y tensor position by averaging inlocs
    PVector avgloc = new PVector(0,0);
    for(PVector loc : inlocs)
      avgloc.add(loc);
    avgloc.div(inlocs.size());
    this.x = (int)avgloc.x; this.y = (int)avgloc.y;
    //move port locations relative to average
    for(PVector loc : inlocs)
      loc.sub(avgloc);
    for(PVector loc : outlocs)
      loc.sub(avgloc);
    this.z = zLower+dz;
    
    //eh.. make shape a box
    shapeVerts = boxShape(1);
    this.fillColor = color(255);
    this.name = name;
    
    /*don't need to do this: z loc of tensor can be put directly above highest tensor below it
    int zmin = Collections.max(inzlocs); //zmin is maximum z input position (bounds bottom)
    int zmax = Collections.min(outzlocs); //zmax is minimum z output position (bounds top)
    if(zmin == zmax) //this shouldn't happen
      println("problem constructing tensor: z bounds equal");
    if(zmin < zmax) //if tensor is INSIDE diagram, z is between zmin, zmax
      this.z = zmin + 1;
    else
      this.z = zmin + 1;
      */
  }
  void kill()
  {
    for(Link link : inlinks)
      if(link != null)
        link.kill();
    for(Link link : outlinks)
      if(link != null)
        link.kill();
    tensors.remove(tensors.indexOf(this));
  }
  //Tensor Shapes
  PVector [] boxShape(float size)
  {
    int dx = 1; int dy = 1;
    PVector [] shapeVerts = new PVector[5];
    shapeVerts[0] = new PVector(-0.5,-0.5);
    shapeVerts[1] = new PVector((size+0.5),-0.5);
    shapeVerts[2] = new PVector((size+0.5),(size+0.5));
    shapeVerts[3] = new PVector(-0.5,(size+0.5));
    shapeVerts[4] = new PVector(-0.5,-0.5);
    return shapeVerts;
  }
  PVector [] rectShape(float size)
  {
    //int dx = grid.dx; int dy = grid.dy;
    PVector [] shapeVerts = new PVector[5];
    shapeVerts[0] = new PVector(-1/2.,-1/2.);
    shapeVerts[1] = new PVector((size+0.5),-1/2.);
    shapeVerts[2] = new PVector((size+0.5),1/2.);
    shapeVerts[3] = new PVector(-1/2.,1/2.);
    shapeVerts[4] = new PVector(-1/2.,-1/2.);
    return shapeVerts;
  }
  PVector [] diamondShape()
  {
    int dx =1; int dy = 1;
    PVector [] shapeVerts = new PVector[5];
    shapeVerts[0] = new PVector(0,-dy/2);
    shapeVerts[1] = new PVector(1.5*dx,dy/2);
    shapeVerts[2] = new PVector(0,dy*1.5);
    shapeVerts[3] = new PVector(-1.5*dx,dy/2);
    shapeVerts[4] = shapeVerts[0].get();
    return shapeVerts;
  }
  PVector [] crossShape()
  {
    PVector[] shapeVerts = new PVector[13];
    for(int i=0;i<2;i++)
    {
      int r = i*2-1;
      shapeVerts[6*i] = new PVector(r*0.5,-r*1.5);
      shapeVerts[6*i+1] = new PVector(r*0.5,-r*.5);
      shapeVerts[6*i+2] = new PVector(r*1.5,-r*.5);
      shapeVerts[6*i+3] = new PVector(r*1.5,r*.5);
      shapeVerts[6*i+4] = new PVector(r*0.5,r*.5);
      shapeVerts[6*i+5] = new PVector(r*0.5,r*1.5);
    }
    shapeVerts[12] = shapeVerts[0];
    return shapeVerts;
  }
  boolean checkHover()
  {
    PVector avg = new PVector(0,0);
    for(PVector vert : shapeVerts)
      avg.add(vert);
    avg.div(shapeVerts.length);
    avg.add(new PVector(x,y));
    //boolean hover = true;
    PVector mpos = new PVector(mouseX,mouseY);
    PVector dmpos = mpos.get(); dmpos.sub(grid.toPixel(avg));
    double mdist = dmpos.magSq();
    for(PVector vert : shapeVerts)
    {
      PVector dvert = vert.get(); dvert.add(new PVector(x,y));
      dvert = grid.toPixel(dvert);
      dvert.sub(grid.toPixel(avg));
      if(mdist > dvert.magSq())
        return false;
    }
    return true;
  }
  boolean initDrag()
  {
    if(checkHover())
    {
      dragging = true;
      return true;
    }
    return false;
  }
  void drag()
  {
    PVector newPos = grid.toGridSnap(mouseX,mouseY);
    x = newPos.x;
    y = newPos.y;
  }
  void rotate(float angle)
  {
    for(PVector inloc : inlocs)
        inloc.rotate(angle);
    for(PVector outloc : outlocs)
        outloc.rotate(angle);
    for(PVector vert : shapeVerts)
        vert.rotate(angle);
    orientation += angle/PI;
  }
  void drawVertex(float xgrid, float ygrid)
  {
    PVector pos = grid.toPixel(xgrid,ygrid);
    vertex(pos.x,pos.y);
  }
  void drawVertex(float xgrid, float ygrid, float zgrid)
  {
    PVector pos = grid.toPixel(xgrid,ygrid,zgrid);
    vertex(pos.x,pos.y,pos.z);
  }
  void draw(int curz)
  {
    //highlight current layer tensors
    if(curz == z)
      stroke(255);
    else
      stroke(0);
    float alpha = 255*(0.9/(1+(z-curz)*(z-curz)));
    //draw tensor shape
    fill(fillColor,alpha);
    if(outTensor)
      fill(255,alpha);
    beginShape();
    for(PVector vert : shapeVerts)
      drawVertex(x+vert.x,y+vert.y);
    endShape();
    
    //draw ports
    fill(100,250);
    if(curz > z)
      noFill();
    for(int i=0;i<inlocs.length;i++)
    {
      PVector inloc = inlocs[i];
      PVector pos = grid.toPixel(x+inloc.x,y+inloc.y);
      ellipse(pos.x,pos.y,grid.siteSize,grid.siteSize);
      fill(0);
      textSize(16);
      text(""+i,pos.x,pos.y);
      fill(100,250);
    }
    fill(200,250);
    if(curz < z)
      noFill();
    for(PVector outloc : outlocs)
    {
      PVector pos = grid.toPixel(x+outloc.x,y+outloc.y);
      ellipse(pos.x,pos.y,grid.siteSize,grid.siteSize);
    }
    
  }
  void draw3D(int curz)
  {
    //highlight current layer tensors
    if(curz == z)
      stroke(255);
    else
      stroke(0);
    stroke(255,0,255);
    //float alpha = 255*(0.9/(1+(z-curz)*(z-curz)/(dz*dz)));
    //draw tensor shape
    fill(fillColor,100);
    if(outTensor)
      fill(255);
    
    float ztop = z+h;
    beginShape();
    for(PVector vert : shapeVerts) //draw bottom
    {
      drawVertex(x+vert.x,y+vert.y,z);
    }
    endShape();beginShape();
    for(PVector vert : shapeVerts)
    {
      drawVertex(x+vert.x,y+vert.y,ztop); //draw top
    }
    endShape();
    for(int v=0; v<shapeVerts.length-1;v++) //draw sides
    {
      beginShape();
      PVector vert = shapeVerts[v];
      PVector nextVert = shapeVerts[v+1];
      drawVertex(x+vert.x,y+vert.y,z);
      drawVertex(x+nextVert.x,y+nextVert.y,z);
      drawVertex(x+nextVert.x,y+nextVert.y,ztop);
      drawVertex(x+vert.x,y+vert.y,ztop);
      drawVertex(x+vert.x,y+vert.y,z);
      endShape();
    }
    //draw ports
     fill(100,250);
     float zhover = h/8;
     float dx = 1/4.; float dy = 1/4.;
     //ztop =0;
    for(PVector inloc : inlocs)
    {
      beginShape();
      drawVertex(x+inloc.x-dx,y+inloc.y-dy,z-zhover);
      drawVertex(x+inloc.x+dx,y+inloc.y-dy,z-zhover);
      drawVertex(x+inloc.x+dx,y+inloc.y+dy,z-zhover);
      drawVertex(x+inloc.x-dx,y+inloc.y+dy,z-zhover);
      drawVertex(x+inloc.x-dx,y+inloc.y-dy,z-zhover);
      endShape();
    }
    fill(200,250);
    ///if(curz < z)
      //noFill();
    for(PVector outloc : outlocs)
    {
      beginShape();
      drawVertex(x+outloc.x-dx,y+outloc.y-dy,ztop+zhover);
      drawVertex(x+outloc.x+dx,y+outloc.y-dy,ztop+zhover);
      drawVertex(x+outloc.x+dx,y+outloc.y+dy,ztop+zhover);
      drawVertex(x+outloc.x-dx,y+outloc.y+dy,ztop+zhover);
      drawVertex(x+outloc.x-dx,y+outloc.y-dy,ztop+zhover);
      endShape();
    }
    fill(255);stroke(255);
    text(tensors.indexOf(this),x,y,z-h/4);
    
  }
}

