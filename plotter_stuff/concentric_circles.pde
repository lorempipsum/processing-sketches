

import controlP5.*;
ControlP5 cp5;


//Let's set this up
void sketch_setup() {
  size(840, 1080);
  println(dateTime);
  cp5 = new ControlP5(this);
  smooth();

  if (just_draw) {
    draw_box = false;
    draw_label = false;
    PLOTTING_ENABLED = true;
  }

  //Initialize plotter
  if (PLOTTING_ENABLED == true) {

    //Select a serial port
    println(Serial.list()); //Print all serial ports to the console
    String portName = Serial.list()[1]; //make sure you pick the right one
    println("Plotting to port : " + portName);

    //Open the port
    myPort = new Serial(this, portName, 9600);
    myPort.bufferUntil(lf);

    //Associate with a plotter object
    plotter = new Plotter(myPort);

    plotter.write("IN;"); // add Select Pen (SP1) command here when the pen change mechanism is fixed
    plotter.write("VS" + 38 + ";"); // set the speed of the pen. Default is 20, max is 38.1.
  }

  //Draw a label first (this is pretty cool to watch)
  if (draw_label) {
    float labelX = xMax + 300;
    float labelY = yMin;

    if (PLOTTING_ENABLED) {
      plotter.write("PU" + labelX + "," + labelY + ";"); //Position pen
      plotter.write("SI0.14,0.14;DI0,1;LB" + label + char(3)); //Draw label

      //Wait 0.5 second per character while printing label
      println("drawing label");
      delay(label.length() * 500);
      println("label done");
      plotter.write("PU" + labelX + "," + labelY + ";"); //Position pen
    }

    fill(50);
    float textY = map(labelY, 0, A4_MAX_WIDTH, 0, width);
    float textX = map(labelX, 0, A4_MAX_HEIGHT, 0, height);
    text(label, textY, textX);

  }

  if (draw_box) {

    //box
    drawLine(xMin, yMin, xMax, yMin, true);
    drawLine(xMax, yMin, xMax, yMax, true);
    drawLine(xMax, yMax, xMin, yMax, true);
    drawLine(xMin, yMax, xMin, yMin, true);
    drawLine(xMin, yMin, xMax, yMax, true);
    drawLine(xMin, yMax, xMax, yMin, true);

    if (PLOTTING_ENABLED) {

      //vertical line down from middle
      line_clipped(xMin,(yMax + yMin) / 2, xMax,(yMax + yMin) / 2);

      //horizontal line
      line_clipped((xMax + xMin) / 2, yMin,(xMax + xMin) / 2, yMax);
    }}

}

void sketch_draw() {
    strokeWeight(2); 
    stroke(0);
    noFill();
    // Draw circle in the middle of the plotter 
    float x = xMin;
    float y = yMin;
    drawDroplets(x, y, frameCount);

    // get value for screen cleaner from cp5 slider "screenCleaner"
    boolean isClearingScreenEachFrame = false;
    if (isClearingScreenEachFrame == true) {
      background(200);
    }
  
}

int circles_xCounter = 0;
int circles_yCounter = 0;
float circles_x;
float circles_y;
void drawDroplets(float x0, float y0, int frameCount) {
    float R = 600;
  float dR = R/8;
  float gridStep = 0.9*R; //<>//
  y0 = y0 + gridStep*circles_yCounter;
  if (y0 > yMax) { //<>//
    yCounter = 0;
    y0 = yMin; //<>//
    xCounter = circles_xCounter +1;
    circles_x = x0 + circles_xCounter*gridStep; //<>// //<>//
  }
  if (x0 > xMax) { //<>//
    xCounter = 0;
    println(x0);
    println("resetting x0");
    x0 = xMin;
  }

  yCounter = yCounter + 1;
  circles_y = y0;

  // return -1 or 1 
  int sign = 1;
  if (noise(circles_y) > 0.5) {
    sign = -1;
  }
  float yBump = sign*noise(circles_x,circles_y)*R/(3*PI);
  yBump=0;
  
  sign = 1;
  if (noise(x) > 0.5) {
    sign = -1;
  }
  float xBump = sign*noise(y,x)*R/PI/4;
  xBump = 0;
  if (x < xMax && x > xMin && y < yMax && y > yMin) {
  //plotter_circle(x, y, 1000);

  plotter_circle_droplet(x+xBump,y + yBump, dR,R);}
}


void drawDroplet() {
      strokeWeight(2); 
    stroke(0);
    noFill();
    // Draw circle in the middle of the plotter 
    float x = VERTICAL_CENTER;
    float y = HORIZONTAL_CENTER;
    float radius = frameCount*100*noise(frameCount);
    if (radius < 3000) {
    plotter_circle(x, y, radius);
  }
    println(radius);

}
