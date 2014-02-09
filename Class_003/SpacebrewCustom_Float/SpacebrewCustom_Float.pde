import spacebrew.*;

Spacebrew sb;

String host = "sandbox.spacebrew.cc";
String name = "Custom_YOURNAME";
String desc = "Sends floats!";

float noiseOut = 0.0;
float sinOut = 0.0;

float inX = 0.0;
float inY = 0.0;

void setup(){
  size( 1024, 768 );
  sb = new Spacebrew(this);
  
  sb.addPublish("noise", "float", str(noiseOut));
  sb.addPublish("sin", "float", str(sinOut));
  sb.addSubscribe("floatX", "float");
  sb.addSubscribe("floatY", "float");
  sb.connect( host, name, desc );
}

// noise is a lookup, so we need a growing number
float offset = 0.0;

void draw(){
  background(0);
  // maybe we just want to send some weird float data
  noiseOut = noise( offset );
  // sin goes -1 to 1, so let's do the same for noise
  noiseOut = map( noiseOut, 0.0, 1.0, -1.0, 1.0 );
  sinOut   = sin( offset );
  
  // send that custom stuff
  sb.send( "noise", "float", str( noiseOut ) );
  sb.send( "sin", "float", str( sinOut ) );
  
  // offset controls speed of sin/noise
  offset +=  (float) mouseX / width ;
  
  translate( width/2, height/2);
  ellipse( inX, inY, 20, 20 ); 
}

void onCustomMessage( String name, String type, String value ){
  println("Wow, such custom: "+ name + ", "+ type + ", " + value );
  
  if ( name.equals( "floatX" ) ){
    inX = float( value );
    // make it related to our window!
    // noise and sin both go -1 to 1...
    inX = inX * width/2.0;
  } else if ( name.equals( "floatY" ) ){
    inY = float( value );
    inY = inY * height/2.0;
  } 
  
}
