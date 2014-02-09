import spacebrew.*;

String server= "sandbox.spacebrew.cc";
String name="P5 Custom Example - Objects";
String description ="";

Spacebrew sb;

// set up JSON to be sent!
JSONObject outgoing = new JSONObject();

// point that will be synced over spacebrew
PVector remotePoint = new PVector(0,0);

void setup(){
  size(800,600);
  sb = new Spacebrew( this );
  sb.addPublish ("p5Point", "point2d", outgoing.toString());
  sb.addSubscribe ("p5Point", "point2d");
  sb.connect(server, name, description);
}

void draw(){
  background(50);
  fill(0);
  ellipse(mouseX, mouseY, 20,20);
  fill(255);
  ellipse(remotePoint.x, remotePoint.y, 20,20);
  
  // build JSON object with an x and a y
  outgoing.setInt("x", mouseX);
  outgoing.setInt("y", mouseY);
  
  sb.send("p5Point", "point2d", outgoing.toString());
}

void onCustomMessage( String name, String type, String value ){
  if ( type.equals("point2d") ){
    // parse JSON!
    JSONObject m = JSONObject.parse( value );
    remotePoint.set( m.getInt("x"), m.getInt("y"));
  }
}
