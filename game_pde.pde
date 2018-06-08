import processing.video.*;
float scale = 1;
float angleX = 0;
float angleY = 0;
float PiRadian = 180;

public float score = 0;
public float maxScore = 5000; 
public float lastScore = 0;
public Movie vid;
PGraphics gameSurface;
final int spaceBetweenBlocks = 50;

PGraphics dataVisualization;
final int dataVisualizationLength = 300;
PGraphics topView;
final int topViewLength = 200;
PGraphics scoreBoard;
final int scoreBoardHeight = 200;
final int scoreBoardWidth = scoreBoardHeight*3/4;

PGraphics barChart;
final int barChartWidth = 1200;
final int barChartHeight = 160;

final int numberSquare = 20; //max squares in a column
final float squareScoreHeight = barChartHeight/(numberSquare + 1); //1 => space between the squares
float scoreSquare = maxScore/numberSquare; //value of one square (how much point represents one square)
public ArrayList<Integer> squaresList = new ArrayList<Integer>();

float squareScoreWidth = squareScoreHeight; //will be scaled
HScrollbar hs;
final int hsHeight = 20;
final int hsWidth = 500;

boolean shiftMode = false;

public float rx = 0;
public float rz = 0;
public float ratio = 1;
final public float plateSquareLength = 400;
final public float plateSquareheight = 20;
public ImageProcessing imgproc;
final Sphere sphere = new Sphere();

public ArrayList<Cylinder> cylinder = new ArrayList<Cylinder>();
public ArrayList<PVector> coordCylinder = new ArrayList<PVector>();


float depth = 2000;

//-------------------------------------------------------------------------------------------

void settings() {

  size(1440, 900, P3D);
}
//-------------------------------------------------------------------------------------------

void setup() {
  frameRate(30);
  vid = new Movie(this, "testvideo.avi"); //Put the video in the same directory
  vid.loop();

  imgproc = new ImageProcessing();

  String []args = {"Image processing window"};
  PApplet.runSketch(args, imgproc);
  noStroke();
  gameSurface = createGraphics(width, height -dataVisualizationLength, P3D);

  dataVisualization = createGraphics(width, dataVisualizationLength, P2D);
  topView = createGraphics(topViewLength, topViewLength, P2D);
  scoreBoard = createGraphics(scoreBoardHeight, scoreBoardHeight, P2D);
  barChart = createGraphics(barChartWidth, barChartHeight, P2D);
  hs = new HScrollbar(topViewLength + 3 * spaceBetweenBlocks + scoreBoardWidth, height - dataVisualizationLength + spaceBetweenBlocks + scoreBoardHeight - 20, hsWidth, hsHeight);
}
//-------------------------------------------------------------------------------------------

void drawdataVisualization() {
  dataVisualization.beginDraw();
  dataVisualization.background(250, 234, 115);
  dataVisualization.endDraw();
}
//-------------------------------------------------------------------------------------------

void drawTopView() {

  topView.beginDraw();
  topView.background(100, 100, 150);

  final float ratioBall = 1.5*topViewLength*sphere.sphereSize/plateSquareLength;
  float relativeBallX = topViewLength *sphere.location.x / plateSquareLength ;
  float relativeBallY = topViewLength *sphere.location.z /plateSquareLength;

  topView.fill(200, 0, 0);
  topView.ellipse(topViewLength/2+relativeBallX, topViewLength/2+ relativeBallY, ratioBall, ratioBall);

  for (Cylinder part : cylinder) {

    float relativePartX = topViewLength *part.location.x / plateSquareLength ;
    float relativePartY = topViewLength *part.location.z / plateSquareLength ;
    final float ratioCylinder =  2*topViewLength*part.cylinderBaseSize/plateSquareLength;
    topView.fill(250, 234, 115);
    topView.ellipse(topViewLength/2 + relativePartX, topViewLength/2 + relativePartY, ratioCylinder, ratioCylinder);
  }
  topView.endDraw();
}
//-------------------------------------------------------------------------------------------

