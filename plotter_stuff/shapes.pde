
/*
* Encode a given point (x, y) into the different regions of
* a clip window as specified by its top-left corner (cx, cy)
* and it's width and height (cw, ch).
*/
int encode_endpoint(
  float x, float y,
  float clipx, float clipy, float clipw, float cliph)
{
  int code = 0; /* Initialized to being inside clip window */

  /* Calculate the min and max coordinates of clip window */
  float xmin = clipx;
  float xmax = clipx + cliph;
  float ymin = clipy;
  float ymax = clipy + clipw;

  if (x < xmin)       /* to left of clip window */
    code |= (1 << 0);
  else if (x > xmax)  /* to right of clip window */
    code |= (1 << 1);

  if (y < ymin)       /* below clip window */
    code |= (1 << 2);
  else if (y > ymax)  /* above clip window */
    code |= (1 << 3);

  return code;
}

/*
Draws lines within the confines of the page (xMax and yMax)
*/
boolean line_clipped(
  float x0, float y0, float x1, float y1) {

  float clipx = xMin;
  float clipy = yMin;
  float clipw = yMax - yMin;
  float cliph = xMax - xMin;

  return draw_line_in_box(x0, y0, x1, y1, clipx, clipy, clipw, cliph);
}

void drawBadLine(int x1, int y1, int x2, int y2, boolean up) {
  x1 = changePoint(x1);
  x2 = changePoint(x2);
  y1 = changePoint(y1);
  y2 = changePoint(y2);

  drawLine(x1, y1, x2, y2, up);
}

int changePoint(int point) {
  int newPoint = (int)((float) point - point * random( - 0.01, 0.01));
  return newPoint;
}

void drawLine(float x1, float y1, float x2, float y2, boolean penUp) {

  float xAlpha = x1;
  float xGamma = x2;
  float yAlpha = y1;
  float yGamma = y2;

  // Compare distances from pen position of both points
  float distance1 = sqrt(abs(xPen - x1) * (xPen - x1) + (yPen - y1) * (yPen - y1));
  float distance2 = sqrt(abs(xPen - x2) * (xPen - x2) + (yPen - y2) * (yPen - y2));

  if (distance2 < distance1) {
    // Swap round the coordinates if current line end point is closer to pen position
    x1 = xGamma;
    x2 = xAlpha;
    y1 = yGamma;
    y2 = yAlpha;
  }

  int movementDelay = getMovementDelay(x1, y1);
  int drawingDelay = getDrawingDelay(x1, y1, x2, y2);
  int upDelay = 0;


  float _x1 = map(x1, 0, A4_MAX_WIDTH, 0, width);
  float _y1 = map(y1, 0, A4_MAX_HEIGHT, 0, height);

  float _x2 = map(x2, 0, A4_MAX_WIDTH, 0, width);
  float _y2 = map(y2, 0, A4_MAX_HEIGHT, 0, height);
  line(_y1, _x1, _y2, _x2);

  String pen = "PD";
  if (penUp == true) {
    pen = "PU";
    upDelay = 50;
  }
  int totalDelay = min(abs(movementDelay + drawingDelay + upDelay), 1000);

  //totalDelay = 0;



  xPen = (int) x2;
  yPen = (int) y2;

  if (PLOTTING_ENABLED) {

    plotter.write(pen + x1 + "," + y1 + ";");
    plotter.write("PD" + x2 + "," + y2 + ";");
    delay(totalDelay);
  }
}


void drawPoint(float x, float y) {
  float _x = map(x, 0, A4_MAX_WIDTH, 0, width);
  float _y = map(y, 0, A4_MAX_HEIGHT, 0, height);

  int movementDelay = getMovementDelay(x, y);
  int upDelay = 20;

  int totalDelay = movementDelay + upDelay;
  xPen = x;
  yPen = y;

  point(x, y);

  if (x > xMin && x < xMax && y > yMin && y < yMax) {
    point(_y, _x);
    if (PLOTTING_ENABLED) {
      plotter.write("PU" + x + "," + y + ";"); //Position pen
      plotter.write("PD" + x + "," + y + ";"); //Position pen
      plotter.write("PU;"); //Lift pen
      delay(totalDelay);
    }
  }
}


