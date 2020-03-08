class Grid
{
  int dx, dy, dz; int xo,yo; int nx, ny;
  int zo = 0;
  int siteSize;
  boolean periodic;
  Grid(int nx, int ny, int dz, float scale, boolean periodic)
  {
    this.nx = nx; this.ny = ny;
    this.periodic = periodic;
    xo = width/2; yo = height/2;
    dx = (int)(width/nx*scale); dy = (int)(height/ny*scale);
    this.dz = dz;
    siteSize = dx/4;
  }
  //returns positive value between 0 and b
  float mod(float a, float b)
  {
    return (a%b+b)%b;
  }
  PVector modGrid(PVector pos)
  {
    return new PVector(mod(pos.x,grid.nx),mod(pos.y,grid.ny)); 
  }
  PVector toPixel(PVector pos)
  {
    return new PVector(xo + pos.x*dx, yo + pos.y*dy);
  }
  PVector toPixel(float gridx, float gridy)
  {
    return toPixel(new PVector(gridx,gridy));
  }
  PVector toPixel(float gridx, float gridy, float gridz)
  {
    return new PVector(xo + gridx*dx, yo + gridy*dy, zo + gridz*dz);
  }
  PVector toGridSnap(int x, int y)
  {
    return new PVector(mouseX/dx-xo/dx,mouseY/dy-yo/dx);
  }
  float distance(PVector a, PVector b)
  {
    if(!periodic)
      return PVector.dist(a,b);
    PVector moda = modGrid(a);
    PVector modb = modGrid(b);
    float Dx =abs(moda.x-modb.x); Dx = min(Dx,grid.nx-Dx);
    float Dy =abs(moda.y-modb.y); Dy = min(Dy,grid.ny-Dy);
    return sqrt(Dx*Dx+Dy*Dy);
  }
  void draw()
  {
    for(int i=0;i<nx;i++)
    for(int j=0;j<ny;j++)
    {
      fill(0); stroke(255);
      PVector sitePos = toPixel(i-nx/2.,j-ny/2.);
      ellipse(sitePos.x,sitePos.y,siteSize,siteSize);
    }
  }
  void drawLine(float x1, float y1, float z1, float x2, float y2, float z2)
  {
    PVector pointA = toPixel(x1,y1,z1);
    PVector pointB = toPixel(x2,y2,z2);
    line(pointA.x,pointA.y,pointA.z,pointB.x,pointB.y,pointB.z);
  }
}
