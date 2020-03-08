class Link
{
  Tensor A, B; int portA, portB;
  
  Link()
  {
  }
  Link(Tensor A, Tensor B, int portA, int portB)
  {
    this.A = A; this.B = B; this.portA = portA; this.portB = portB;
  }
  Link(Tensor A, int portA)
  {
    this.A = A; this.portA =portA; B = null;
  }
  void kill()
  {
    if(A != null)
      A.portlinks[portA] = null;
    if(B != null)
      B.portlinks[portB] = null;
    links.remove(links.indexOf(this));
  }
  //detect cuts
  //either returns index of this link, or returns -1 if no cut
  int cut()
  {
    if(B == null) //ignore cut if we are missing the second tensor
      return -1;
    //cut link if mouse is within PORTSIZE of it
    //compute 
    PVector p0 =  A.portLoc(portA);
    PVector p1 = B.portLoc(portB);
    float len = PVector.sub(p1,p0).mag();
    PVector n = PVector.sub(p1,p0); n.normalize();
    PVector perp = n.copy(); perp.rotate(HALF_PI); 
    PVector rel = PVector.sub(new PVector(1.*mouseX,1.*mouseY),p0);
    float nProj = rel.dot(n); float perpProj = rel.dot(perp);
    if(0 < nProj && nProj < len && -PORTSIZE < perpProj && perpProj < PORTSIZE)
      return links.indexOf(this);
    
    return -1;
  }
  void draw()
  {
    stroke(255,255,255);
    PVector Aloc = A.portLoc(portA);
    if(B == null)
    {
      line(Aloc.x,Aloc.y,mouseX,mouseY);
    }
    else
    {
      PVector Bloc = B.portLoc(portB);
      line(Aloc.x,Aloc.y,Bloc.x,Bloc.y);
      text(links.indexOf(this)+1,(Aloc.x + Bloc.x)/2,(Aloc.y + Bloc.y)/2);
    }
  }
}
