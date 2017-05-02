class BambooTile extends Being {

  private static final float NON_LINEAR_JITTER_BREAK = 0.85f;

  private static final int NUM_OF_STROKES = 4;

  private int MAX_AGE = 600;

  private int mGrowthDirection = (int) random(4);

  private boolean mDrawLines = true;

  private int mAge = 0;

  private float mLeftX[] = new float[NUM_OF_STROKES];

  private float mRightX[] = new float[NUM_OF_STROKES];

  private float mTopY[] = new float[NUM_OF_STROKES];

  private float mBottomY[] = new float[NUM_OF_STROKES];

  BambooTile(final float tileSize, final float x, final float y, final boolean drawLines) {
    mJitter = tileSize;
    mDrawLines = drawLines;

    final float column = floor(x / tileSize);
    final float row = floor(y / tileSize);

    final boolean growsHorizontally = mGrowthDirection % 2 == 0;

    float offset = 0;
    for (int i = 0; i < NUM_OF_STROKES; i++) {
      mLeftX[i] = (column * tileSize) + (growsHorizontally ? offset : 0f);
      mRightX[i] = ((column + 1) * tileSize) + (growsHorizontally ? offset : 0f);
      mTopY[i] = (row * tileSize) + (!growsHorizontally ? offset : 0f);
      mBottomY[i] = ((row + 1) * tileSize) + (!growsHorizontally ? offset : 0f);

      offset += (getJitter() * 0.1f);
    }
  }

  boolean drawIfAlive(final color c) {
    for (int i = 0; i < NUM_OF_STROKES; i++) {

      final float startX;
      final float startY;
      final float endX;
      final float endY;

      switch (mGrowthDirection) {
      case 0:
        // Right to left:
        startX = mRightX[i] - (i > 0 ? getJitter() : 0f);
        startY = mTopY[i] + getEvenFloatJitter();
        endX = mRightX[i] - getJitter();
        endY = startY;
        break;

      case 1:
        // Bottom to top:
        startX = mLeftX[i] + getEvenFloatJitter();
        startY = mBottomY[i] - (i > 0 ? getJitter() : 0f);
        endX = startX;
        endY = mBottomY[i] - getJitter();
        break;

      case 2:
        // Left to right:
        startX = mLeftX[i] + (i > 0 ? getJitter() : 0f);
        startY = mTopY[i] + getEvenFloatJitter();
        endX = mLeftX[i] + getJitter();
        endY = startY;
        break;

      default:
        // Top to bottom:
        startX = mLeftX[i] + getEvenFloatJitter();
        startY = mTopY[i] + (i > 0 ? getJitter() : 0f);
        endX = startX;
        endY = mTopY[i] + getJitter();
      }

      if (i % 2 == 1) {
        stroke(0);
        line(startX, startY, endX, endY);
        stroke(c);
      } else {
        line(startX, startY, endX, endY);
      }
    }

    return mAge++ < MAX_AGE;
  }

  protected float getJitter() {
    return random(mJitter);
  }

  private float getEvenFloatJitter() {
    return (int) (random(mJitter) / 2f) * 2f;
  }

  private float getNonLinearJitter() {
    if ((int) random(2) % 2 == 0) {
      return getJitter();
    } else {
      return getJitter() * NON_LINEAR_JITTER_BREAK;
    }
  }
}