void draw_circle_with_line() {
  float cx = VERTICAL_CENTER;
  float cy = HORIZONTAL_CENTER;
    int r = 2000;

  float step = frameCount/2;
  x0 = (int)(cx+r*cos(step));
  y0 = (int)(cy+r*sin(step));
  x1 = (int)(cx+r*sin(step));
  y1 = (int)(cy+r*cos(step));
  up = true;
  drawLine(x0, y0, x1, y1, up);
}

void draw_offset_circle_with_line() {
  float cx = VERTICAL_CENTER;
  float cy = HORIZONTAL_CENTER;
    int r = 2000;

  float step = frameCount/2;
  x0 = (int)(cx+r*sin(step));
  y0 = (int)(cy+r*sin(step));
  x1 = (int)(cx+r*sin(step));
  y1 = (int)(cy+r*cos(step));
  up = true;
  drawLine(x0, y0, x1, y1, up);
}



/*
* Draw a square with top-left corner at (x, y), and side 'w',
* filled with clipped lines at an angle 'a' and spaced apart
* a distance 'step'.
*/
void draw_sloped_line(float x, float y, float w, float a)
{
  float xstart = x;
  float ystart = y;

  float slope = cos(a);
  float c = ystart - slope * xstart;

  //for (int i = 0; i < w / step; i++) {
  float x0 = x;
  float y0 = y;
  float x1 = x + w * cos(a);
  float y1 = y + w * sin(a);
  line_clipped(x0, y0, x1, y1);

  if (PLOTTING_ENABLED) {
    delay(200);}
}

/*
* Draw a square with top-left corner at (x, y), and side 'w',
* filled with clipped lines at an angle 'a' and spaced apart
* a distance 'step'.
*/
void draw_hatched_square(float x, float y, float w, float step, float a)
{
  float xstart = x + random(w);
  float ystart = y + random(w);

  boolean downAccept = true;
  boolean upAccept = true;
  boolean draw = true;

  int i = 0;
  float slope = tan(a);
  float c = ystart - slope * xstart;

  //for (int i = 0; i < w / step; i++) {
  while(downAccept || upAccept) {
    float x0 = x - w / 2;
    float y0 = slope * x0 + c + (float)i * step / cos(a);
    float x1 = x + w + w / 2;
    float y1 = slope * x1 + c + (float)i * step / cos(a);;
    if (draw == true) {
      upAccept = draw_line_in_box(x0, y0, x1, y1, x, y, w, w);
    }
    x0 = x - w / 2;
    y0 = slope * x0 + c - (float)i * step / cos(a);
    x1 = x + w + w / 2;
    y1 = slope * x1 + c - (float)i * step / cos(a);
    if (draw == true) {
      downAccept = draw_line_in_box(x0, y0, x1, y1, x, y, w, w);
    }


    i++;
  }
  if (PLOTTING_ENABLED) {
    delay(200);}
}

/*
* Draw a rectangle with top-left corner at (x, y), and width 'w', height 'h'
* filled with clipped lines at an angle 'a' and spaced apart
* a distance 'step'.
*/
void draw_hatched_rectangle(float x, float y, float w, float h, float step, float a)
{
  float xstart = x + random(w);
  float ystart = y + random(w);

  boolean downAccept = true;
  boolean upAccept = true;
  boolean draw = true;

  int i = 0;
  float slope = tan(a);
  float c = ystart - slope * xstart;

  //for (int i = 0; i < w / step; i++) {
  while(downAccept || upAccept) {
    float x0 = x - w / 2;
    float y0 = slope * x0 + c + (float)i * step / cos(a);
    float x1 = x + w + w / 2;
    float y1 = slope * x1 + c + (float)i * step / cos(a);;
    if (draw == true) {
      upAccept = draw_line_in_box(x0, y0, x1, y1, x, y, w, h);
    }
    x0 = x - w / 2;
    y0 = slope * x0 + c - (float)i * step / cos(a);
    x1 = x + w + w / 2;
    y1 = slope * x1 + c - (float)i * step / cos(a);
    if (draw == true) {
      downAccept = draw_line_in_box(x0, y0, x1, y1, x, y, w, h);
    }


    i++;
  }
  if (PLOTTING_ENABLED) {
    delay(200);}
}

