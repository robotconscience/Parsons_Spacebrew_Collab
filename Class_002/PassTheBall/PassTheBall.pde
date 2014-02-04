// Spacebrew Server Jumping Example
//   
//    Example that shows how an app can connect and bridge two separate
//    Spacebrew servers. Make sure to differentiate the names of the publishers
//    and subscribers that are connected to each server.
//
//   author: Julio Terra
//   date: February 3rd, 2014
//

import spacebrew.*;

// spacebrew variables
Spacebrew sb_in;
String server_in="localhost";   

Spacebrew sb_out;
String server_out="yourneighborshost";

String name="your name";  // same name used for app on both servers
String description ="helping the ball jump from server to server";


// variables for location, velocity, base velocity, visibility,
PVector location;
PVector velocity;
PVector base_velocity;
boolean visible = false;
int ellipse_size = 16;


void setup() {
  size(600,700);
  smooth();
  background(255);

  // instantiate the spacebrewConnection variable
  sb_in = new Spacebrew( this );
  sb_out = new Spacebrew( this );

  // declare your publishers
  sb_out.addPublish( "out", "range", 0 ); 

  // declare your subscribers
  sb_in.addSubscribe( "in", "range"); 

  // connect!
  sb_in.connect(server_in, name, description );
  sb_out.connect(server_out, name, description );

  // initialize base velocity, velocity and location
  base_velocity = new PVector(5.5,0);
  velocity = new PVector(base_velocity.x, base_velocity.y);
  location = new PVector(100, 100);

}

void draw() {
  noStroke();
  fill(255,100);
  rect(0,0,width,height);


  // check if ball is visible before moving
  if (visible) {
  
    // Add the current speed to the location.
    location.add(velocity);

    // send spacebrew messages when ball is offscreen
    if ((location.x > width + (ellipse_size / 2))) {
      sb_out.send("out", int(location.y/float(height) * 1024));
      velocity = new PVector(0,0);  // stop ball from moving
      visible = false;              // stop drawing ball
     
    }

    // Display ball
    stroke(0);
    fill(190);
    ellipse(location.x,location.y,16,16);
  }

}

// onRangeMessage handle range message
void onRangeMessage( String name, int value ){
  println("got range message " + name + " : " + value);

  if (name.equals("in")) {
    location = new PVector(0, (float(value)/1024f * height));  // start ball on left edge of screen
    velocity = new PVector(base_velocity.x, base_velocity.y);  // move ball using the base velocity
    visible = true;
  }
}

// onKeypressed start ball moving if RIGHT key is pressed
void keyPressed(){
  if (key == CODED) {
    if (keyCode == RIGHT) {
      location = new PVector(0, random(height));  // start ball on left edge of screen
      velocity = new PVector(base_velocity.x, base_velocity.y);
      visible = true;
    }
  }  
}


