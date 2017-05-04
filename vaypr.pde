
private static final boolean VERBOSE = true;

private static final char TAP_KEY = ' ';

private static final char CLEAR_KEY = 'x';

private static final char CHANGE_MODE_KEY = 'm';

private static final char DECREASE_HEAT_KEY = 's';

private static final char INCREASE_HEAT_KEY = 'w';

private static final char ADD_BACKDROP_BEING_KEY = 'q' ;

private static final int TAP_RESET_INTERVAL_MILLIS = 1500;

private static final int NUM_OF_INITIAL_BACKDROP_BEINGS = 2;

private BeingBuilder mBeingBuilder;

private ArrayList<Being> mBeings = new ArrayList<Being>();

private ArrayList<Being> mBackdropBeings = new ArrayList<Being>();

private boolean mDrawOverlayImage = true;

private PImage mOverlayImage;

private float mOverlayImageSize;

private color mColor = 0xffffffff;

private float mBpm = 130f;

//private int mBeatLengthMillis = (int) (60f * 1000f / mBpm);
private int mBeatLengthMillis = 500;

private int mLastBeatMillis = 0;

private int mCurrentBeat = 0;

private int mBeatMultipleToTrigger = 2;

private int mLastKeyPressMillis = 0;

private ArrayList<Integer> mTaps = new ArrayList<Integer>();

void setup() {
  //fullScreen(2);
  fullScreen();
  //size(800, 600);

  mOverlayImage = loadImage("mnq.png");
  mOverlayImageSize = width / 16f;

  resetBackdropBeings();
  resetScreenWithBackdrop();

  setRandomBeingBuilder();

  final int numberOfInitialBeings = (mBeingBuilder.getRecommendedMaxNumber() / 2);
  for (int i = 0; i < numberOfInitialBeings; i++) {
    addBeing();
  }
}

void draw() {

  for (int f = 0; f < mBeings.size(); f++) {
    final Being being = mBeings.get(f);
    final boolean beingIsAlive = being.drawIfAlive(mColor);
    if (!beingIsAlive) {
      mBeings.remove(f);
      addBeing();
    }
  }

  countBeats();

  if (mDrawOverlayImage) {
    final float imageX = (width / 2f) - (mOverlayImage.width / 2f);
    final float imageY = (height / 2f) - (mOverlayImage.height / 2f);
    image(mOverlayImage, imageX, imageY);
  }
}

void keyPressed() {

  println("main: keyPressed(): key: " + (int) key);

  switch (key) {
  case TAP_KEY:
    resetScreenWithBackdrop();
    handleTap();
    break;
  case CLEAR_KEY:
    resetScreenWithBackdrop();
    break;

  case CHANGE_MODE_KEY:
    setRandomBeingBuilder();
    break;

  case DECREASE_HEAT_KEY:
    decreaseHeat();
    break;

  case INCREASE_HEAT_KEY:
    increaseHeat();
    break;

  case ADD_BACKDROP_BEING_KEY:
    addBackdropBeing();
  }
}

private void resetScreenWithBackdrop() {
  background(0);

  final ArrayList<Being> deadBackdrops = new ArrayList<Being>();
  for (int i = 0; i < mBackdropBeings.size(); i++) {
    if (!mBackdropBeings.get(i).drawIfAlive(0)) {
      deadBackdrops.add(mBackdropBeings.get(i));
    }
  }

  for (final Being deadBeing : deadBackdrops) {
    mBackdropBeings.remove(deadBeing);
  }
}

private void addBackdropBeing() {
  //mBackdropBeings.add(new BackdropTriangle());
  final Being newBackdropBeing = new ImageBeing();
  mBackdropBeings.add(newBackdropBeing);
  newBackdropBeing.drawIfAlive(0);
}

private void resetBackdropBeings() {
  mBackdropBeings = new ArrayList<Being>();
  for (int i = 0; i < NUM_OF_INITIAL_BACKDROP_BEINGS; i++) {
    addBackdropBeing();
  }
}

private void setRandomBeingBuilder() {
  switch((int) random(10)) {
  case 0:
    mBeingBuilder = new RadarCollectionBuilder();
    break;
  case 1:
    mBeingBuilder = new FlowerStickBuilder();
    break;
  case 2:
    mBeingBuilder = new BambooTilesBuilder();
    break;
  case 3:  
    mBeingBuilder = new GrillBuilder();
    break;
  case 4:
    mBeingBuilder = new LineCollectionBuilder();
    break;
  case 5:
    mBeingBuilder = new SnailBuilder();
    break;
  default:
    mBeingBuilder = new FoliageBuilder();
  }

}