boolean draw_line_in_box(float x0, float y0, float x1, float y1, float clipx, float clipy, float clipw, float cliph) {

  /* Stores encodings for the two endpoints of our line */
  int e0code, e1code;

  /* Whether the line should be drawn or not */
  boolean accept = false;
  int tries = 0;

  do {
    /* Get encodings for the two endpoints of our line */
    e0code = encode_endpoint(x0, y0, clipx, clipy, clipw, cliph);
    e1code = encode_endpoint(x1, y1, clipx, clipy, clipw, cliph);
    tries = tries + 1;
    if (tries > 10) {
      println("tried too many times;");
      break;
    }

    if (e0code == 0 && e1code == 0) {
      /* If line inside window, accept and break out of loop */

      accept = true;
      break;
    } else if ((e0code & e1code) != 0) {
      /*
      * If the bitwise AND is not 0, it means both points share
      * an outside zone. Leave accept as 'false' and exit loop.
      */
      break;
    } else {
      if (dontMoveCursor == false) {
        /* Pick an endpoint that is outside the clip window */
        int code = e0code != 0 ? e0code : e1code;

        float newx = 0, newy = 0;

        /*
        *Now figure out the new endpoint that needs to replace
        *the current one. Each of the four cases are handled
        *separately.
        */
        if ((code & (1 << 0)) != 0) {
          /*Endpoint is to the left of clip window */
          //println("/* Endpoint is above the clip window */");

          newx = clipx;
          newy = ((y1 - y0) / (x1 - x0)) * (newx - x0) + y0;
        } else if ((code & (1 << 1)) != 0) {
          /*Endpoint is to the right of clip window */
          //println("/* Endpoint is below the clip window */");

          newx = clipx + cliph;
          newy = ((y1 - y0) / (x1 - x0)) * (newx - x0) + y0;
        } else if ((code & (1 << 3)) != 0) {
          /*Endpoint is above the clip window */
          //println("/* Endpoint is to the right of the clip window */");
          newy = clipy + clipw;
          newx = ((x1 - x0) / (y1 - y0)) * (newy - y0) + x0;
        } else if ((code & (1 << 2)) != 0) {
          /*Endpoint is below the clip window */
          //println(" /* Endpoint is to the left of the clip window */");
          newy = clipy;
          newx = ((x1 - x0) / (y1 - y0)) * (newy - y0) + x0;
        }

        /*Now we replace the old endpoint depending on which we chose */
        if (code == e0code) {
          x0 = newx;
          y0 = newy;
          up = true;

        } else {
          x1 = newx;
          y1 = newy;
          up = true;
        }
      }

      tries = tries + 1;
    }
  } while(true);


  if (accept) {
    drawLine(x0, y0, x1, y1, up);


  } else {
    xPen = x1;
    yPen = y1;
    up = true;
    if (PLOTTING_ENABLED) {
      plotter.write("PU;");
    }
  }

  return accept;
}


int getMovementDelay(float xDestination, float yDestination) {

  float distanceX = Math.abs(int(xDestination - xPen));
  float distanceY = Math.abs(int(yDestination - yPen));


  float x_delay = map(distanceX, 0, xMax - xMin, 10, TIME_X);
  float y_delay = map(distanceY, 0, yMax - yMin, 10, TIME_Y);

  float total_delay = x_delay + y_delay;

  // HACK change this back to 1 for normnal operation
  if (frameCount == 0) {
    total_delay = 1000;
  }

  return(int) total_delay;
}

int getDrawingDelay(float x1, float y1, float x2, float y2) {
  float xDestination = abs(int(x2 - x1));
  float yDestination = abs(int(y2 - y1));

  float x_delay = map(xDestination, 0, xMax - xMin, 20, TIME_X);
  float y_delay = map(yDestination, 0, yMax - yMin, 20, TIME_Y);

  float total_delay = x_delay + y_delay;

  return(int) total_delay;
}


/*************************
Simple plotter class
*************************/

class Plotter {
  Serial port;

  Plotter(Serial _port) {
    port = _port;
  }

  void write(String hpgl) {
    if (PLOTTING_ENABLED) {
      port.write(hpgl);
    }
  }

  void write(String hpgl, int del) {
    if (PLOTTING_ENABLED) {
      port.write(hpgl);
      delay(del);
    }
  }
}