void drawScoreBoard() {

  scoreBoard.beginDraw();
  scoreBoard.rect(0, 0, scoreBoardWidth, scoreBoardHeight, 20);
  scoreBoard.stroke(255);
  scoreBoard.strokeWeight(3);
  scoreBoard.textSize(16);
  scoreBoard.fill(0);
  scoreBoard.text("Total score: \n   "+ nfc(score, 3) +"   \n velocity: \n   "+ nfc(mag(sphere.velocity.x, sphere.velocity.z), 3) + "\n last score: \n   "+ nfc(lastScore, 3), 10, 20);
  scoreBoard.fill(250, 234, 115);
  scoreBoard.endDraw();
}
//-------------------------------------------------------------------------------------------

void drawBarChart() {
  barChart.beginDraw();

  barChart.fill(250, 200, 115);
  barChart.rect(0, 0, barChartWidth, barChartHeight);

  barChart.fill(0, 0, 255);
  barChart.noStroke();

  int c = 0; //begin to draw the cubes after this index
  if (squaresList.size() * squareScoreWidth > barChartWidth) {
    c = (int)((squaresList.size() * squareScoreWidth - barChartWidth)/squareScoreWidth);
  }

  for (int i = 0; i < squaresList.size() - c; ++i) {
    for (int j = 0; j < squaresList.get(i + c); ++j) {
      barChart.rect(i * squareScoreWidth + i, barChartHeight - (j+1) * squareScoreHeight - (1 + j), squareScoreWidth, squareScoreHeight);
    }
  }

  barChart.endDraw();
}
//-------------------------------------------------------------------------------------------

void drawGame() {
  gameSurface.beginDraw();
  gameSurface.directionalLight(50, 100, 125, 3, 1, 0);
  gameSurface.ambientLight(102, 102, 102);
  gameSurface.background(232);


  //plate
  gameSurface.translate(width/2, height/2-100, 0);
  if (!shiftMode) {
    if (imgproc.rotations.x<=PI/3 && imgproc.rotations.x >= -PI/3) {
      rx= imgproc.rotations.x;
    } else {

      rx=min(PI/3, imgproc.rotations.x);
      rx=max(-PI/3, rx);
    }
    if (imgproc.rotations.z<=PI/3 && imgproc.rotations.z >= -PI/3) {
      rz= imgproc.rotations.z;
    } else {

      rz=min(PI/3, imgproc.rotations.z);
      rz=max(-PI/3, rz);
    }
  }
  gameSurface.rotateZ(rz);
  gameSurface.rotateX(rx);

  gameSurface.fill(255);
  gameSurface.box(plateSquareLength, plateSquareheight, plateSquareLength);

  //sphere
  gameSurface.pushMatrix(); 
  if (!shiftMode) {
    sphere.checkEdges();
    sphere.checkCylinderCollision();
    sphere.update();
  }
  sphere.display();
  gameSurface.popMatrix();

  //cylinder
  gameSurface.pushMatrix();
  for (Cylinder part : cylinder) {
    part.display();
  }
  gameSurface.popMatrix();
  gameSurface.endDraw();
}
//-------------------------------------------------------------------------------------------

void draw() {
  if (vid.available() == true) {
    vid.read();
  }



  drawScoreBoard();
  drawBarChart();
  drawGame();
  drawTopView();
  drawdataVisualization();

  image(gameSurface, 0, 0);
  image(dataVisualization, 0, height - dataVisualizationLength);

  image(topView, spaceBetweenBlocks, height - dataVisualizationLength + spaceBetweenBlocks);
  image(scoreBoard, topViewLength + 2 * spaceBetweenBlocks, height - dataVisualizationLength + spaceBetweenBlocks);
  image(barChart, topViewLength + 3 * spaceBetweenBlocks + scoreBoardWidth, height - dataVisualizationLength + spaceBetweenBlocks);

  if (frameCount%90 == 0) { //30 frame par seconde
    int h = Math.min((int)(score/scoreSquare), numberSquare); 
    squaresList.add(h);
  }

  squareScoreWidth = 5 + 4 * hs.getPos() * squareScoreHeight; //values can be modifiy to adjust the width

  hs.update();
  hs.display();
}

