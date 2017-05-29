class Foliage extends Being {

  private static final int NUM_OF_INITIAL_NODES = 64;

  private static final int MAX_AGE = 640;

  private static final int ADD_NODE_ROUND_LIMIT = 2;
  
  private static final int MAX_NUM_OF_NODES = 480;

  private static final float PUSH_FORCE = 4f;

  private Node mFirstNode;
  
  private int mNodeAddCounter = 0;

  private float mDisplaySize = max(width, height);

  static final int LINE_MODE = 0;

  private float mNodeDensity = (int) (NUM_OF_INITIAL_NODES / 16f);

  private float mNodeRadius = mDisplaySize / 300f;

  private float mNeighbourGravity = mNodeRadius * 0.5f;

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
      final float radius = random(mDisplaySize * 0.01f) + mDisplaySize * 0.01f;
      final float squeezeFactor = random(0.66f) + 0.66f;

      for (int i = 0; i < NUM_OF_INITIAL_NODES; i++) {
        final Node node = new Node();

        final float angleOfNode = TWO_PI * ((i + 1f) / NUM_OF_INITIAL_NODES);

        node.mX = circleCenterX
          + ((cos(angleOfNode) * radius) * squeezeFactor)
          + getJitter();
        node.mY = circleCenterY
          + (sin(angleOfNode) * radius)
          + getJitter();

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
      final Node node = new Node();

      node.mX = ((float) i / (float) NUM_OF_INITIAL_NODES * width) + getJitter();
      node.mY = mStartY + getJitter();

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

    final float[] x = new float[4];
    final float[] y = new float[4];

    int nodeCounter = 0;

    Node currentNode = mFirstNode;
    x[0] = currentNode.mX;
    y[0] = currentNode.mY;

    Node nextNode;

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
        //println("addNode: " + nodeCounter);
        addNodeNextTo(currentNode);
      }

      final int bezierIndex = (nodeCounter % 4) + 1;

      if (bezierIndex == 4) {
        bezier(
          x[0], y[0], 
          x[1], y[1], 
          x[2], y[2], 
          x[3], y[3]
          );
        //line(x[0], y[0], x[3], y[3]);

        bezier(
          width - x[0], y[0], 
          width - x[1], y[1], 
          width - x[2], y[2], 
          width - x[3], y[3]
          );

        x[0] = x[3] + 1;
        y[0] = y[3] + 1;
      } else {
        x[bezierIndex] = currentNode.mX;
        y[bezierIndex] = currentNode.mY;
      }

      currentNode = nextNode;
      ++nodeCounter;
    } while (!mStopped && currentNode != mFirstNode);
    return true;
  }

  private void addNodeNextTo(final Node node) {
    final Node oldNeighbour = node.mNext;
    if (oldNeighbour == null) {
      return;
    }

    final Node newNeighbour = new Node();

    newNeighbour.mX = (node.mX + oldNeighbour.mX) / 2;
    newNeighbour.mY = (node.mY + oldNeighbour.mY) / 2;

    node.mNext = newNeighbour;
    newNeighbour.mNext = oldNeighbour;
  }

  class Node {

    protected Node mNext;

    protected float mX;

    protected float mY;

    protected Node() {
    }

    protected Node(final float x, final float y) {
      mX = x;
      mY = y;
    }

    @Override
      public String toString() {
      return "[Line " + super.toString() + " at " + mX + ", " + mY + "]";
    }

    private float distanceToNode(final Node otherNode) {
      return distance(mX, mY, otherNode.mX, otherNode.mY);
    }

    private float angleToNode(final Node otherNode) {
      return angle(mX, mY, otherNode.mX, otherNode.mY);
    }

    private void update() {

      mX += getJitter();
      mY += getJitter();

      updateAcceleration();
    }

    protected void updateAcceleration() {
      Node otherNode = mNext;

      float force = 0f;
      float angle = 0f;

      do {

        if (otherNode == null || otherNode.mNext == this) {
          return;
        }

        final float distance = distanceToNode(otherNode);

        if (distance > mMaxPushDistance) {
          otherNode = otherNode.mNext;
          continue;
        }

        angle = angleToNode(otherNode) + (angle * 0.05f);

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

        if (force < 64) {
          mX += cos(angle) * force;
          mY += sin(angle) * force;
        }

        otherNode = otherNode.mNext;
      } while (!mStopped);
    }
  }
}