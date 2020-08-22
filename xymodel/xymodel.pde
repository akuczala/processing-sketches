float increment = 0.02;
int n = 180;
int dotsize;
float[][] field = new float[n][n];
float[][] fieldv = new float[n][n];
float[][] nextField = new float[n][n];
float[][] nextFieldv = new float[n][n];
float J = 1; 
float h = 0;
float T = 0.2;
float dt = 0.01;
float sample = 0;
float gauge = 0;
int brushSize = 10;
boolean pause = false;
boolean usePixels = true;

enum Mode {
  THERMAL, DYNAMIC
};
enum DisplayMode {
  FIELD, STRING, VORTEX
};

DisplayMode displayMode = DisplayMode.FIELD;
Mode mode = Mode.THERMAL;

void setup() {
  size(720, 720);
  dotsize = (width/n);
  colorMode(HSB, 255);
  for (int i=0; i<n; i++)
    for (int j=0; j<n; j++)
    {
      //fieldv[i][j] = 5*sin(4.*(i/n+j/n));
      if (Math.sqrt(Math.pow(i-n/2, 2)+Math.pow(j-n/2, 2))<n/8)
        field[i][j] = 0;
      else
        field[i][j] = 0.5;
      //field[i][j] = (sin(5*PI*i/n)*
      //sin(5*PI*j/n)+1);
      //+(sin(1*PI*i/n+1)*sin(0*PI*j/n+1)+1)/4;
    }
}

public void dynamic() {
  for (int i=0; i<n; i++)
    for (int j=0; j<n; j++)
    {
      nextFieldv[i][j] = fieldv[i][j] + getForce(i, j)*dt;
      nextField[i][j] = field[i][j] + nextFieldv[i][j]; 
      nextField[i][j] = (nextField[i][j]%1);
      if (nextField[i][j] < 0)
        nextField[i][j] += 1;
      if (displayMode == DisplayMode.FIELD)
        drawCell(i, j, nextField[i][j], 1., 1.);
    }
  for (int i=0; i<n; i++)
    for (int j=0; j<n; j++)
    {
      field[i][j] = nextField[i][j];
      field[i][j] = getField(i, j);
      fieldv[i][j] = nextFieldv[i][j];
    }
}
public void thermal() {
  for (int flip=0; flip<10000; flip++)
  {

    float maxangle = 1;
    int randi = (int)(random(1)*n);
    int randj = (int)(random(1)*n);
    float randa = random(1)*2*maxangle - maxangle;
    float oldField = getField(randi, randj);
    float oldEnergy = getEnergy(randi, randj);
    field[randi][randj] += randa;
    field[randi][randj] = (field[randi][randj]%1);
    if (field[randi][randj] < 0)
      field[randi][randj] += 1;
    field[randi][randj] = getField(randi, randj);
    float newEnergy = getEnergy(randi, randj);
    float dE = newEnergy - oldEnergy;
    float prob = exp(-dE/T);
    if (T == 0) prob = 0;
    if (dE > 0 && prob < random(1))
    {
      field[randi][randj] = oldField;
    }
    //pixels[randi+width*randj] = color(255,0,0);
    if (displayMode == DisplayMode.FIELD)
      drawCell(randi, randj, getField(randi, randj), 1., 1.);
  }
}
void string() {
  for (int i = 0; i<n; i++)
    for (int j=0; j<n; j++) {
      float di = (getField(i+1, j)+gauge)%1 - (getField(i, j)+gauge)%1;
      float dj = (getField(i, j+1)+gauge)%1 - (getField(i, j)+gauge)%1;
      float angle = 0.5*(atan2(dj, di)/PI + 1);
      float mag = sqrt(di*di+dj*dj)/sqrt(2);
      sample = mag;
      drawCell(i, j, angle, 1., mag);
    }
}
float[] fieldValueToComplex(float f)
{
  float theta = 2*PI*f;
  float[] out = {cos(theta), sin(theta)};
  return out;
}

