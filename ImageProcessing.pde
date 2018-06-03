import java.util.Collections;
import gab.opencv.*;
import processing.video.*;
class ImageProcessing extends PApplet {


  //PARAMETERS-------------------------------------------------------------------
  TwoDThreeD twoDthreeD;

  PImage img1;
  int camW=650;
  int camH=550;
  PImage houghImg;

  int minVotes = 130;
  int round=10;
  public PVector rotations=new PVector(0, 0, 0);
  int nlines=6;
  OpenCV opencv;
  List<PVector> bestQuads=new ArrayList();


  //-------------------------------------------------------------------------------
  void settings() { 
    size(2*camW, camH);
  }

  void setup() {






    opencv = new OpenCV(this, 100, 100);
    twoDthreeD=new TwoDThreeD(camW, camH, 5);
  }



  //------------------------------------------------------------------------------
  void draw() {

    img1=cam2.get();

    image(img1, 0, 0);
    PImage img2=img1.copy();
    PImage blob=img1.copy();

    //IMAGE DE GAUCHE ---------------------------------------------------------------

    // Hue/Brightness/Saturation thresholding:
    img2 = thresholdHSB(img2, 59, 140, 52, 255, 20, 186);

    // blob detection:
    BlobDetection b = new BlobDetection();
    img2=b.findConnectedComponents(img2, true);

    //blurring:
    img2=gaussBlurr(img2);

    //edge detection:
    img2= scharr(img2);

    //suppression of pixels with low brightness:
    img2= threshold(img2, 120);


    //hough transform : 
    List<PVector> q= hough(img2, nlines);
    plotLines(q, img2);
    List<PVector> temp=new ArrayList();
    for (PVector i : bestQuads) {
      temp.add(new PVector(i.x, i.y, 1));
    }

    rotations= twoDthreeD.get3DRotations(temp);

    rotations.x=degrees(rotations.x);
    rotations.z=degrees(rotations.z);









    //IMAGE DROITE (BLOB)-----------------------------------------------------------

    //thresholdHSB
    blob = thresholdHSB(blob, 80, 135, 40, 255, 40, 255);

    // blob detection:
    BlobDetection C = new BlobDetection();
    blob=C.findConnectedComponents(blob, true);

    image(blob, img1.width, 0);
  }
  //END DRAW-------------------------------------------------------------------

  void plotLines(List<PVector> lines, PImage edgeImg) {

    QuadGraph Q = new QuadGraph();
    bestQuads=Q.findBestQuad(lines, edgeImg.width, edgeImg.height, edgeImg.width*edgeImg.height, edgeImg.width*edgeImg.height/10, false);  //jijijijijjijijjijijijijdiajfiajfiajfiajfidjasfiajifdjsaifjasijfdiasjfidasjfiasjfiajfiajfiajidsjfiajfdiasjfiasjdfiajidfjasifjaisfjaisjfiasjfiasjfsaisf
    for (int j=0; j<bestQuads.size(); ++j) {
      fill(color((int)(255*random(0, 1)), (int)(255*random(0, 1)), (int)(255*random(0, 1))), 80);
      ellipse(bestQuads.get(j).x, bestQuads.get(j).y, 55, 55);
    }

    for (int idx = 0; idx < lines.size(); idx++) {
      PVector line = lines.get(idx);
      float r = line.x;
      float phi = line.y;
      int x0 = 0;
      int y0 = (int) (r / sin(phi));
      int x1 = (int) (r / cos(phi));
      int y1 = 0;
      int x2 = edgeImg.width;
      int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
      int y3 = edgeImg.width;
      int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
      // Finally, plot the lines
      stroke(204, 102, 0);
      if (y0 > 0) {
        if (x1 > 0)
          line(x0, y0, x1, y1);
        else if (y2 > 0)
          line(x0, y0, x2, y2);
        else
          line(x0, y0, x3, y3);
      } else {
        if (x1 > 0) {
          if (y2 > 0)
            line(x1, y1, x2, y2);
          else
            line(x1, y1, x3, y3);
        } else
          line(x2, y2, x3, y3);
      }
    }
  }
  //-------------------------------------------------------------------------------

