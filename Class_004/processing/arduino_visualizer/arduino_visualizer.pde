/**
 */

import spacebrew.*;


// Spacebrew stuff
String server = "sandbox.spacebrew.cc";
String name = "Arduino Visualiziaziere";
String description = "Let's graph the shit out of this data";

JSONObject json;

PFont myFont;

Spacebrew sb;

void setup()
{
  size(1200, 740, P3D);

  // instantiate the spacebrewConnection variable
  sb = new Spacebrew( this );

  // declare your subscribers
  sb.addSubscribe( "graph_you", "graphable" );

  // connect!
  sb.connect(server, name, description );
  
  myFont = createFont("Menlo", 24);
}

void draw() {
  if (sb.connected()) {
    background( 0 );
    graph_items();
  }
  else {
    background( 255 );
    fill(0);
    textAlign(CENTER);
    textSize(50);
    text("Not Connected to Spacebrew", width/2, height/2 );      
  }  

}

String names [] = new String[18];
int values [] = new int[18];
int apps = 0; 

int find_name(String name) {
  for (int i = 0; i < apps; i++) {
    if (names[i].equals(name)) {
      println("found name at index " + i);
      return i; 
    }
  }
  names[apps] = name;
  println("added name at index " + apps);
  apps ++;
  return (apps - 1);
}

void update_graph(String name, int value) {
  values[find_name(name)] = value;
  println( "update_graph - name " + name + ", value " + value );
}

int bar_height = height;

void graph_items() {

  colorMode(HSB, 255);
  // set backgroun color based on valueness
  if (apps > 0) bar_height = height / apps;

  // draw bar on left hand side of page for names
  int name_space = 200;
  fill(255, 0, 50);
  rect(0, 0, name_space, height);

  for (int cur = 0; cur < apps; cur ++) {

    fill((255 / 18 * cur), 255, 255);
    noStroke();
    rect(name_space, bar_height * cur, ((width-name_space) / 1024f * values[cur]), bar_height );
        
    // set text alignment and font size
    textAlign(RIGHT);
    textSize(16);
    fill(255, 0, 255);

    // print current value value to screen
    textFont(myFont);
    textSize(24);
    text(names[cur], name_space - 10, bar_height * cur + (bar_height / 2 + 8));  
        
  }
}

void onCustomMessage( String name, String type, String value ) {
  println("name " + name + ", type " + type + ", value "); 
  
  if (type.equals("graphable")) {  
    json = new JSONObject();
    json = JSONObject.parse(value);

    update_graph( json.getString("name"), json.getInt("value") );
  }
}
