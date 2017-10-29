class Foliage extends Being {

  private static final int NUM_OF_INITIAL_NODES = 64;

  private static final int MAX_AGE = 640;

  private static final int ADD_NODE_ROUND_LIMIT = 4;

  private static final int MAX_NUM_OF_NODES = 1024;

  private static final float PUSH_FORCE = 8f;

  private Node mFirstNode;

  private int mNodeAddCounter = 0;

  private float mDisplaySize = max(width, height);

  static final int LINE_MODE = 0;

  private float mNodeDensity = (int) (NUM_OF_INITIAL_NODES / 16f);

  private float mNodeRadius = mDisplaySize / 256f;

  private float mNeighbourGravity = -mNodeRadius * 0.5f;

  private float mPreferredNeighbourDistance;

  private float mMaxPushDistance = mDisplaySize * 0.1f;

  Foliage() {
    //mJitter = mDisplaySize * 0.002f;
  }

  Foliage initCircle() {

    final int numberOfCircles = (int) random(5) + 1;

    Node lastNode = null;
    for (int c = 0; c < numberOfCircles; c++) {

      final float circleCenterX = mStartX + (getJitter() * 10f);
      final float circleCenterY = mStartY + (getJitter() * 10f);
      final float radius = random(mDisplaySize * 0.01f) + mDisplaySize * 0.001f;
      final float squeezeFactor = random(0.66f) + 0.66f;

      for (int i = 0; i < NUM_OF_INITIAL_NODES; i++) {

        final float angleOfNode = TWO_PI * ((i + 1f) / NUM_OF_INITIAL_NODES);
        final PVector vector = new PVector();

        vector.x = circleCenterX
          + ((cos(angleOfNode) * radius) * squeezeFactor)
          + getJitter();
        vector.y = circleCenterY
          + (sin(angleOfNode) * radius)
          + getJitter();
        //vector.z = 0f;

        final Node node = new Node(vector);

        if (mFirstNode == null) {
          mFirstNode = node;
          lastNode = node;
        } else if (i == NUM_OF_INITIAL_NODES - 1) {
          mPreferredNeighbourDistance = node.distanceToNode(lastNode);
          lastNode.mNext = node;
          node.mNext = mFirstNode;
        } else {
          lastNode.mNext = node;
          lastNode = node;
        }
      }
    }

    return this;
  }

  Foliage initLine() {
    //mDrawBezier = true;

    Node lastNode = null;

    for (int i = 0; i < NUM_OF_INITIAL_NODES; i++) {

      final PVector vector = new PVector();
      vector.x = ((float) i / (float) NUM_OF_INITIAL_NODES * width) + getJitter();
      vector.y = mStartY + getJitter();
      //vector.z = 0f;

      final Node node = new Node(vector);

      if (mFirstNode == null) {
        mFirstNode = node;
        lastNode = node;
      } else if (i == NUM_OF_INITIAL_NODES - 1) {
        mPreferredNeighbourDistance = node.distanceToNode(lastNode);
        lastNode.mNext = node;
      } else {
        lastNode.mNext = node;
        lastNode = node;
      }
    }

    return this;
  }

  boolean drawIfAlive(final color c) {

    if (++mAge > MAX_AGE) {
      return false;
    }

    mStopped = false;

    noFill();
    stroke(c);

    int nodeCounter = 0;

    Node currentNode = mFirstNode;

    Node nextNode;
    for (int i = 0; i < 8; i++) {
      do {
        nextNode = currentNode.mNext;
        if (nextNode == null) {
          break;
        }

        currentNode.update();

        if (
          ++mNodeAddCounter < ADD_NODE_ROUND_LIMIT
          && nodeCounter < MAX_NUM_OF_NODES
          && (nodeCounter % mNodeDensity == 0)
          ) {
          addNodeNextTo(currentNode);
        }

        point(
          currentNode.vector.x, 
          currentNode.vector.y,
          currentNode.vector.z
          );

        //pushMatrix();
        //translate(currentNode.vector.x, currentNode.vector.y, currentNode.vector.z);
        //sphere(mNodeRadius * 2f);
        //popMatrix();

        currentNode = nextNode;
        ++nodeCounter;
      } while (!mStopped && currentNode != mFirstNode);
    }
    return true;
  }

  private void addNodeNextTo(final Node node) {
    final Node oldNeighbour = node.mNext;
    if (oldNeighbour == null) {
      return;
    }

    final Node newNeighbour = new Node();

    newNeighbour.vector = PVector.add(node.vector, oldNeighbour.vector).mult(0.5f);

    node.mNext = newNeighbour;
    newNeighbour.mNext = oldNeighbour;
  }

  class Node {

    protected Node mNext;

    protected PVector vector;

    protected Node() {
    }

    protected Node(final PVector vector_) {
      vector = vector_;
    }

    @Override
      public String toString() {
      return "[Line " + super.toString() + " at " + vector.x + ", " + vector.y + "]";
    }

    private float distanceToNode(final Node otherNode) {
      return PVector.dist(vector, otherNode.vector);
    }

    private PVector vectorToOtherNode(final Node otherNode) {
      return PVector.sub(otherNode.vector, vector);
    }

    private float angle(final Node otherNode) {
      return angle(vector.x, vector.y, otherNode.vector.x, otherNode.vector.y);
    }

    private float angle(
      final float x1, 
      final float y1, 
      final float x2, 
      final float y2
      ) {
      final float calcAngle = atan2(
        -(y1 - y2), 
        x2 - x1
        );

      if (calcAngle < 0) {
        return calcAngle + TWO_PI;
      } else {
        return calcAngle;
      }
    }

    private void update() {

      vector.x += getJitter();
      vector.y += getJitter();
      vector.z += getJitter();

      updateAcceleration();
    }

    protected void updateAcceleration() {
      Node otherNode = mNext;

      PVector forceVector = new PVector(0f, 0f);
      float force = 0f;
      float angle = 0f;

      do {

        final float distance = distanceToNode(otherNode);

        if (distance > mMaxPushDistance) {
          otherNode = otherNode.mNext;
          continue;
        }

        final PVector vectorToOtherNode = vectorToOtherNode(otherNode);
        //println("From: " + components(vector) + " to: " + components(otherNode.vector) + " --> : " + components(vectorToOtherNode));
        angle = angle(otherNode) + (angle * 0.05);

        force *= 0.05;

        if (otherNode == mNext) {

          if (distance > mPreferredNeighbourDistance) {
            //                        force = mPreferredNeighbourDistanceHalf;
            force += (distance / PUSH_FORCE);
          } else {
            force -= mNeighbourGravity;
          }
        } else {

          if (distance < mNodeRadius) {
            force -= mNodeRadius;
          } else {
            force -= (PUSH_FORCE / distance);
          }
        }

        //forceVector.add(vectorToOtherNode.setMag(-force));
        //println("distance: " + distance + ", force: " + force);
        //println("forceVector: " + components(forceVector));
        //vector.add(forceVector);
        //forceVector.mult(0.05f);

        vector.add(vectorToOtherNode.setMag(force));

        otherNode = otherNode.mNext;
      } while (otherNode != null && otherNode != this);

      //println();
    }
  }

  private String components(final PVector vector) {
    return "[x: " + vector.x + ", y: " + vector.y + "]";
    //return "[x: " + vector.x + ", y: " + vector.y + ", z:" + vector.z + "]";
  }

  private color getRandomColor() {
    return color(
      (int) random(100) + 155, 
      (int) random(100) + 155, 
      (int) random(100) + 155, 
      40
      );
  }
}