//per-cell operations

public float getField(int i, int j)
{
  if (i < 0)
    i += n;
  if (j < 0)
    j += n;
  //return floor(field[i%n][j%n]*4)/(1.*4);
  return field[i%n][j%n];
}
public float getE(int i, int j, int di, int dj)
{
  return -J*cos(2*PI*(getField(i, j) - getField(i+di, j+dj)));
}
public float getEnergy(int i, int j)
{
  float energy = getE(i, j, 1, 0)+getE(i, j, -1, 0)+getE(i, j, 0, 1)+getE(i, j, 0, -1);
  //diagonal terms
  energy += getE(i, j, 1, 1)+getE(i, j, -1, -1)+getE(i, j, -1, 1)+getE(i, j, 1, -1);
  //kinetic term
  energy += - h*cos(2*PI*getField(i, j));
  return energy;
}
public float getF(int i, int j, int di, int dj)
{
  return -J*sin(2*PI*(getField(i, j) - getField(i+di, j+dj))) + h*sin(2*PI*getField(i, j));
}
public float getForce(int i, int j)
{
  return getF(i, j, 1, 0)+getF(i, j, -1, 0)+getF(i, j, 0, 1)+getF(i, j, 0, -1);
}

float detectVortex(int i, int j)
{
  float[] vals = {
    getField(i, j), 
    getField(i, j+1), 
    getField(i+1, j+1), 
    getField(i+1, j)
  };
  return sin(PI*(vals[0]-vals[2]))
    *sin(PI*(vals[1]-vals[3]))
    *sin(PI*(vals[0]-vals[1]+vals[2]-vals[3]));
}
