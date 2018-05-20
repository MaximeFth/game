import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;
import java.awt.Color;
import java.util.Hashtable;

class BlobDetection {

  List<Color> colors=new ArrayList<Color>();

  int infinity=Integer.MAX_VALUE;
  PImage findConnectedComponents(PImage input, boolean onlyBiggest) {

    colors.add(Color.blue);
    colors.add(Color.cyan);
    colors.add(Color.pink);
    colors.add(Color.green);
    colors.add(Color.magenta);
    colors.add(Color.orange);
    colors.add(Color.yellow);
    colors.add(Color.red);
    colors.add(Color.gray);


    // First pass: label the pixels and store labels' equivalences
    int [] labels= new int [input.width*input.height];
    List<TreeSet<Integer>> labelsEquivalences = new ArrayList<TreeSet<Integer>>();
    labelsEquivalences.add(new TreeSet<Integer>());
    labelsEquivalences.add(new TreeSet<Integer>());
    labelsEquivalences.add(new TreeSet<Integer>());
    labelsEquivalences.add(new TreeSet<Integer>());
    int currentLabel=1;
    PImage output= createImage( input.width, input.height, RGB);
    int label1 = 0;
    int label2=0;
    int label3=0;
    int label4=0;



    //initiliazation tab of labels
    for (int i = 0; i< input.width * input.height; i++) {
      labels[i] = -1;
    }

    //traverse all pixel
    for (int i=0; i < input.height; ++i) {
      for (int j=0; j < input.width; ++j) {
        if (brightness(input.pixels[i*input.width+j])==0) {

          if (i==0 || j==0) {
            label1=-1;
          } else {
            label1=labels[(i-1)*input.width+j-1];
          }
          if (i==0) {
            label2=-1;
          } else {
            label2=labels[(i-1)*input.width+j];
          }
          if (i==0 || j==input.width-1) {
            label3=-1;
          } else {
            label3=labels[(i-1)*input.width+j+1];
          }
          if (j==0) {
            label4=-1;
          } else {
            label4=labels[i*input.width+j-1];
          }


          //first pixel
          if (i==0 && j==0) {
            labels[0] = currentLabel;
          } else if (label1 == -1 && label2 == -1 && label3== -1 && label4 == -1) {
            //all pixels around are not labeled
            currentLabel++;
            labels[i*input.width + j] = currentLabel;
            labelsEquivalences.add(new TreeSet<Integer>());
          } else {
            //there is a label not equal to -1 (labeled)

            //take the min of valid label
            if (label1 == -1) {
              label1 = infinity;
            }
            if (label2 == -1) {
              label2 = infinity;
            }
            if (label3 == -1) {
              label3 = infinity;
            }
            if (label4 == -1) {
              label4 = infinity;
            }

            int minLabel=Math.min(Math.min(label1, label2), Math.min(label3, label4));
            //label the current pixel
            labels[i*input.width + j] = minLabel;

            //put equivalence of valid label
            if (label1 != infinity) {
              labelsEquivalences.get(label1).add(label1);
              labelsEquivalences.get(label1).add(label2);
              labelsEquivalences.get(label1).add(label3);
              labelsEquivalences.get(label1).add(label4);
            }
            if (label2 != infinity) {
              labelsEquivalences.get(label2).add(label1);
              labelsEquivalences.get(label2).add(label2);
              labelsEquivalences.get(label2).add(label3);
              labelsEquivalences.get(label2).add(label4);
            }
            if (label3 != infinity) {
              labelsEquivalences.get(label3).add(label1);
              labelsEquivalences.get(label3).add(label2);
              labelsEquivalences.get(label3).add(label3);
              labelsEquivalences.get(label3).add(label4);
            }
            if (label4 != infinity) {
              labelsEquivalences.get(label4).add(label1);
              labelsEquivalences.get(label4).add(label2);
              labelsEquivalences.get(label4).add(label3);
              labelsEquivalences.get(label4).add(label4);
            }
          }
        }
      }
    }//end of the double for


    //ArrayList<Integer> pixelNumber = new ArrayList<Integer>();
    Hashtable pixelNumber = new Hashtable<Integer, Integer>();
    for (int i=0; i<labels.length; ++i) {

      if (labels[i]!=-1) { //valid label

        if (! labelsEquivalences.get(labels[i]).isEmpty()) {

          labels[i]=labelsEquivalences.get(labels[i]).first(); //replace by the min equivalence
        }
      }
      if (onlyBiggest) {
        /*System.out.println("label"+labels[i]);
         pixelNumber.get(labels[i]);
         pixelNumber.set(labels[i], pixelNumber.get(labels[i])+1) ;
         */
        if (pixelNumber.containsKey(labels[i])) {
          int temp = (int)pixelNumber.get(labels[i]);
          pixelNumber.put(labels[i], temp+1);
        } else {
          pixelNumber.put(labels[i], 1);
        }
      }
    }
    // Finally,
    // if onlyBiggest==false, output an image with each blob colored in one uniform color
    // if onlyBiggest==true, output an image with the biggest blob colored in white and the others in black
    // TODO!
    if (!onlyBiggest) {
      for (int i=0; i<output.width*output.height; ++i) {
        if (labels[i]==-1) {
          output.pixels[i]=(Color.BLACK.getRGB());
        } else {
          output.pixels[i]=colors.get(labels[i]%colors.size()).getRGB();
        }
      }

      return output;
    } else {
      int maxIndex=0;
      int max=0;
      //System.out.println(pixelNumber.size());
      for (int i=0; i<pixelNumber.size(); ++i) {
        //System.out.println("i = "+i);
        if (pixelNumber.containsKey(i)) {
          if ((int)pixelNumber.get(i)>max) {
            maxIndex=i;
            max = (int)pixelNumber.get(i);
          }
        }
      }
      for (int i=0; i<output.width*output.height; ++i) {
        if (labels[i]==maxIndex) { 
          output.pixels[i]=Color.BLACK.getRGB();
        } else {
          output.pixels[i]=Color.GREEN.getRGB();
        }
      }

      return output;
    }
  }
}