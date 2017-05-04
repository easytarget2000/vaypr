class Snail extends Being {

  private static final int MAX_AGE = 1024;

  private float mMaxLapRadius = random(width * 0.25f);
  
  private float mMinLapRadius = mMaxLapRadius * 0.5f;
  
  private float mLapRadiusFactor = 1f + random(8f);

  private float mCircleRadius;
  
  private boolean mDrawLine;

  Snail(final float circleRadius) {
    mCircleRadius = circleRadius;
  }

  boolean drawIfAlive(color c) {
    noFill();
    stroke(c);

    final float angle = (mAge * 16f) / (float) MAX_AGE * TWO_PI;
    final float lapRadius = mMinLapRadius + (mAge / (float) MAX_AGE * mMaxLapRadius * mLapRadiusFactor);

    ellipse(
      mStartX + (cos(angle) * lapRadius), 
      mStartY + (sin(angle) * lapRadius), 
      mCircleRadius, 
      mCircleRadius
      );
      
    return mAge++ < MAX_AGE;
  }
}