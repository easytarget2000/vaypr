class BackdropTriangle extends Being {

  private static final int MAX_AGE = 1024;

  private static final int MAX_BRIGHTNESS = 64;

  private static final int sNumberOfColumns = 24;

  private static final int sNumberOfRows = 16;

  private static final boolean FILLED = true;
  
  private color mColor = color((int) random(128));

  private float mWidth;

  private float mWidthHalf;

  private float mHeight;

  private int mRow = (int) random(sNumberOfRows);

  private int mColumn = (int) random(sNumberOfColumns);

  private boolean mPointUp = ((int) random(2) % 2) == 0;

  public BackdropTriangle() {
    //sNumberOfColumns = 10 + (int) random(16);
    //sNumberOfRows = (int) (sNumberOfColumns * 0.9);
    
    println("BackdropTriangle: (): " + mColumn + ", " + mRow);
    
    mWidth = width / (float) sNumberOfColumns;
    mWidthHalf = mWidth / 2f;
    mHeight = height / (float) sNumberOfRows;
  }

  boolean drawIfAlive(color c) {
    final float rowTop = (float) mRow * mHeight;
    final float rowBottom = rowTop + mHeight;

    final float columnLeft = mColumn * mWidth;

    //if (FILLED) {
    //  noStroke();
    //  fill(mColor);
    //} else {
    //  noFill();
    //  stroke(mColor);
    //}

    if (mRow % 2 == 0) {
      if (mPointUp) {
        beginShape();
        vertex(columnLeft, rowTop);
        vertex(columnLeft + (mWidthHalf), rowBottom);
        vertex(columnLeft - (mWidthHalf), rowBottom);
        endShape(CLOSE);
      } else {
        beginShape();
        vertex(columnLeft, rowTop);
        vertex(columnLeft + (mWidthHalf), rowBottom);
        vertex(columnLeft + (mWidth), rowTop);
        endShape(CLOSE);
      }
    } else {
      if (mPointUp) {
        beginShape();
        vertex(-mWidthHalf + columnLeft, rowTop);
        vertex(-mWidthHalf + columnLeft + mWidth, rowTop);
        vertex(0f + columnLeft, rowBottom);
        endShape(CLOSE);
      } else {
        beginShape();
        vertex(0f + columnLeft, rowBottom);
        vertex(-mWidthHalf + columnLeft + mWidth, rowTop);
        vertex(mWidth + columnLeft, rowBottom);
        endShape(CLOSE);
      }
    }

    return mAge++ < MAX_AGE;
  }

}