//-------------------------------------------------------------------------------------------

void keyReleased() {
  if (shiftMode==true) {
    shiftMode=false;
    rx=0;
    rz=0;
  }
}

void keyPressed() {
  if (key==CODED) {
    if (keyCode==SHIFT) {
      shiftMode = true;
      shiftMode();
    }
  }
}

void mouseDragged() {
  if (!shiftMode && mouseY < height - dataVisualizationLength) {
    if (rx-(mouseY-pmouseY)/100.0 > -PI/3 && rx-(mouseY-pmouseY)/100.0 < PI/3) {
      rx= rx-((mouseY-pmouseY)/100.0)*ratio;
    }  

    if (rz+(mouseX-pmouseX)/100.0 > -PI/3 && rz+(mouseX-pmouseX)/100.0 < PI/3) { 
      rz=rz+((mouseX-pmouseX)/100.0)*ratio;
    }
  }
}

void mouseClicked() {
  if (shiftMode==true) {
    float posX = mouseX - width/2;
    float posY = mouseY - height/2;
    double border = plateSquareLength/2;
    if (posX > -border && posX < border && posY > -border && posY < border ) {  //check if on the plate       
      Cylinder  c = new Cylinder(new PVector(posX, 0, posY));
      if (!collision(c)) { //check if a cylinder or the ball is already here
        coordCylinder.add(c.location);
        cylinder.add(c);
      }
    }
  }
}

boolean collision(Cylinder c) {
  boolean collision = false;

  //check for all cylinder
  for (PVector cc : coordCylinder) {
    if (c.location.dist(cc) <= 2*Cylinder.cylinderBaseSize) {
      collision = true;
    }
  }

  //Check for the sphere, we change the position y of the cylinder to compare with the location of the sphere
  c.location = c.location.add(0, -(sphere.sphereSize + plateSquareheight/2), 0); 
  if (c.location.dist(sphere.location) <= (Cylinder.cylinderBaseSize + sphere.sphereSize)) {
    collision = true;
  }

  c.location = c.location.add(0, (sphere.sphereSize + plateSquareheight/2), 0);

  return collision;
}

