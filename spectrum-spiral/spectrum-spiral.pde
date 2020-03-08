import ddf.minim.analysis.*;
import ddf.minim.*;

import processing.opengl.*;
import java.awt.Color;

Minim minim;  
AudioPlayer audio; //for audio file input
//AudioInput audio; //for streaming audio input
FFT fftLog;

float height3;
float height23;

boolean spiral = true;

int bin = 12*4; //12*16, 12*4

//assuming 44,000 hz sample rate,
//bufferSize = 1024 -> 40 fps, 2048 -> 20, 4096 -> 10, 8192 -> 5 etc
int bufferSize = 256*16; // must be power of 2

//set default file
String fileName = "cscale.mp3";

int n;
float scale = 50; //sets log amplitude scale
float valueMultiplier = 1; //multiplicative gain
int blend = 255; //255 = no blend
float time = 0;

PFont font;

//parameters for note histogram
String notes[] = {"A","Bb","B","C","Db","D","Eb","E","F","F#","G","Ab"};
int noteColors[] = {0,10,20,40,80,100,120,140,160,180,200,220}; //hues
float tune = -1; //tuning offset
int noteHist[] = new int[12]; //note histogram

void setup()
{
  size(900, 900,P2D);

  height3 = height/3;
  height23 = 2*height/3;

  minim = new Minim(this);
  
  //load audio file
  
  selectInput("Select a file to process:", "fileSelected");
  try{
    audio = minim.loadFile(fileName, bufferSize); //for audio file input
    audio.loop();// loop audio file
    //audio = minim.getLineIn(); //for audio input
    //audio.enableMonitoring(); //listen to audio in
  }catch(Exception e) {
    exit();
    return;
  }
  
  // create an FFT object for calculating logarithmically spaced averages
  fftLog = new FFT( audio.bufferSize(), audio.sampleRate() );
  print(audio.sampleRate());
  //fftLog.window(FFT.HAMMING);
  fftLog.window(FFT.GAUSS);
  // calculate averages based on a miminum octave width of 22 Hz
  // split each octave into three bands
  // this should result in 30 averages
  fftLog.logAverages( 22, bin );
  
  rectMode(CORNERS);
  font = loadFont("ArialMT-12.vlw");
}

