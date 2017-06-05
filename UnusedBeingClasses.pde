/**
* BambooTile
*/

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

  BambooTile(final float tileSize, final boolean drawLines) {
    mJitter = tileSize;
    mDrawLines = drawLines;

    final float column = floor(mStartX / tileSize);
    final float row = floor(mStartY / tileSize);

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
    noFill();
    stroke(c);

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

/**
* FlowerStick
*/

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

class ImageBeing extends Being {
  
  private static final int MAX_AGE = 16;
  
  private final PImage mImage = loadImage("q02.png");
  
  private float mX = random(width);
  
  private float mY = random(height);
  
  boolean drawIfAlive(color c) {
    image(mImage, mX, mY);
    return mAge++ < MAX_AGE;
  }
  
}

/**
*
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

/**
* Snail
*/

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

/**
*
*/

enum LineCollectionMode {
  BULLSHIT, EXPLOSIVE, BALL_O_WOOL
}

class LineCollection extends Being {

  private static final int MAX_AGE = 1024;

  private LineCollectionMode mMode = LineCollectionMode.BULLSHIT;

  private int mRoundsPerDrawCall = (int) random(4);

  private float mLineLength;

  LineCollection(final LineCollectionMode mode) {
    mMode = mode;
    if (mMode == LineCollectionMode.BALL_O_WOOL) {
      mLineLength = (height / 10f) + random(height / 3f);
    } else {
      mLineLength = max(width, height);
    }
  }

  boolean drawIfAlive(color c) {
    noFill();
    stroke(c);

    float angle = random(TWO_PI);

    for (int round = 0; round < mRoundsPerDrawCall; round++) {
      switch (mMode) {
      case BULLSHIT:
        drawBullshitLine();
        break;
      case EXPLOSIVE:
        drawExplosiveLine();
        break;
      case BALL_O_WOOL:
        drawBallOfWoolLine();
        break;
      }

      angle *= 1.01f;
    }

    return mAge++ < MAX_AGE;
  }

  private void drawBullshitLine() {
    line(
      random(-width), 
      random(-height), 
      random(width * 2f), 
      random(height * 2f)
      );
  }

  private void drawExplosiveLine() {
    final float angle = random(TWO_PI);

    final float relativeStart = random(mLineLength * 0.5f);

    line(
      mStartX + (cos(angle) * relativeStart), 
      mStartY + (sin(angle) * relativeStart), 
      mStartX + (cos(angle) * mLineLength), 
      mStartY + (sin(angle) * mLineLength)
      );
  }

  private void drawBallOfWoolLine() {
    final float angle1 = random(TWO_PI);
    final float angle2 ;
    if ((int) random(2) % 2 == 0) {
      angle2 = random(TWO_PI);
    } else {
      angle2 = angle1 * 1.1f;
    }

    line(
      mStartX + (cos(angle1) * mLineLength), 
      mStartY + (sin(angle1) * mLineLength), 
      mStartX + (cos(angle2) * mLineLength), 
      mStartY + (sin(angle2) * mLineLength)
      );
  }
}

/**
*
*/

class Grill extends Being { //<>// //<>// //<>// //<>//

  private static final int MAX_AGE = 128;

  private int mRounds = 2 + (int) random(6);

  private int mNumberOfLines = 16 + (int) random(24);

  private int mAgePerLine = (int) ceil((float) (MAX_AGE - 2) / (float) mNumberOfLines);

  private boolean mDrawCircles;

  private float mInset = width * 0.1f;

  private float mLineLength = height - (2f * mInset);

  private float mLastX = -mInset + getJitter();

  private float mLastY = mInset;

  private float mXStepSize = width * 1.25f / mNumberOfLines; 

  private float mYStepSize = mLineLength / (float) mAgePerLine;
  
  private float mCircleSize = random(width * 0.05f);

  Grill(final boolean drawCircles) {
    mDrawCircles = drawCircles;
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

      if (mDrawCircles) {
        ellipse(mLastX += getJitter(), mLastY += mYStepSize, mCircleSize, mCircleSize);
      } else {
        line(mLastX, mLastY + 1, mLastX += getJitter(), mLastY += mYStepSize);
      }
    }

    return mAge <= MAX_AGE;
  }
}