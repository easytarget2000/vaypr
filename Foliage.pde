class Foliage extends Being {

  private static final int NUM_OF_INITIAL_NODES = 64;

  private static final int MAX_AGE = 256;

  private static final int ADD_NODE_LIMIT = 16;

  private static final float PUSH_FORCE = 4f;

  private Node mFirstNode;

  private float mDisplaySize;

  static final int LINE_MODE = 0;

  private float mNodeDensity;

  private float mNodeRadius;

  private float mNeighbourGravity;

  private float mPreferredNeighbourDistance;

  private float mMaxPushDistance;

  //    private NewNode mSpecialNode;

  Foliage() {
    mDisplaySize = max(displayWidth, displayHeight);
    final float nodeSize = mDisplaySize / 300f;
    mNodeRadius = nodeSize * 0.5f;
    mNodeDensity = (int) random(NUM_OF_INITIAL_NODES);
    mNeighbourGravity = mNodeRadius * 0.5f;
    mMaxPushDistance = mDisplaySize * 0.1f;
    mJitter = mDisplaySize * 0.002f;

    //Log.d(
    //  TAG, 
    //  "Initialized: node size: " + nodeSize
    //  + ", rect mode: " + mPaintMode
    //  + ", node density: " + mNodeDensity
    //  );
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

  boolean drawIfAlive(final color c) {

    if (++mAge > MAX_AGE) {
      return false;
    }

    mStopped = false;

    noFill();
    stroke(c);

    Node currentNode = mFirstNode;
    Node nextNode;
    int nodeCounter = 0;

    for (int i = 0; i < 2; i++) {
      beginShape();
      if (i == 0) {
        vertex(currentNode.mX, currentNode.mY);
      } else {
        vertex(width - currentNode.mX, currentNode.mY);
      }

      do {
        nextNode = currentNode.mNext;
        if (nextNode == null) {
          break;
        }

        currentNode.update();

        if (nodeCounter < ADD_NODE_LIMIT && (++nodeCounter % mNodeDensity == 0)) {
          addNodeNextTo(currentNode);
        }

        if ((int) random(20) % 20 == 0) {
          final float nodeRadius = random(mNodeRadius * 2f);
          ellipse(currentNode.mX, currentNode.mY, nodeRadius, nodeRadius);
        }

        if (i == 0) {
          vertex(nextNode.mX, nextNode.mY);
        } else {
          vertex(width - nextNode.mX, nextNode.mY);
        }
        currentNode = nextNode;
      } while (!mStopped && currentNode != mFirstNode);

      endShape();
    }
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

        mX += cos(angle) * force;
        mY += sin(angle) * force;

        otherNode = otherNode.mNext;
      } while (!mStopped);
    }
  }
}