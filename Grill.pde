class Grill extends Being { //<>// //<>// //<>//

  private static final int MAX_AGE = 128;

  private int mRounds = 2 + (int) random(6);

  private int mNumberOfLines = 16 + (int) random(24);

  private int mAgePerLine = (int) ceil((float) (MAX_AGE - 2) / (float) mNumberOfLines);

  private float mInset = width * 0.1f;

  private float mLineLength = height - (2f * mInset);

  private float mLastX = -mInset + getJitter();

  private float mLastY = mInset;

  private float mXStepSize = width * 1.25f / mNumberOfLines; 

  private float mYStepSize = mLineLength / (float) mAgePerLine;

  Grill() {
    //println("Grill: (): mNumberOfLines: " + mNumberOfLines);
    //println("Grill: (): mAgePerLine: " + mAgePerLine);
    //println("Grill: (): mYStepSize: " + mYStepSize);
  }

  boolean drawIfAlive(color c) {
    noFill();
    stroke(c);

    //println("Grill: drawIfAlive(): New Line. mAge: " + mAge);
    //println("Grill: drawIfAlive(): New Line. mAgePerLine: " + mAgePerLine);
    //println("Grill: drawIfAlive(): New Line. mRounds: " + mRounds);

    for (int round = 0; round < mRounds; round++) {
      if (++mAge % mAgePerLine == 0) { // Start a new line.
        mLastX += mXStepSize;
        mLastY = mInset;
      }

      line(mLastX, mLastY + 1, mLastX += getJitter(), mLastY += mYStepSize);
    }

    return mAge <= MAX_AGE;
  }
}