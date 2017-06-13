class Architecture extends Being {

  private static final int MAX_AGE = 640;

  private int mNodesPerColumn = 16 + (int) random(16f);

  private Node[] mFirstNodes;

  Architecture() {

    float x =  0f;
    final float minColumnsDistance = width * 0.1f;
    final float maxColumnsDistance = width * 0.1f;

    final int numberOfRows = 8 + (int) random(8f);
    final float maxRowDistance = (height / numberOfRows) * 3f;
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
      float lastColumnY = random(height);

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
  }

  boolean drawIfAlive(color c) {
    noFill();
    stroke(c);

    for (Node node : mFirstNodes) {
      do {
        for (int i = 0; i < 5; i++) {
          node.draw();
        }
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

    private float mMaxOffset = 100f;//height / 2f;

    private float mMaxOffsetHalf = mMaxOffset / 2f;

    Node(final float x, final float y, final Node nextNode) {
      mX = x;
      mY = y;
      mNextNode = nextNode;
    }

    void draw() {
      //point(mX, mY);
      //line(mX, mY, mNextNode.mX, mNextNode.mY);
      final float distanceFactor = random(1f);
      //point(
      //  mX + ((mNextNode.mX - mX) * distanceFactor), 
      //  mY + ((mNextNode.mY - mY) * distanceFactor)
      //  );

      point(
        random(1f) * width,
        random(1f) * height
        );

      //final float x = random(width);
      //final float top = height / 2f;

      //point(x, top + getProbableOffset());
      //point(x, top);
    } 

    private float getProbableOffset() {
      return mMaxOffsetHalf - (log(random(1f)) * mMaxOffset);
    }
  }
}