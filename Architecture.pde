class Architecture extends Being {

  private static final int MAX_AGE = 640;
  
  private int mNodesPerColumn = 2 + (int) random(6f);

  private Node mFirstNode;

  Architecture() {

    float x = width * 0.05f;
    final float linesHorizontalMaxDistance = width * 0.3f;

    Node node = null;

    while (x < (width * 0.95f)) {
      
      final float nextColumnX = x + random(linesHorizontalMaxDistance);
      
      for (int i = 0; i < mNodesPerColumn; i++) {
        final Node lastNode = node;
        node = new Node(x, 10, null);
        
      if (mFirstNode == null) {
        mFirstNode = node;
      } else {
        lastNode.mNextNode = node;
      }
      }
      
      
      x = nextColumnX;
    }

  }

  boolean drawIfAlive(color c) {
    noFill();
    stroke(c);

    final Node node = mFirstNode;
    
    do {
      node.draw();
      node = node.mNextNode;
    } while (node != null);

    return mAge++ < MAX_AGE;
  }
  
  /**
  * Architecture.Node
  */

  private class Node {
    
    private float mX;
    
    private float mY;
    
    private Node mNextNode;
    
    Node(final float x, final float y, final Node nextNode) {
      mX = x;
      mY = y;
      mNextNode = nextNode;
    }
    
    void draw() {
      point(mX, mY);
    }
    
  }
}