void vortex() {
  for (int i = 0; i<n; i++) {
    for (int j=0; j<n; j++) {

      sample = detectVortex(i, j);
      float hue=0;
      float bright =1;
      float threshold = 0.5;
      if (sample < 0)
        hue = 0.5;
      if (sample > 0)
        hue = 0;
      if (sample > threshold || sample < -threshold) {
        bright = abs(sample);
      } else {
        bright = 0;
      }
      //hue = (sample+1)/2;
      drawCell(i, j, hue, 1., bright);
    }
  }
}
float dTheta(int i1, int j1, int i2, int j2)
{

  float df = (getField(i2, j2) - getField(i1, j1));
  if (abs(df) > .75) return df;
  else return 0;
}
void clearField()
{
  for (int i=0; i<n; i++)
    for (int j=0; j<n; j++)
    {
      field[i][j] = 0;
      fieldv[i][j] = 0;
    }
}
void drawCell(int i, int j, float hue, float sat, float val)
{
  if (usePixels)
    for (int di=0; di<dotsize; di++)
      for (int dj=0; dj<dotsize; dj++)
        pixels[i*dotsize+di+(j*dotsize+dj)*width] = color((int)(hue*255), (int)(255*sat), (int)(255*val));
  else
  {
    fill((int)(hue*255), (int)(255*sat), (int)(255*val));
    rect(i*dotsize, j*dotsize, dotsize, dotsize);
  }
}
void draw() {
  if (usePixels)
    loadPixels();

  // For every x,y coordinate in a 2D space, calculate a noise value and produce a brightness value
  if (!pause)
  {
    if (mode == Mode.THERMAL) thermal();
    if (mode == Mode.DYNAMIC) dynamic();
  }
  if (displayMode == DisplayMode.STRING)
    string();
  if (displayMode == DisplayMode.VORTEX)
    vortex();
  if (mousePressed)
  {
    for (int di=-brushSize; di<brushSize; di++)
      for (int dj=-brushSize; dj<brushSize; dj++)
      {
        int i = mouseX/dotsize+di;
        int j = mouseY/dotsize+dj;
        if (-1 < i && i < n && -1 < j && j < n)
        {
          field[i][j] = (0.2*(di+dj)/brushSize)%1;
          drawCell(i, j, field[i][j], 1., 1.);
        }
      }
  }
  if (usePixels)
    updatePixels();
}
void keyPressed() {
  if (key == 'v')
    if (displayMode == DisplayMode.FIELD)
      displayMode = DisplayMode.STRING;
    else
      if (displayMode == DisplayMode.STRING)
        displayMode = DisplayMode.VORTEX;
      else
        if (displayMode == DisplayMode.VORTEX)
          displayMode = DisplayMode.FIELD;
  if (key == 'p')
    pause = !pause;
  if (key == 'c')
    clearField();
  if (key == 'w')
    h += 0.1;
  if (key == 's')
    h -= 0.1;
  if (key == 'd')
    J += 0.1;
  if (key == 'a')
    J -= 0.1;
  if (mode == Mode.THERMAL) {
    if (key == 'i')
      T += 0.1;
    if (key == 'k')
      T -= 0.1;
    if (T < 0)
      T = 0;
  }
  if (mode == Mode.DYNAMIC) {
    if (key == 't')
      dt = dt*2;
    if (key == 'g')
      dt = dt/2;
  }
  if (key == 'x')
    gauge += .1;
  if (key == 'z')
    gauge -= .1;
  if (key == 'z' || key == 'x')
    if (displayMode == DisplayMode.STRING)
      string();
  if (key == 'm') {
    if (mode == Mode.THERMAL) {
      mode = Mode.DYNAMIC;
    } else {
      mode = Mode.THERMAL;
    }
  }
  println("h=" + h + ", J=" + J + ", T=" + T + ", dt=" + dt);
  //print(sample);
}
