interface Drawable {
  boolean drawIfAlive(color c);
}

abstract class Being implements Drawable {

  protected boolean mStopped = false;

  protected int mAge = 0;

  protected float mJitter = width * 0.005f;
  
  protected float mStartX = (width * 0.33f); // + random(width * 0.33f);
  
  protected float mStartY = height / 2f;

  public void stopPerforming() {
    mStopped = true;
  }

  protected float getJitter() {
    return mJitter * 0.5f - random(mJitter);
  }

  protected float angle(
    final float x1, 
    final float y1, 
    final float x2, 
    final float y2
    ) {
    final float calcAngle = atan2(
      -(y1 - y2), 
      x2 - x1
      );

    if (calcAngle < 0) {
      return calcAngle + TWO_PI;
    } else {
      return calcAngle;
    }
  }

  protected float distance(
    final float x1, 
    final float y1, 
    final float x2, 
    final float y2
    ) {
    return sqrt(
      pow((x2 - x1), 2) + pow((y2 - y1), 2)
      );
  }

  protected color colorWithNewAlpha(color c, int newAlpha) {
    return (c & 0xffffff) | (newAlpha << 24);
  }
}