#include "HSBColor.h"
#include "LPD8806.h"
#include "SPI.h"
#include <Bridge.h>
#include <SpacebrewYun.h>


// Example to control LPD8806-based RGB LED Modules in a strip

// Number of RGB LEDs in strand:
int nLEDs = 32;

// First parameter is the number of LEDs in the strand.  The LED strips
// are 32 LEDs per meter but you can extend or cut the strip.  Next two
// parameters are SPI data and clock pins:
LPD8806 strip = LPD8806(nLEDs, 11, 12);

// create a variable of type SpacebrewYun and initialize it with the constructor
SpacebrewYun sb = SpacebrewYun("led lights", "Range sender and receiver");


int proxVal = 0;
int switchVal = 0;

int barsPin [4] = { A4, A3, A1, A2 };
int barsInvert [4] = { false, false, false, true };
int barsHeight [4] = {0, 0, 0, 0};
uint32_t curColors [4] = {0, 0, 0, 0};


long last_update = 0;
long last_updates [4] = {0,0,0,0};
int update_inter = 150;

uint32_t barHeight = 0;
uint32_t curColor;
int curColorArray[3] = {0, 0, 127};
uint32_t white;
 
void setup() {
	// Start up the LED strip

	Serial.begin(57600);
	delay(4000);
//
//	// start-up the bridge
	Bridge.begin();
//
//	// configure the spacebrew object to print status messages to serial
	sb.verbose(true);

	// configure the spacebrew publisher and subscriber
	sb.addSubscribe("height", "range");
	sb.addSubscribe("color", "range");

	// register the string message handler method 
	sb.onRangeMessage(handleRange);

	// connect to cloud spacebrew server at "sandbox.spacebrew.cc"
	sb.connect("sandbox.spacebrew.cc"); 
	Serial.print("Got here ");

	// Update the strip, to start they are all 'off'
	strip.begin();
	strip.show();
	curColor = strip.Color(0,   0,   120);
	white = strip.Color(0,   0,   0);

  pinMode(2, INPUT_PULLUP);

}
 
void loop() {
  sb.monitor();

  switchVal = digitalRead(2);

  if (switchVal != 0) { 
    rainbowCycle(0);
  }

  delay(20);
}
 
// Fill the dots progressively along the strip.
void setLEDBar(int bar, uint32_t c, int bHeight) {
	int i;
	if (bHeight > 8) bHeight = 8;

        if (bar % 2 == 0) {
    	  for (i=0; i < bHeight; i++) {
    		strip.setPixelColor((bar * 8 + 8 - i - 1), c);
    	  }
    
    	  for (i = bHeight; i < 8; i++) {
    	  	strip.setPixelColor((bar * 8 + 8 - i - 1), white);
      	  }
        }
        
        else {
          
    	  for (i=0; i < bHeight; i++) {
    		strip.setPixelColor(i + (bar * 8), c);
    	  }
    
    	  for (i = bHeight; i < 8; i++) {
    	  	strip.setPixelColor(i + (bar * 8), white);
      	  }
        }
}

// handler method that is called whenever a new string message is received 
void handleRange (String route, int value) {
  // print the message that was received
  Serial.print("From ");
  Serial.print(route);
  Serial.print(", received msg: ");
  Serial.println(value);
  if (route.indexOf("h") == 0) {
    Serial.print("set height ");
    barHeight = int(map(value, 0, 1023, 0, 8));
  } else {
    curColor = int(map(value, 0, 1023, 0, 359));
    H2R_HSBtoRGB(curColor, 100, 50, curColorArray);
    for (int i = 0; i < 3; i++) { curColorArray[i] = curColorArray[i]/2; }
    curColor = strip.Color(curColorArray[0], curColorArray[1], curColorArray[2]);
  }    
  setLEDBar(0, curColor, barHeight);		
  setLEDBar(1, curColor, barHeight);		
  setLEDBar(2, curColor, barHeight);		
  setLEDBar(3, curColor, barHeight);		
  strip.show();
}

uint32_t Wheel(uint16_t WheelPos)
{
  byte r, g, b;
  switch(WheelPos / 128)
  {
    case 0:
      r = 127 - WheelPos % 128;   //Red down
      g = WheelPos % 128;      // Green up
      b = 0;                  //blue off
      break; 
    case 1:
      g = 127 - WheelPos % 128;  //green down
      b = WheelPos % 128;      //blue up
      r = 0;                  //red off
      break; 
    case 2:
      b = 127 - WheelPos % 128;  //blue down 
      r = WheelPos % 128;      //red up
      g = 0;                  //green off
      break; 
  }
  return (strip.Color(r,g,b));
}
// Slightly different, this one makes the rainbow wheel equally distributed 
// along the chain
void rainbowCycle(uint8_t wait) {
  uint16_t i, j;
  
  for (j=0; j < 384 * 5; j++) {     // 5 cycles of all 384 colors in the wheel
    for (i=0; i < strip.numPixels(); i++) {
      // tricky math! we use each pixel as a fraction of the full 384-color wheel
      // (thats the i / strip.numPixels() part)
      // Then add in j which makes the colors go around per pixel
      // the % 384 is to make the wheel cycle around
      strip.setPixelColor(i, Wheel( ((i * 384 / strip.numPixels()) + j) % 384) );
    }  
    strip.show();   // write all the pixels out
    delay(wait);
  }
}
