class Link
{
  Tensor A, B; int portA, portB; //A is input, B is output
  color lineColor;
  Link()
  {
  }
  Link(Tensor A, Tensor B,int portA,int portB)
  {
    this.A = A; this.B = B; this.portA = portA; this.portB = portB;
   A.inlinks[portA] = this; B.outlinks[portB] = this; 
   lineColor = color(random(155)+100,random(155)+100,random(155)+100);
  }
  void draw3D()
  {
    stroke(lineColor);
    if(A != null)
      stroke(A.fillColor);
    if(A.z > B.z)
    {
      grid.drawLine(A.inlocs[portA].x+A.x,A.inlocs[portA].y+A.y,A.z,
      B.outlocs[portB].x+B.x,B.outlocs[portB].y+B.y,B.z+B.h);
    }else{
      grid.drawLine(A.inlocs[portA].x+A.x,A.inlocs[portA].y+A.y,A.z,
        A.inlocs[portA].x+A.x,A.inlocs[portA].y+A.y,A.z-A.h);
      grid.drawLine(B.outlocs[portB].x+B.x,B.outlocs[portB].y+B.y,B.z,
        B.outlocs[portB].x+B.x,B.outlocs[portB].y+B.y,B.z+2*B.h);
    }
    
  }
  void kill()
  {
    if(A != null)
      A.inlinks[portA] = null;
    if(B != null)
      B.outlinks[portB] = null;
    links.remove(links.indexOf(this));
  }
}