void shiftMode() {
  if (shiftMode) {
    sphere.velocity = new PVector(0, 0, 0);
    rx = -PI/2;
    rz = 0;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (e < 0 && ratio - 0.1 > 0.4) ratio -= 0.1;
  if (e > 0 && ratio + 0.1 < 1.2 ) ratio += 0.1;
}

//-------------------------------------------------------------------------------------------

class My2DPoint {
  float x;
  float y;

  My2DPoint(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

class My3DPoint {
  float x;
  float y;
  float z;

  My3DPoint(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {

  float X1 = p.x - eye.x; // on applique
  float Y1 = p.y - eye.y;

  float U1 = -p.z / (eye.z) + 1;
  X1 = X1 / U1;
  Y1 = Y1 / U1;
  return new My2DPoint(X1, Y1);
}

class My3DBox {
  My3DPoint[] p;

  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ) {
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p = new My3DPoint[] { new My3DPoint(x, y + dimY, z + dimZ), 
      new My3DPoint(x, y, z + dimZ), 
      new My3DPoint(x + dimX, y, z + dimZ), 
      new My3DPoint(x + dimX, y + dimY, z + dimZ), 
      new My3DPoint(x, y + dimY, z), origin, 
      new My3DPoint(x + dimX, y, z), 
      new My3DPoint(x + dimX, y + dimY, z) };
  }

  My3DBox(My3DPoint[] p) {
    this.p = p;
  }
}

class My2DBox {

  My2DPoint[] s;

  My2DBox(My2DPoint[] s) {
    this.s = s;
  }

  void render() {
    line(s[0].x, s[0].y, s[1].x, s[1].y);
    line(s[0].x, s[0].y, s[3].x, s[3].y);
    line(s[0].x, s[0].y, s[4].x, s[4].y);
    line(s[1].x, s[1].y, s[5].x, s[5].y);
    line(s[2].x, s[2].y, s[6].x, s[6].y);
    line(s[2].x, s[2].y, s[3].x, s[3].y);
    line(s[3].x, s[3].y, s[7].x, s[7].y);
    line(s[7].x, s[7].y, s[4].x, s[4].y);
    line(s[7].x, s[7].y, s[6].x, s[6].y);
    line(s[6].x, s[6].y, s[5].x, s[5].y);
    line(s[5].x, s[5].y, s[4].x, s[4].y);
    line(s[2].x, s[2].y, s[1].x, s[1].y);
  }
}

float[] homogeneous3DPoint(My3DPoint p) {
  float[] result = { p.x, p.y, p.z, 1 };
  return result;
}

float[][] rotateXMatrix(float angle) {
  return (new float[][] { { 1, 0, 0, 0 }, 
    { 0, cos(angle), sin(angle), 0 }, 
    { 0, -sin(angle), cos(angle), 0 }, { 0, 0, 0, 1 } });
}

float[][] rotateYMatrix(float angle) {
  return (new float[][] { { cos(angle), 0, sin(angle), 0 }, 
    { 0, 1, 0, 0 }, { -sin(angle), 0, cos(angle), 0 }, 
    { 0, 0, 0, 1 } });
}

float[][] rotateZMatrix(float angle) {
  return (new float[][] { { cos(angle), -sin(angle), 0, 0 }, 
    { sin(angle), cos(angle), 0, 0 }, { 0, 0, 1, 0 }, 
    { 0, 0, 0, 1 } });
}

float[][] scaleMatrix(float x, float y, float z) {
  return (new float[][] { { x, 0, 0, 0 }, { 0, y, 0, 0 }, { 0, 0, z, 0 }, 
    { 0, 0, 0, 1 } });
}

float[][] translationMatrix(float x, float y, float z) {
  return (new float[][] { { 1, 0, 0, x }, { 0, 1, 0, y }, { 0, 0, 1, z }, 
    { 0, 0, 0, 1 } });
}

float[] matrixProduct(float[][] a, float[] b) {
  float[] f = new float[4];
  f[0] = a[0][0] * b[0] + a[0][1] * b[1] + a[0][2] * b[2]
    + a[0][3] * b[3];
  f[1] = a[1][0] * b[0] + a[1][1] * b[1] + a[1][2] * b[2]
    + a[1][3] * b[3];
  f[2] = a[2][0] * b[0] + a[2][1] * b[1] + a[2][2] * b[2]
    + a[2][3] * b[3];
  f[3] = a[3][0] * b[0] + a[3][1] * b[1] + a[3][2] * b[2]
    + a[3][3] * b[3];
  return f;
}

My3DPoint euclidian3DPoint(float[] a) {
  My3DPoint result = new My3DPoint(a[0] / a[3], a[1] / a[3], a[2] / a[3]);
  return result;
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  My3DPoint[] M = new My3DPoint[8];
  for (int i = 0; i < 8; ++i) {
    float[] s = { box.p[i].x, box.p[i].y, box.p[i].z, 1 };
    s = matrixProduct(transformMatrix, s);
    M[i] = euclidian3DPoint(s);
  }

  return new My3DBox(M);
}

My2DBox projectBox(My3DPoint eye, My3DBox box) {
  My3DPoint eye1=eye;
  My2DPoint[] s= new My2DPoint[8];
  for (int i=0; i<=7; ++i) {
    s[i]= projectPoint(eye1, box.p[i]);
  }
  return new My2DBox(s);
}