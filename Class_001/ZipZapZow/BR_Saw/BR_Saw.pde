import ddf.minim.*;
import ddf.minim.signals.*;

import spacebrew.*;

Spacebrew sb;

Minim minim;
AudioOutput out;
SawWave saw;

void setup()
{
  size(512, 200, P3D);
  minim = new Minim(this);
  // get a line out from Minim, default sample rate is 44100, bit depth is 16
  out = minim.getLineOut(Minim.STEREO, 2048);
  // create a sine wave Oscillator, set to 440 Hz, at 0.5 amplitude, sample rate to match the line out
  saw = new SawWave(440, 0.2, out.sampleRate());
  // set the portamento speed on the oscillator to 200 milliseconds
  saw.portamento(200);
  // add the oscillator to the line out
  out.addSignal(saw);
  
  sb = new Spacebrew(this);
  sb.addPublish("line", "range", 0 );
  sb.addSubscribe("saw", "range");
  sb.connect("sandbox.spacebrew.cc", "brett_saw", "");
}

float freq = 0;

void draw()
{
  background(0);
  stroke(255);
  // draw the waveforms
  for(int i = 0; i < out.bufferSize()-1; i++)
  {
    float x1 = map(i, 0, out.bufferSize(), 0, width);
    float x2 = map(i+1, 0, out.bufferSize(), 0, width);
    line(x1, 50 + out.left.get(i)*50, x2, 50 + out.left.get(i+1)*50);
    line(x1, 150 + out.right.get(i)*50, x2, 150 + out.right.get(i+1)*50);
  }
  freq *= .9;
  saw.setFreq(freq);
}


void stop()
{
  out.close();
  minim.stop();
  
  super.stop();
}

void mouseDragged(){
  sb.send("line", (int) random(1023));
}

void onRangeMessage( String name, int value ){
  freq = map(mouseY, 0, 1023, 1500, 60);
  saw.setFreq(freq);
}
