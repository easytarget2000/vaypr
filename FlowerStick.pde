
class FlowerStick extends Being {

  private static final int NUM_OF_INITIAL_NODES = 48;

  private boolean mGrowing = true;

  private Branch[] mBranches;

  private int mInsertionIndex = NUM_OF_INITIAL_NODES / 2;

  private float mLastLineX;

  private float mLastLineY;

  FlowerStick() {
    mJitter = height * 0.001f;
    mLastLineX = (float) mStartX;
    mLastLineY = height;
  }

  boolean drawIfAlive(final color c) {
    final float currentY = (float) height - mAge;

    if (currentY < mStartY) {

      if (mBranches == null) {
        final int numberOfBranches = 8 + (int) random(64);
        mBranches = new Branch[numberOfBranches];

        final int numberOfPods = (int) random(64 - 16) + 16;

        final float sharedLength = random(
          height / 3f * (numberOfPods / 64f)
          );

        for (int i = 0; i < numberOfBranches; i++) {
          final float angle;
          angle = (TWO_PI * ((i + 1f) / numberOfBranches)) + random(TWO_PI / 90f);
          final float length = sharedLength + random(height / 100f);

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
      final float newLineX = (float) (mStartX + getJitter());
      line(
        mLastLineX, 
        mLastLineY, 
        newLineX, 
        currentY
        );
      mLastLineX = newLineX;
      mLastLineY = currentY;
    }

    mAge += (int) random(height / 32f);

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
      mSpeed = random(height * 0.01f);
      mAngle = angle;
      mMaxPodRadius = random(height * 0.01f);
      mNumberOfPodsLeft = (int) random(9);
    }

    private boolean drawAndUpdate(final color c) {
      noFill();
      final float x = mStartX + (cos(mAngle) * mCurrentLength);
      final float y = mStartY + (sin(mAngle) * mCurrentLength);

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

      final float newX = mStartX + (cos(mAngle) * mCurrentLength);
      final float newY = mStartY + (sin(mAngle) * mCurrentLength);

      stroke(colorWithNewAlpha(c, 64));
      line(x, y, newX, newY);

      return true;
    }
  }
}