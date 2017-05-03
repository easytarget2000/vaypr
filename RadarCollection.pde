

/**
 * Created by michelsievers on 20/03/2017.
 */

public class RadarCollection extends Being {

  private static final int MAX_AGE = 16;

  private int mAge = 0;

  private Radar[] mRadars;

  public RadarCollection() {
    final float screenSize = max(width, height);
    mRadars = new Radar[1 + (int) random(10)];

    for (int i = 0; i < mRadars.length; i++) {
      mRadars[i] = new Radar(mStartX, mStartY, random(screenSize * 0.4f) + 64, random(TWO_PI));
    }
    mJitter = screenSize * 0.01f;
  }

  boolean drawIfAlive(final color c) {
    noFill();
    stroke(c);

    boolean updatedOne = false;
    for (final Radar radar : mRadars) {
      updatedOne |= radar.update();

      line(
        radar.getStartX(), 
        radar.getStartY(), 
        radar.getEndX(), 
        radar.getEndY()
        );
    }
    return updatedOne;
  }

  private class Radar {

    private float mCenterX;

    private float mCenterY;

    private float mRadius;

    private float mInitialLength;

    private float mCurrentLength;

    private float mInitialAngle;

    private float mCurrentAngle;

    private float mAngleStep;

    private float mTargetX;

    private float mTargetY;

    private float mInertiaX;

    private float mInertiaY;

    private int mAge;

    private int mMaxAge;

    private Radar(final float x, final float y, final float radius, final float angle) {

      mCenterX = x;
      mCenterY = y;

      mRadius = radius;
      mInitialLength = radius * 0.33;
      mCurrentLength = mInitialLength;

      mMaxAge = (int) random(2048) + 256;

      mInitialAngle = angle;
      mAngleStep = TWO_PI / (float) mMaxAge;

      //Log.d(TAG, "Initializing " + toString());
    }

    public String toString() {
      return "[RadarCollection.Radar around " + mCenterX + ", " + mCenterY
        + ", radius " + mRadius + "]";
    }

    private void setTarget(final float x, final float y) {
      mTargetX = x;
      mTargetY = y;
    }

    private float getStartX() {
      return mCenterX + (cos(mCurrentAngle) * mRadius);
    }

    private float getStartY() {
      return mCenterY + (sin(mCurrentAngle) * mRadius);
    }

    private float getEndX() {
      return mCenterX + (cos(mCurrentAngle) * (mRadius - mCurrentLength));
    }

    private float getEndY() {
      return mCenterY + (sin(mCurrentAngle) * (mRadius - mCurrentLength));
    }

    private boolean update() {

      if (mAge > mMaxAge * 0.9) {
        mCurrentLength = mInitialLength + ((mInitialLength - mCurrentLength) / 10);
      }

      mCurrentLength += getJitter();
      if (mCurrentLength < 0) {
        mCurrentLength = 4;
      } else if (mCurrentLength > mRadius) {
        mCurrentLength = mRadius;
      }

      mCurrentAngle = mInitialAngle + (mAge++ * mAngleStep);

      return mAge <= mMaxAge;
    }
  }
}