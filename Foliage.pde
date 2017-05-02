class Foliage extends Being {

  private static final int NUM_OF_INITIAL_NODES = 64;

  private static final int MAX_AGE = 2;

  private static final int ADD_NODE_LIMIT = 128;

  private static final float PUSH_FORCE = 8f;

  private Node mFirstNode;

  private float mDisplaySize;

  private boolean mSymmetric;

  static final int LINE_MODE = 0;

  private int mPaintMode;

  private PImage mImage;

  private boolean mChangeAlpha = false;

  private float mNodeDensity;

  private float mNodeRadius;

  private float mNeighbourGravity;

  private float mPreferredNeighbourDistance;

  private float mMaxPushDistance;

  private boolean mPaintedInitialFilling = false;

  //    private NewNode mSpecialNode;

  Foliage() {
    mDisplaySize = max(displayWidth, displayHeight);
    final float nodeSize = mDisplaySize / 300f;
    mNodeRadius = nodeSize * 0.5f;
    mNodeDensity = 1 + random(10);
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

  void setImage(final PImage image) {
    mImage = image;
  }

  Foliage initCircle(final float x, final float y) {

    final int numberOfCircles = (int) random(5) + 1;

    Node lastNode = null;
    for (int c = 0; c < numberOfCircles; c++) {

      final float circleCenterX = x + (getJitter() * 10f);
      final float circleCenterY = y + (getJitter() * 10f);
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

  Foliage initGrill() {

    final int numberOfLines = 5;

    final int numberOfNodesPerLine = NUM_OF_INITIAL_NODES / numberOfLines;

    final float lineSpacing = width / numberOfLines * 0.9f;

    final float lineStart = 50f;

    final float lineLength = height - 100f;

    Node lastNode = null;

    //println("Foliage: initGrill(): ------");

    for (int i = 0; i < NUM_OF_INITIAL_NODES; i++) {
      final Node node = new Node();

      final int line = i / numberOfNodesPerLine;

      node.mX = lineStart + (lineSpacing * line);

      final float relativeDistanceFromLineStart = ((float) i - (numberOfNodesPerLine * line)) / (float) numberOfNodesPerLine;
      final float distanceFromLineStart = lineLength * relativeDistanceFromLineStart;

      if (line % 2 == 0) {
        node.mY = lineStart + distanceFromLineStart;
      } else {
        node.mY = lineStart + lineLength - distanceFromLineStart;
      }

      //println("Foliage: initGrill(): ----");
      //println("Foliage: initGrill(): line: " + line);
      //println("Foliage: initGrill(): relativeDistanceFromLineStart: " + relativeDistanceFromLineStart);
      //println("Foliage: initGrill(): distanceFromLineStart: " + distanceFromLineStart);
      //println("Foliage: initGrill(): node.mX: " + node.mX);
      //println("Foliage: initGrill(): node.mY: " + node.mY);

      if (mFirstNode == null) {
        mFirstNode = node;
        lastNode = node;
      } else if (i == NUM_OF_INITIAL_NODES - 1) {  // Last node:
        mPreferredNeighbourDistance = node.distanceToNode(lastNode);
        lastNode.mNext = node;
      } else {
        lastNode.mNext = node;
        lastNode = node;
      }
    }
    return this;
  }

  void setSymmetric(final boolean symmetric) {
    mSymmetric = symmetric;
  }

  void setRectMode(final int paintMode) {
    mPaintMode = paintMode;
  }

  boolean drawIfAlive(final color c) {

    if (++mAge > MAX_AGE) {
      return false;
    }

    mStopped = false;

    Node currentNode = mFirstNode;
    Node nextNode;
    int nodeCounter = 0;

    beginShape();
    if (!mSymmetric) {
      vertex(currentNode.mX, currentNode.mY);
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

      if (mSymmetric) {
        drawSymmetric(currentNode, c);
      } else {
        vertex(nextNode.mX, nextNode.mY);
      }

      currentNode = nextNode;
    } while (!mStopped && currentNode != mFirstNode);

    if (!mSymmetric) {
      endShape(CLOSE);

      //if (!mPaintedInitialFilling) {
      //  final int lastAlpha = paint.getAlpha();
      //  paint.setStyle(Paint.Style.FILL);
      //  paint.setAlpha(INITIAL_FILLING_ALPHA);
      //  canvas.drawPath(path, paint);

      //  paint.setAlpha(lastAlpha);
      //  paint.setStyle(Paint.Style.STROKE);

      //  mPaintedInitialFilling = true;
      //} else {
      //canvas.drawPath(path, paint);
      //}
    }

    return true;
  }

  private void drawImage(final Node node) {
    image(mImage, node.mX, node.mY);
  }

  private void drawSymmetric(final Node node, final color c) {
    stroke(c);
    point((int) node.mX, (int) node.mY);
    //point((int) node.mX, (int) node.mY + 1);
    //point((int) node.mX + 1, (int) node.mY + 1);

    point((int) (mDisplaySize - node.mX), (int) node.mY);
    //point((int) (mCanvasSize - node.mX), (int) node.mY + 1);
    //point((int) (mCanvasSize - node.mX + 1), (int) node.mY + 1);
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