class Cylinder {

    color colorCylinder = color(246, 100, 87);
    final static float  cylinderBaseSize = 20;
    final float cylinderHeight = 50;
    final int cylinderResolution = 40;
    PShape openCylinder = new PShape();
    PShape top = new PShape();
    PShape bottom = new PShape();
    PVector location;

    Cylinder(PVector location) {
        this.location = location;
        float angle;
        float[] x = new float[cylinderResolution + 1];
        float[] y = new float[cylinderResolution + 1];
        //tab of angle
        for (int i = 0; i < x.length; i++) {
            angle = (TWO_PI / cylinderResolution) * i;
            x[i] = sin(angle) * cylinderBaseSize;
            y[i] = cos(angle) * cylinderBaseSize;
        }
        
        //creation of the side part of the cylinder
        openCylinder = createShape();
        openCylinder.beginShape(QUAD_STRIP);
        
        //draw the border of the cylinder
        for (int i = 0; i < x.length; i++) {
            openCylinder.vertex(x[i], y[i], 0);
            openCylinder.vertex(x[i], y[i], cylinderHeight);
        }
        openCylinder.endShape();
        
        //creation of the top part of the cylinder
        top = createShape();
        top.beginShape(TRIANGLE_FAN);
        top.vertex(0, 0, 0);
        for (int i = 0; i < x.length; i++) {
            top.vertex(x[i], y[i], 0);
        }
        top.endShape();

        //creation of the bottom part of the cylinder
        bottom = createShape();
        bottom.beginShape(TRIANGLE_FAN);
        bottom.vertex(0, 0, cylinderHeight);
        for (int i = 0; i < x.length; i++) {
            bottom.vertex(x[i], y[i], cylinderHeight);
        }
        bottom.endShape();

    }

    void display() {
        gameSurface.pushMatrix();
        gameSurface.fill(colorCylinder);
        gameSurface.translate(location.x, location.y, location.z);
        gameSurface.rotateX(PI / 2);

        gameSurface.shape(openCylinder);
        gameSurface.shape(top);
        gameSurface.shape(bottom);

        gameSurface.popMatrix();
    }

}