  List<PVector> hough(PImage edgeImg, int nlines) {
    ArrayList<Integer>  bestCandidates=new ArrayList();
    float discretizationStepsPhi = 0.06f;
    float discretizationStepsR = 2.5f;
    int phiDim = (int) (Math.PI / discretizationStepsPhi + 1);
    int rDim = (int) ((sqrt(
      edgeImg.width * edgeImg.width + edgeImg.height * edgeImg.height)
      * 2) / discretizationStepsR + 1);
    float[] tabSin = new float[phiDim];
    float[] tabCos = new float[phiDim];
    float ang = 0;
    float inverseR = 1.f / discretizationStepsR;
    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
      tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
      tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
    }
    int[] accumulator;
    accumulator = new int[phiDim * rDim];

    for (int y = 0; y < edgeImg.height; y++) {
      for (int x = 0; x < edgeImg.width; x++) {
        // Are we on an edge?
        if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
          for (int i = 0; i < phiDim; ++i) {
            float r = x * tabCos[i] + y * tabSin[i];
            int  rindex= (int)(r + rDim/2);
            accumulator[i * rDim +  rindex] += 1;
          }
        }
      }
    }

    List<PVector> lines = new ArrayList<PVector>();
    for (int idx = 0; idx < accumulator.length; idx++) {

      if (accumulator[idx] > minVotes) { 
        int max=0;
        for (int i=-round/2; i< round/2; ++i) {
          for (int j=-round/2; j< round/2; ++j) {
            if (idx+i*phiDim+j>0 &&idx+i*phiDim+j< accumulator.length ) {
              if (accumulator[idx+i*phiDim+j]>max) {
                max=accumulator[idx+i*phiDim+j];
              }
            }
          }
        }
        if (accumulator[idx]==max) {
          bestCandidates.add(idx);
        }
      }
    }
    houghImg = createImage(rDim, phiDim, ALPHA);
    for (int i = 0; i < accumulator.length; i++) {
      houghImg.pixels[i] = color(min(255, accumulator[i]));
    }
    houghImg.resize(400, 400);
    houghImg.updatePixels();
    Collections.sort(bestCandidates, new HoughComparator(accumulator));
    for (int i=0; i<nlines; ++i) {
      // first, compute back the (r, phi) polar coordinates:
      if (i < bestCandidates.size()) {
        int idx = bestCandidates.get(i);
        int accPhi = (int) (idx/ (rDim));  // accphi==0.
        int accR = idx - (accPhi) * (rDim);
        float r = (accR - (rDim) * 0.5f) * discretizationStepsR;
        float phi = accPhi * discretizationStepsPhi;
        lines.add(new PVector(r, phi));
      }
    }
    return lines;
  }

  //-------------------------------------------------------------------------------
  PImage threshold(PImage img, int threshold) {
    // create a new, initially transparent, 'result' image
    PImage result = createImage(img.width, img.height, RGB);

    for (int i = 0; i < img.width * img.height; i++) {
      if (brightness(img.pixels[i])>threshold) { 
        result.pixels[i]=color(255);
      } else {
        result.pixels[i]=color(0);
      }
    }
    return result;
  }
  //-------------------------------------------------------------------------------

  PImage thresholdHue(PImage img, int thresholdMin, int thresholdMax) {
    PImage result = createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.width * img.height; i++) {
      if (hue(img.pixels[i])>thresholdMin && hue(img.pixels[i])<thresholdMax ) {
        result.pixels[i]=img.pixels[i];
      } else {
        result.pixels[i]=color(0);
      }
    }

    return result;
  }
  //-------------------------------------------------------------------------------
  PImage thresholdHSB(PImage img, int minH, int maxH, int minS, int maxS, int minB, int maxB) {
    PImage result=createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.width * img.height; i++) {

      if (saturation(img.pixels[i])<maxS && saturation(img.pixels[i])>minS
        && hue(img.pixels[i])<maxH && hue(img.pixels[i])>minH 
        && brightness(img.pixels[i])< maxB 
        && brightness(img.pixels[i])> minB) {
        result.pixels[i]=color(255);
      } else {
        result.pixels[i]=color(0);
      }
    }
    return result;
  }
  //-------------------------------------------------------------------------------
  boolean imagesEqual(PImage img1, PImage img2) {
    if (img1.width != img2.width || img1.height != img2.height)
      return false;
    for (int i = 0; i < img1.width*img1.height; i++)
      //assuming that all the three channels have the same value
      if (red(img1.pixels[i]) != red(img2.pixels[i]))
        return false;
    return true;
  }
  //-------------------------------------------------------------------------------
  PImage gaussBlurr(PImage img) {
    PImage result=img.copy();
    int w=99;
    float[][] gaussKer = {
      { 9, 12, 9 }, 
      { 12, 15, 12}, 
      { 9, 12, 9 } };
    result=convolute(img, gaussKer, w);

    return result;
  }
  //-------------------------------------------------------------------------------

  PImage convolute(PImage img, float[][] ker, float weight) {
    PImage result = createImage(img.width, img.height, ALPHA);
    // clear the image
    for (int i = 0; i < img.width * img.height; i++) {
      result.pixels[i] = color(0);
    }


    float[] buffer = new float[img.width * img.height];
    float sum_h = 0;
    for (int i = 2; i< img.height -2; i++) {
      sum_h = 0;
      for (int j = 2; j < img.width -2; j++) {
        sum_h = 
          brightness(img.pixels[(i-1)*img.width + j-1])*(int)ker[0][0] + 
          brightness(img.pixels[(i-1)*img.width + j])*(int)ker[0][1] +
          brightness(img.pixels[(i-1)*img.width + j+1])*(int)ker[0][2]+
          brightness(img.pixels[(i)*img.width + j-1])*(int)ker[1][0]+
          brightness(img.pixels[(i)*img.width + j]) * (int)ker[1][1]+
          brightness(img.pixels[(i)*img.width + j+1])*(int)ker[1][2]+
          brightness(img.pixels[(i+1)*img.width + j-1])*(int)ker[2][0]+
          brightness(img.pixels[(i+1)*img.width + j]) * (int)ker[2][1]+
          brightness(img.pixels[(i+1)*img.width + j+1])*(int)ker[2][2];
        buffer[i*img.width + j] = sum_h;
      }
    }
    for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
      for (int x = 2; x < img.width - 2; x++) { // Skip left and right
        int val=(int) ((buffer[y * img.width + x] / weight));
        result.pixels[y * img.width + x]=color((val));
      }
    }
    return result;
  }

  //-------------------------------------------------------------------------------
  PImage scharr(PImage img) {
    PImage result = createImage(img.width, img.height, ALPHA);
    for (int i = 0; i < img.width * img.height; i++) {
      result.pixels[i] = color(0);
    }
    float max=0;
    float[] buffer = new float[img.width * img.height];

    float sum_h = 0;
    float sum_v = 0;
    for (int i = 2; i< img.height -2; i++) {
      sum_h = 0;
      sum_v = 0;
      for (int j = 2; j < img.width -2; j++) {
        sum_h = 
          brightness(img.pixels[(i-1)*img.width + j-1])*( 3 )+ 
          brightness(img.pixels[(i-1)*img.width +  j ])*( 10)+
          brightness(img.pixels[(i-1)*img.width + j+1])*( 3 )+
          brightness(img.pixels[(i+1)*img.width + j-1])*(-3 )+
          brightness(img.pixels[(i+1)*img.width +  j ])*(-10)+
          brightness(img.pixels[(i+1)*img.width + j+1])*(-3 );

        sum_v = 
          brightness(img.pixels[(i-1)*img.width + j-1])*( 3 )+ 
          brightness(img.pixels[(i-1)*img.width + j+1])*(-3 )+
          brightness(img.pixels[( i )*img.width + j-1])*( 10)+
          brightness(img.pixels[( i )*img.width + j+1])*(-10)+
          brightness(img.pixels[(i+1)*img.width + j-1])*( 3 )+
          brightness(img.pixels[(i+1)*img.width + j+1])*(-3 );

        float sum = sqrt(pow(sum_h, 2)+ pow(sum_v, 2));
        buffer[i*img.width + j] = sum;
        if (sum > max) max = sum;
      }
    }
    for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
      for (int x = 2; x < img.width - 2; x++) { // Skip left and right
        int val=(int) ((buffer[y * img.width + x] / max)*255);
        result.pixels[y * img.width + x]=color(val);
      }
    }
    return result;
  }
  //-------------------------------------------------------------------------------
}