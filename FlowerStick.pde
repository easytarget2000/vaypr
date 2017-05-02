
class FlowerStick extends Being {

  private static final int NUM_OF_INITIAL_NODES = 48;

  private float mBlossomX;

  private float mBlossomY;

  private float mDisplayHeight;

  private boolean mGrowing = true;

  private Branch[] mBranches;

  private int mInsertionIndex = NUM_OF_INITIAL_NODES / 2;

  private float mLastLineX;

  private float mLastLineY;

  FlowerStick(final float displayHeight, final float x, final float y) {
    mDisplayHeight = displayHeight;
    mJitter = mDisplayHeight * 0.001f;
    mBlossomX = x;
    mBlossomY = y;
    mLastLineX = (float) mBlossomX;
    mLastLineY = (float) mDisplayHeight;
  }

  boolean drawIfAlive(final color c) {
    final float currentY = (float) mDisplayHeight - mAge;

    if (currentY < mBlossomY) {

      if (mBranches == null) {
        final int numberOfBranches = 8 + (int) random(64);
        mBranches = new Branch[numberOfBranches];

        final int numberOfPods = (int) random(64 - 16) + 16;

        final float sharedLength = random(
          mDisplayHeight / 3f * (numberOfPods / 64f)
        );

        for (int i = 0; i < numberOfBranches; i++) {
          final float angle;
          angle = (TWO_PI * ((i + 1.0) / numberOfBranches)) + random(TWO_PI / 90);
          final float length = sharedLength + random(mDisplayHeight / 100.0);

          mBranches[i] = new Branch(angle, length);
        }
      }

      boolean somethingGrew = false;
      for (final Branch branch : mBranches) {
        if (!branch.drawAndUpdate(c)) {
          mGrowing = false;
        }
      }

      if (!somethingGrew) {
        
      }
     
    } else {
      final float newLineX = (float) (mBlossomX + getJitter());
      line(
        mLastLineX, 
        mLastLineY, 
        newLineX, 
        currentY
      );
      mLastLineX = newLineX;
      mLastLineY = currentY;
    }

    mAge += (int) random(mDisplayHeight / 32f);

    return mGrowing;
  }

  private class Branch {

    private float mCurrentLength = 0f;

    private float mFinalLength;

    private float mSpeed;

    private float mAngle;

    private float mMaxPodRadius;

    private int mNumberOfPodsLeft;

    private Branch(final float angle, final float length) {
      mFinalLength = length;
      mSpeed = random(mDisplayHeight * 0.01f);
      mAngle = angle;
      mMaxPodRadius = random(mDisplayHeight * 0.01f);
      mNumberOfPodsLeft = (int) random(9);
    }

    private boolean drawAndUpdate(final color c) {

      final float x = mBlossomX + (cos(mAngle) * mCurrentLength);
      final float y = mBlossomY + (sin(mAngle) * mCurrentLength);

      if (mCurrentLength > mFinalLength) {
        if (mNumberOfPodsLeft > 0) {
          stroke(colorWithNewAlpha(c, (int) random(255)));
          final float podRadius = random(mMaxPodRadius);
          ellipse(x, y, podRadius, podRadius);
          --mNumberOfPodsLeft;
          return true;
        } else {
          return false;
        }
      }

      mCurrentLength += mSpeed;

      final float newX = mBlossomX + (cos(mAngle) * mCurrentLength);
      final float newY = mBlossomY + (sin(mAngle) * mCurrentLength);

      stroke(colorWithNewAlpha(c, 64));
      line(x, y, newX, newY);

      return true;
    }
  }
}