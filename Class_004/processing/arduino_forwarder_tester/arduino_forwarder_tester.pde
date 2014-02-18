import spacebrew.*;
import processing.serial.*;

String server = "sandbox.spacebrew.cc";
String name = "julio";
String description = "This is an example client which publishes the value of a analog sensor from an Arduino ";

int value = 0;   // the value of the phtocell we weill send over spacebrew

Spacebrew sb;  // Spacebrew connection object
Serial myPort;          // Serial port object 

JSONObject json;

void setup() {
  size(400, 200);

  // initialize json object with name and value attributes 
  json = new JSONObject();
  json.setString("name", name);
  json.setInt("value", value);

  // instantiate the spacebrew object
  sb = new Spacebrew( this );
  
  // add each thing you publish to
  sb.addPublish( "graph_me", "graphable", json.toString() ); 

  // connect to spacebrew
  sb.connect(server, name, description );

  // print list of serial devices to console
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[(Serial.list().length-1)], 9600); // CONFIRM the port that your arduino is connect to
  myPort.bufferUntil('\n');

}

void draw() {
  // set backgroun color based on valueness
  background( value / 4, value / 4, value / 4 );

  // if background is light then make text black
  if (value < 512) { fill(225, 225, 225); }

  // otherwise make text white
  else { fill(25, 25, 25); }

  // set text alignment and font size
  textAlign(CENTER);
  textSize(16);

  if (sb.connected()) {
    // print client name to screen
    text("Connected as: " + name, width/2, 25 );  

    // print current value value to screen
    textSize(60);
    text(value, width/2, height/2 + 20);  
  }
  else {
    text("Not Connected to Spacebrew", width/2, 25 );      
  }
}

// handles serial messages from Arduino
void serialEvent (Serial myPort) {
  // read data as an ASCII string:
  String inString = myPort.readStringUntil('\n');

  if (inString != null) {
    // trim off whitespace
    inString = trim(inString);

    // convert value from string to an integer and add to json
    value = int(inString); 
    json.setString("name", name);
    json.setInt("value", value);

    // publish the value to spacebrew if app is connected to spacebrew
    if (sb.connected()) {
      sb.send( "graph_me", json.toString() );
    }
  }
}

String names [] = {"me", "you", "him", "her", "who", "this", "that", "other", "brother", 
                   "sister", "mother", "twelve", "thirteen", "fourteen", "fifteen", "sixteen"};

void mousePressed() {
  json.setString("name", names[(int)floor(random(names.length))] );
  json.setInt("value", (int)random(1024) );
  sb.send( "graph_me", json.toString() );
  
}