void draw()
{
  //background(0); //clear each frame
  fill(0,blend); rect(0,0,width,height);//alpha blending
  textFont(font);
  textSize( 18 );
  
  float centerFrequency = 0;
  
  // perform a forward FFT on the samples in audio's mix buffer
  // note that if audio were a MONO file, this would be the same as using audio.left or audio.right
  fftLog.forward( audio.mix );
 
  noStroke();
  int xo, yo;
  xo = width/2; yo = height/2;
  int lastx = xo; int lasty = yo;
  int lastx2 = xo;int lasty2 = yo;
  float lastVal = 0;
  float maxVal [] = new float[2];
  float maxAt [] = new float[2];
  
  // draw the logarithmic averages
  // since logarithmically spaced averages are not equally spaced
  // we can't precompute the width for all averages
  n = fftLog.avgSize()-bin; //don't bother with first octave
  
  for(int i = bin; i < fftLog.avgSize(); i++)
  {
    centerFrequency    = fftLog.getAverageCenterFrequency(i);
    // how wide is this average in Hz?
    float averageWidth = fftLog.getAverageBandWidth(i);   
    
    // we calculate the lowest and highest frequencies
    // contained in this average using the center frequency
    // and bandwidth of this average.
    float lowFreq  = centerFrequency - averageWidth/2;
    float highFreq = centerFrequency + averageWidth/2;
    
    // freqToIndex converts a frequency in Hz to a spectrum band index
    // that can be passed to getBand. in this case, we simply use the 
    // index as coordinates for the rectangle we draw to represent
    // the average.
    int xl = (int)fftLog.freqToIndex(lowFreq);
    int xr = (int)fftLog.freqToIndex(highFreq);
    int w = width/n;
    xl = i*w; xr = (i+1)*w;
    float val = fftLog.getAvg(i)*valueMultiplier;
    //peakIndex = 1;
    if(val > maxVal[0])
    {
      maxVal[0] = val;
      maxAt[0] = centerFrequency;
    }
    //take log of value
    float logval;
    if(val == 0)
      logval = 0;
    else
      logval = log(val)/log(10)*20;
    if(logval < 0)
       logval = 0;
       if(val > scale)
         val = scale;
      if(logval >scale)
        logval = scale;
    
    
    // draw a rectangle for each average, multiply the value by spectrumScale so we can see it better
    //rect( xl, height, xr, height - fftLog.getAvg(i)*spectrumScale );
     //rect(xl, height,xr, height - val*spectrumScale );
     float turn = 1;
     float frac= ((float)(i-bin))/n;
     float angle = 2*PI*(i%bin)/bin;
     float ux = cos(angle*turn);
     float uy = sin(angle*turn);
     float rad = width/2*(0.00+frac);
     
     int x = (int)(rad*ux+xo);
     int y = (int)(rad*uy+yo);
     rad += 40;
     int x2 = (int)(rad*ux+xo);
     int y2 = (int)(rad*uy+yo);
     
     // if the mouse is inside of this average's rectangle
    // print the center frequency and set the fill color to red
    if ( mouseX >= xl && mouseX < xr )
    {
      fill(255, 128);
      text("Logarithmic Average Center Frequency: " + centerFrequency, 5,25);
      text("Value: " + val/scale, 5,100);
      colorMode(RGB,255);
      fill(255, 0, 0);
    }
    else
    {
        colorMode(HSB,255);
        fill(255-logval/scale*255,255,255,logval/scale*255); //color by val
        //fill(frac*255,255,val/scale*255); //HSB spiral
        //fill((frac+time)%1*255,255,255,val/scale*255); //HSB spiral w opacity
        //fill(255.*(i%bin)/bin,255,val/scale*255); //HSB each octave
        //fill(255);
    }
       //draw trapezoids in spiral
       if(spiral)
       {
         triangle(lastx2,lasty2,lastx,lasty,x2,y2);
         triangle(x2,y2,x,y,lastx,lasty);
       }else{
         //draw as a grid
         rect((i-bin)%bin*width/bin,floor((i-bin)/bin)*1.*bin/n*width,((i-bin)%bin + 1)*width/bin,floor((i-bin)/bin)*1.*bin/n*width + (1.*bin/n)*width);
       }
       //draw a regular old spectrogram
       /*
       fill(50,255,255,20);
       int scale = 10;
       rect(i*w,height,(i+1)*w,height-val*scale);
       fill(0,255,255,20);
       rect(i*w,height,(i+1)*w,height-logval*scale);
       */
     lastx = x;
     lasty = y;
     lastx2 = x2;
     lasty2 = y2;
     lastVal = val;
  }
  time += 1./2000;
  //fill(0); rect(0,0,100,100);
   
   //A0 = 25.25; A1 = 55; A2 = 110; A3 = 220; A4 = 440
   float octave = log(maxAt[0]/25.25)/log(2);
   float tone = (octave*12 + tune)%12;
   int semiTone = round(tone);
   if(semiTone > 11 || semiTone < 0)
     semiTone = 0;
   String note = notes[semiTone];
   if(octave >= 1)
     noteHist[semiTone] += 1;
   //text("Octave " + (int)(octave) + "semitone " + semiTone,50,50);
   
   //draw histogram
   
   
   int w = width/12;
   int h = 1;
   for(int i=0; i<12;i++)
   {
     fill(noteColors[i],255,255,25);
     rect(i*w,0,(i+1)*w,h*noteHist[i]);
     fill(noteColors[i],255,255,255);
     if(i == semiTone)
       rect(tone*w,0,tone*w+1,noteHist[i]+10);
     if(noteHist[semiTone] > height/2)
       noteHist[i] = noteHist[i]/2;
     fill(255,128);
     text(notes[i],i*w,20);
   }
   fill(255,128);
   text(note + (int)(octave),50,50);
   maxVal[0] = 0;
     
}
void keyPressed()
{
  if(key == 'x' || key == 'z')
  {
    if(key == 'x')
      tune += 0.1;
    if(key == 'z')
      tune -= 0.1;
      println(tune);
      for(int i =0;i<12;i++)
        noteHist[i] = 0;
  }
    if(key == 'q' || key == 'a')
    {
      if(key == 'q')
        blend += 10;
      if(key == 'a')
        blend -= 10;
      if(blend < 0)
        blend = 0;
      if(blend > 255)
        blend = 255;
      println(blend);
    }
    if(key == 'w' || key == 's')
    {
      if(key == 'w')
        scale *= 1.1;
      if(key == 's')
        scale = scale/1.1;
      println(scale);
    }
    if(key == 'l')
      selectInput("Select a file to process:", "fileSelected");
    if(key == 'p')
      spiral = !spiral;
}
void mousePressed()
{
  //ENABLE WHEN USING FILE
  int ms = (int)map(mouseX, 0, width, 0, audio.length());
  if ( mouseButton == LEFT )
  {
    //ENABLE FOR FILE
    audio.skip(ms); 
    
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    fileName = selection.getAbsolutePath();
    //ENABLE FOR FILE
    audio.pause();
    audio = minim.loadFile(fileName, bufferSize);
    //audio = minim.getLineIn();
     //loop the file ENABLE FOR FILE
    audio.loop();
  }
}
