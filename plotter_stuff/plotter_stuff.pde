

//Label
String dateTime = day() + " / " + month() + " / " + year() + " " + hour() + " : " + minute() + " : " + second() + " - ";
String label = dateTime + "draw_cube_spinner";


//Plotter dimensions
float xMin = 600;
float yMin = 800;
float xMax = 10300 - 300;
float yMax = 8400 - 600;
float plotAreaWidth = (float)(yMax - yMin);
float plotAreaHeight = (float)(xMax - xMin);
float aspectRatio = (float)(plotAreaHeight / plotAreaWidth);

float VERTICAL_CENTER = (xMax + xMin) / 2;
float HORIZONTAL_CENTER = (yMax + yMin) / 2;

float A4_MAX_HEIGHT = 10887;
float A4_MAX_WIDTH = 8467;
float xPen = xMin;
float yPen = yMin;

float TIME_Y = 5000;
float TIME_X = 5000;
int rowPosition = 0;
int columnPosition = 0;

float getDirection () {
  float randomInt = int(random(3));

  if (randomInt == 1) {
    return 1;
  } 
  if (randomInt == 2) { 
    return -1;
  } else {
    return 0;
  }
}

// As x increases, so does the scale of the shape
float increaseScaleByXCoordinate(float initial_scale, float x) {
  float initialScale = initial_scale;
  float scale = map(x, 0, xMax, initialScale/2, initialScale*2);
  return scale;
}

float getRowGap(float y, float x, float objectWidth) {
  float maxRowGap = objectWidth*1.5;
  float minRowGap = objectWidth/2;
  return map(noise(x, y), 0 ,1 ,maxRowGap, minRowGap);
}

float initialX = xMin;
float initialY = yMin;
float COLUMN_GAP = 1;
float ROW_GAP = 1;
float OBJECT_HEIGHT = 100;
int fps = 60;



void draw() {
  strokeWeight(3); 
  boolean skipFrame;
  float x, y;
  float initialScale = 100;
  int numberOfCorners = 4;



  y = initialY;
  // float columnGap = map(initialX, xMin, xMax, 0, objectHeight);
  float scale = increaseScaleByXCoordinate(initialScale, initialX);
  float rowGap = getRowGap(y, initialX, scale);
  float maxRotation = cp5.getController("maxRotation").getValue();
  // float rotation = map(initialX, xMin, xMax, 0, maxRotation);
  float rotation = map(noise(initialX, y), 0, 1, 0, maxRotation);

  float objectHeight = scale;
  //float objectHeight = OBJECT_HEIGHT;
  float minColumnGap = objectHeight*cp5.getController("minColumnGapController").getValue();
  float maxColumnGap =  objectHeight*cp5.getController("maxColumnGapController").getValue();

  float columnGap = map(noise(initialX,y), 0, 1, minColumnGap, maxColumnGap);

  initialX = initialX + columnGap;
  float noiseValue = noise(initialX, y);



  numberOfCorners = int(map(noiseValue, 0, 1, 3, 5));
  //numberOfCorners =4;
  
  // get number of corners from cp5 slider "corners" 
  numberOfCorners = int(cp5.getController("corners").getValue());

  skipFrame = false;
  // safeguard against drawing outside the lines 
  if (initialX > xMax || initialX < xMin || y < yMin || y > yMax) {
    skipFrame = true;
    if (initialX > xMax) {
      initialX = xMin;
      initialY = initialY + rowGap;
      frameCount = 0;
    }
    if (initialX < xMin) {
      initialX = xMin;
    }
    if (y < yMin) {
      initialY = yMin;
    }
    if (y > yMax) {
      initialY = yMin;
      frameCount = 0;
    }
    // when both x and y coordinates are at the max, stop the program
    if (initialX >= xMax && y >= yMax) {
      print("max coords achieved");
      noLoop();
    }
  }

  if (skipFrame == false) {

    // get value for screen cleaner from cp5 slider "screenCleaner"
    boolean isClearingScreenEachFrame = cp5.getController("screenClearerToggle").getValue() == 1;
    if (isClearingScreenEachFrame == true) {
      background(200);
    }

    
    draw_cube_spinner(initialX, y, scale, objectHeight, rotation, numberOfCorners);
    fps = int(cp5.getController("fps").getValue());
    frameRate(fps);
    //change speed. 0.1 to 38 :
    if (PLOTTING_ENABLED) {
      plotter.write("VS" + 30 + ";");
    }
  }
}
