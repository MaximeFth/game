class Sphere {
  PVector location;
  public PVector velocity;
  float ratioScoreVelocity=1;
  PVector gravityForce;
  final float gravityConstant = 0.1;
  final float sphereSize = 23;
  final float coefWall = 0.9;
  final color colorBall = color(246, 100, 87);

  Sphere() {
    location = new PVector(0, -(sphereSize + plateSquareheight/2), 0); // on top of the center of the plate
    velocity = new PVector(0, 0, 0);
    gravityForce = new PVector(0, 0, 0);
  }

  void update() {

    //equation of application of gravity
    gravityForce.z = -sin(imgproc.rotations.x) * gravityConstant;
    gravityForce.x = sin(imgproc.rotations.z) * gravityConstant;
    velocity.add(gravityForce);
    float normalForce = 1;
    float mu = 0.01;
    float frictionMagnitude = normalForce * mu;
    PVector friction = velocity.copy();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    //end of equation

    velocity.add(friction);
    location.add(velocity);
    velocity.add(gravityForce);
  }

  void checkCylinderCollision() {


    for (PVector part : coordCylinder) { 
      part.add(0, -(sphereSize + plateSquareheight/2), 0); // we must change the location to compare with the sphere one
      if (location.dist(part) <= (Cylinder.cylinderBaseSize + sphereSize)) {
        score=score+ ratioScoreVelocity*mag(velocity.x, velocity.y);
        PVector velocity2D = new PVector(velocity.x, velocity.z);
        PVector location2D = new PVector(location.x, location.z);
        PVector part2D = new PVector(part.x, part.z);

        //equation of the collision
        PVector n = location2D.sub(part2D).normalize();
        float dotProduct = velocity2D.dot(n);
        velocity2D = velocity2D.sub(n.mult(2 * dotProduct));
        //end of the equation

        velocity.x = velocity2D.x;
        velocity.z = velocity2D.y;
      }
      part.add(0, (sphereSize + plateSquareheight/2), 0); // we rechange the location of the cylinder
    }
  }

  void display() {
    gameSurface.pushMatrix();
    gameSurface.translate(location.x, location.y, location.z);
    gameSurface.fill(colorBall);
    gameSurface.noStroke();
    gameSurface.sphere(sphereSize);
    gameSurface.popMatrix();
  }

  void checkEdges() {
    if (location.x < -plateSquareLength / 2 + sphereSize) {
      velocity.x = abs(velocity.x) * (coefWall);
      score=score- ratioScoreVelocity*mag(velocity.x, velocity.y);
    }
    if (location.x > plateSquareLength / 2 - sphereSize) {
      velocity.x = abs(velocity.x) * (-coefWall);
      score=score- ratioScoreVelocity*mag(velocity.x, velocity.y);
    }
    if (location.z < -plateSquareLength / 2 + sphereSize) {
      velocity.z = abs(velocity.z) * (coefWall);
      score=score- ratioScoreVelocity*mag(velocity.x, velocity.y);
    }
    if (location.z > plateSquareLength / 2 - sphereSize) {
      velocity.z = abs(velocity.z) * (-coefWall);
      score=score- ratioScoreVelocity*mag(velocity.x, velocity.y);
    }
  }
}