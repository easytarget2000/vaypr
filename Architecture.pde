class Architecture extends Being {

  private static final int MAX_AGE = 640;

  private int mNodesPerColumn = 2 + (int) random(6f);

  private Node[] mFirstNodes;

  Architecture() {

    float x =  0f;
    final float minColumnsDistance = width * 0.1f;
    final float maxColumnsDistance = width * 0.1f;

    final int numberOfRows = 4 + (int) random(7f);
    final float maxRowDistance = (height / numberOfRows) * 2f;
    final float maxRowDistanceHalf = maxRowDistance / 2f;

    mFirstNodes = new Node[numberOfRows];

    final ArrayList<Float> columnXList = new ArrayList<Float>(); 
    do {
      columnXList.add(x);
      x += minColumnsDistance + random(maxColumnsDistance);
    } while (x < width * 0.9f);

    columnXList.add((float) width);

    for (int row = 0; row < numberOfRows; row++) {
      Node node = null;
      float lastColumnY = random(height * ((row + 1f) / (float) numberOfRows));

      for (int column = 0; column < columnXList.size(); column++) {
        final Node lastNode = node;

        node = new Node(
          columnXList.get(column), 
          lastColumnY += maxRowDistanceHalf - random(maxRowDistance), 
          null
          );

        if (mFirstNodes[row] == null) {
          mFirstNodes[row] = node;
        } else {
          lastNode.mNextNode = node;
        }
      }
    }

    //final float nextColumnX = x + random(linesHorizontalMaxDistance);

    //for (int column = 0; column < mNodesPerColumn; column++) {
    //  final Node lastNode = node;
    //  node = new Node(x, random(height), null);

    //  if (mFirstNode == null) {
    //    mFirstNode = node;
    //  } else {
    //    lastNode.mNextNode = node;
    //  }
    //}

    //x = nextColumnX;
  }

  boolean drawIfAlive(color c) {
    noFill();
    stroke(c);

    for (Node node : mFirstNodes) {
      do {
        node.draw();
        node = node.mNextNode;
      } while (node.mNextNode != null);
    }

    return mAge++ < MAX_AGE;
  }

  /**
   * Architecture.Node
   */

  private class Node {

    private float mX;

    private float mY;

    private Node mNextNode;
    
    private float mMaxOffset = width / 16f;

    Node(final float x, final float y, final Node nextNode) {
      mX = x;
      mY = y;
      mNextNode = nextNode;
    }

    void draw() {
      //point(mX, mY);
      //line(mX, mY, mNextNode.mX, mNextNode.mY);
      final float distanceFactor = random(1f);
      point(
        mX + ((mNextNode.mX - mX) * distanceFactor), 
        mY + ((mNextNode.mY - mY) * distanceFactor) + getProbableOffset()
        );
    }

    private float getProbableOffset() {
      return sqrt(random(1f)) * mMaxOffset;
    }
  }
}