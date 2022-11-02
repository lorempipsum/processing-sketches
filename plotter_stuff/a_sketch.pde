import processing.serial.*;

Serial myPort;    // Create object from Serial class
Plotter plotter;  // Create a plotter object
int val;          // Data received from the serial port
int lf = 10;      // ASCII linefeed

import controlP5.*;
ControlP5 cp5;

//Enable plotting?
boolean PLOTTING_ENABLED = false;
boolean draw_box = false;
boolean draw_label = true;
boolean up = true;
boolean just_draw = false;
boolean dontMoveCursor = false;


public void settings() {
  size(840, 1080);
}

//Let's set this up
void setup() {
  println(dateTime);
  cp5 = new ControlP5(this);
  createControllers();
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
