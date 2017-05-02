

/**
 * Created by michelsievers on 20/03/2017.
 */

public class RadarCollection extends Being {

  private static final int MAX_AGE = 5;

  private int mAge = 0;

  private Radar[] mRadars;

  public RadarCollection(final float x, final float y, final float screenSize) {
    mRadars = new Radar[1 + (int) random(10)];

    for (int i = 0; i < mRadars.length; i++) {
      mRadars[i] = new Radar(x, y, random(screenSize * 0.4f) + 64, random(TWO_PI));
    }
    mJitter = screenSize * 0.01f;
  }

  boolean drawIfAlive(final color c) {
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

      mMaxAge = (int) random(1000) + 100;

      mInitialAngle = angle;
      mAngleStep = TWO_PI / (float) mMaxAge;
      //            final float maxInertia = length / 3.0;
      //            final float minInertia = -maxInertia;
      //            mInertiaX = minInertia + random(maxInertia * 2);
      //            mInertiaY = minInertia + random(maxInertia * 2);

      //Log.d(TAG, "Initializing " + toString());
    }

    @Override
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
      //
      //            for (final Radar otherLine : mRadars) {
      //                if (otherLine == this) {
      //                    continue;
      //                }
      //
      //                final float distance = distance(mCenterX, mCenterY, otherLine.mCenterX, otherLine.mCenterY);
      //                if (distance < 16) {
      //                    mCurrentAngle = angle(mCenterX, mCenterY, otherLine.mCenterX, otherLine.mCenterY);
      //                }
      //            }

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
      //            mCurrentAngle += ((double) mMaxAge / ++mAge) / 10.0;

      //            mCenterX += getDoubleJitter();
      //            mCenterY += getDoubleJitter();

      return mAge <= mMaxAge;
    }
  }
}