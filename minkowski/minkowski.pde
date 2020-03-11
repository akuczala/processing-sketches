import java.util.List;

List<Event> events;
double dt=0.1;
double drho = 0.02;
double t=0;
double rho=0;
int toggleXa = 0;
int toggleZa = 0;
void setup()
{
  width = 600;
  size(600,600,P3D);
  events = new ArrayList<Event>();
  for(int i=0;i<100;i++)
  {
    events.add(new Event(random(width)-width/2,random(height)-height/2,random(width)-width/2));
    
  }
}
void draw()
{
  background(0);
  stroke(255);
  for(int i=0;i<events.size();i++)
  {
    Event e = events.get(i);
    e.draw();
    e.pos = e.pos.add(new Vec(dt,0,0));
    
    if(toggleZa == 1)
    {
      e.boost(drho*Math.sin(t/5),0);
      rho += drho*Math.sin(t/5);
    }
    if(e.pos.t > height/2 && e.trail == false)
    {
      e.pos = new Vec(-height/2,random(width)-width/2, random(width)-width/2);
      
    }
  }
  text(""+rho,50,50);
  //text(""+t,50,100);
  stroke(255);
  //lightcone
  line(0,0,0,width,height,0);
  line(width,0,0,0,height,0);
  
  noFill();
  int rings = 5;
  for(int i=0;i<rings;i++)
  {
    int radius = i*width/rings/2;
    drawCircle(radius,new Vec(-radius,0,0));
    drawCircle(radius,new Vec(radius,0,0));
  }
  if((int)((t/dt)%(5/dt)) == 0)
  {
    events.add(new Event(0,0,0,color(255,0,0)));
    events.get(events.size()-1).trail = true;
    //t=0;
  }
  t += dt;
}
void drawCircle(int radius, Vec pos)
{
  int npoints = 32;
  beginShape();
  for(int i=0;i<npoints;i++)
  {
    float angle = (i+0.0)/npoints*2*PI;
    double x = radius*Math.cos(angle)+pos.x+width/2;
    double y = pos.t+height/2;
    double z = radius*Math.sin(angle)+pos.y+width/2;
    vertex((int)x,(int)y,(int)z);
  }
  vertex(width/2+(int)pos.x+radius,(int)pos.t+height/2,(int)pos.y+width/2);
  endShape();
}
void keyPressed()
{
  boolean press = false;
  for(int i=0; i<events.size();i++)
  {
    Event e = events.get(i);
    if(key == 'q')
    {
        
        toggleZa = (toggleZa + 1)%2;
        press = true;
    }
    if(key == 'e')
    {
       e.boost(-drho,PI/2);
       rho -= drho; 
       
    }
    if(key == 'w')
    {
        e.boost(drho,0);
        rho += drho;
    }
    if(key == 's')
    {
        e.boost(-drho,0);
       rho -= drho; 
    }
    if(key == 'a')
        e.rotate(-0.05);
    if(key == 'd')
        e.rotate(0.05); 
  }
}

class Vec
{
  double x,y,t;
  Vec(double t,double x, double y)
  {
    this.x = x; this.y = y; this.t = t;
  }
  Vec()
  {
    x=0;y=0;t=0;
  }
  Vec add(Vec v)
  {
    return new Vec(v.t+t,v.x + x, v.y + y);
  }
  Vec scale(double a)
  {
    return new Vec(t*a,x*a,y*y);
  }
  double dot(Vec u)
  {
    //Minkowski dot product
    return this.x*u.x + this.y*u.y - this.t*u.t;
  }
  double mag()
  {
    return Math.sqrt(this.squared());
  }
  double squared()
  {
    return this.dot(this);
  }
  Vec boost(double rho, double theta)
  {
    double axis = this.x*Math.cos(theta)+this.y*Math.sin(theta);
    double newt = this.t*Math.cosh(rho) - Math.sinh(rho)*axis;
    double newaxis = -this.t*Math.sinh(rho) +axis*Math.cosh(rho);
    return new Vec(newt,x*Math.sin(theta)+newaxis*Math.cos(theta),y*Math.cos(theta)+newaxis*Math.sin(theta));
  }
  Vec rotate(double theta)
  {
    double newx = x*Math.cos(theta)-y*Math.sin(theta);
    double newy = x*Math.sin(theta)+y*Math.cos(theta);
    return new Vec(t,newx,newy);
  }
  void print()
  {
    println(t+ "," + x + "," + y);
  }
}
class Event
{
  color col;
  boolean trail = false;
  Vec pos;
  Event(double t, double x, double y)
  {
    pos = new Vec(t,x,y);
    //col = color(255,255,255);
    col = color(100,255*((int)pos.x+width/2)/width,255*((int)pos.y+width/2)/width);
  }
  Event(double t, double x, double y,color col)
  {
    pos = new Vec(t,x,y);
    this.col = col;
  }
  void boost(double rho, double theta)
  {
    pos = pos.boost(rho,theta);
  }
  void rotate(double theta)
  {
    pos = pos.rotate(theta);
  }
  void draw()
  {
    fill(col);
    stroke(col);
    beginShape();
    vertex((int)pos.x+width/2,(int)pos.t+height/2,(int)pos.y);
    vertex((int)pos.x+width/2-5,(int)pos.t+height/2+5,(int)pos.y);
    vertex((int)pos.x+width/2+5,(int)pos.t+height/2+5,(int)pos.y);
    vertex((int)pos.x+width/2,(int)pos.t+height/2,(int)pos.y);
    endShape();
  }
}