private void handleTap() {

  resetBeats();

  final int millisSinceLastTap = millis() - mLastKeyPressMillis;

  if (millisSinceLastTap > TAP_RESET_INTERVAL_MILLIS) {
    mTaps = new ArrayList<Integer>();
    println("main: handleTap(): mBeatLenghtMillis: Resetting.");
  } else if (millisSinceLastTap < 300) {
    return;
  }

  mLastKeyPressMillis = millis();
  mTaps.add(mLastKeyPressMillis);

  final int numberOfTaps = mTaps.size();

  if (numberOfTaps >= 4) {
    int tapMillisSum = 0;
    for (int tapIndex = 1; tapIndex < numberOfTaps; tapIndex++) {
      final int millisBetweenTaps = mTaps.get(tapIndex) - mTaps.get(tapIndex - 1);
      //println("main: handleTap(): millisBetweenTaps: " + tapIndex + " :" + millisBetweenTaps);
      tapMillisSum += millisBetweenTaps;
    }

    mBeatLengthMillis = tapMillisSum / numberOfTaps;
    println("main: handleTap(): mBeatLenghtMillis: " + mBeatLengthMillis);

    if (numberOfTaps >= 16) {
      mTaps = new ArrayList<Integer>();
    }
  }
}

private void decreaseHeat() {
  resetBeats();
  setRandomColor();

  if (mBeatMultipleToTrigger < 16) {
    mBeatMultipleToTrigger *= 2;
    adjustColorForHeat();
  }

  println("main: decreaseHeat(): mBeatMultipleToTrigger: " + mBeatMultipleToTrigger);
}

private void increaseHeat() {
  resetBeats();

  if (mBeatMultipleToTrigger > 1) {
    mBeatMultipleToTrigger /= 2;
    adjustColorForHeat();
  }

  println("main: increaseHeat(): mBeatMultipleToTrigger: " + mBeatMultipleToTrigger);
}

private void adjustColorForHeat() {
  if (mBeatMultipleToTrigger == 1) {
    setRandomColorWithAlpha(mBeingBuilder.getRecommendedAlpha() * 3);
  } else if (mBeatMultipleToTrigger == 2) {
    setRandomColorWithAlpha((int) (mBeingBuilder.getRecommendedAlpha() * 1.5f));
  } else {
    setRandomColor();
  }
}

private void countBeats() {

  if (millis() - mLastBeatMillis > mBeatLengthMillis) {
    mLastBeatMillis = millis();
    ++mCurrentBeat;

    if (VERBOSE) {
      println("main: countBeats(): mCurrentBeat: " + mCurrentBeat);
    }

    if (mCurrentBeat % mBeatMultipleToTrigger == 0) {
      if (VERBOSE) {
        println("main: countBeats(): Beat!");
      }
      resetScreenWithBackdrop();
    }

    if (mCurrentBeat % (mBeatMultipleToTrigger * 2) == 0) {
      addBeing();
    }

    if (mCurrentBeat % 8 == 0) {
      setRandomColor();
      addBackdropBeing();
      switch ((int) random(5)) {
      case 0:
        increaseHeat();
      case 1:
        increaseHeat();
        break;
      case 2:
        decreaseHeat();
      case 3:
        decreaseHeat();
      }
    }

    if (mCurrentBeat % 32 == 0) {
    }

    if (mCurrentBeat % 64 == 0) {
      setRandomBeingBuilder();
    }
  }
}

private void resetBeats() {
  mCurrentBeat = mCurrentBeat + (mCurrentBeat % 4);
  mLastBeatMillis = 0;
}

private void addBeing() {
  if (mBeings.size() >= mBeingBuilder.getRecommendedMaxNumber()) {
    return;
  }

  final float x = random(displayWidth);
  final float y = random(displayHeight);
  mBeings.add(mBeingBuilder.build());
}

private void setDrawOverlayImage() {
  mDrawOverlayImage = (int) random(3) != 1;
}

private void setRandomColor() {
  mColor = getRandomColor();
}

private void setRandomColorWithAlpha(final int alpha) {
  mColor = getRandomColorWithAlpha(alpha);
}

private color getRandomColor() {
  return getRandomColorWithAlpha(mBeingBuilder.getRecommendedAlpha());
}

private color getRandomColorWithAlpha(final int alpha) {
  return color(
    (int) random(100) + 155, 
    (int) random(100) + 155, 
    (int) random(100) + 155, 
    alpha
    );
}