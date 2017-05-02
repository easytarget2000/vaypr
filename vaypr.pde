
private static final boolean VERBOSE = true;

private static final char TAP_KEY = ' ';

private static final char CHANGE_MODE_KEY = 'q';

private static final char DECREASE_HEAT_KEY = 'w';

private static final char INCREASE_HEAT_KEY = 's';

private static final char ADD_TRIANGLE_KEY = 't' ;

private static final int TAP_RESET_INTERVAL_MILLIS = 1500;

private static final boolean SOLID_BACKDROP = true;

private BeingBuilder mBeingBuilder;

private ArrayList<Being> mBeings = new ArrayList<Being>();

private ArrayList<Being> mBackdropBeings = new ArrayList<Being>();

private color mColor = 0xffffffff;

private float mBpm = 130f;

//private int mBeatLengthMillis = (int) (60f * 1000f / mBpm);
private int mBeatLengthMillis = 500;

private int mLastBeatMillis = 0;

private int mCurrentBeat = 0;

private int mBeatMultipleToTrigger = 2;

private int mLastKeyPressMillis = 0;


void setup() {
  //fullScreen(2);
  size(800, 600);
  resetScreen();
  noFill();

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
}

void keyPressed() {

  println("main: keyPressed(): key: " + (int) key);

  switch (key) {
  case TAP_KEY:
    resetScreen();
    handleTap();
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
  
  case ADD_TRIANGLE_KEY:
    addBackdropBeing();
  }
}

private void resetScreen() {
  background(0);
  
  final ArrayList<Integer> deadBackdropIndices = new ArrayList<Integer>();
  for (int i = 0; i < mBackdropBeings.size(); i++) {
    if (!mBackdropBeings.get(i).drawIfAlive(0)) {
      deadBackdropIndices.add(i);
    }
  }
  
  for (final Integer deadBeingIndex : deadBackdropIndices) {
    mBackdropBeings.remove(deadBeingIndex);
  }
}

private void addBackdropBeing() {
  println("main: addBackdropBeing()");
  mBackdropBeings.add(new BackdropTriangle());
}

private void resetBackdropTriangles() {
  mBackdropBeings = new ArrayList<Being>();
}

private void setRandomBeingBuilder() {
  switch((int) random(5)) {
  case 0:
    mBeingBuilder = new RadarCollectionBuilder();
    break;
  case 1:
    mBeingBuilder = new FlowerStickBuilder();
    break;
  case 2:
    mBeingBuilder = new BambooTilesBuilder();
    break;
  default:
    mBeingBuilder = new FoliageBuilder();
  }


  // DEBUG!
  mBeingBuilder = new FoliageBuilder();

  setRandomColor();
}

private ArrayList<Integer> mTaps = new ArrayList<Integer>();

private void handleTap() {

  resetBeats();

  if (millis() - mLastKeyPressMillis > TAP_RESET_INTERVAL_MILLIS) {
    mTaps = new ArrayList<Integer>();
    println("main: handleTap(): mBeatLenghtMillis: Resetting.");
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

  if (mBeatMultipleToTrigger >= 16) {
    mBeatMultipleToTrigger = 1;
  } else {
    mBeatMultipleToTrigger *= 2;
  }

  println("main: decreaseHeat(): mBeatMultipleToTrigger: " + mBeatMultipleToTrigger);
}

private void increaseHeat() {
  resetBeats();

  if (mBeatMultipleToTrigger == 1) {
    mBeatMultipleToTrigger = 16;
  } else {
    mBeatMultipleToTrigger /= 2;
    if (mBeatMultipleToTrigger == 1) {
      setRandomColorWithAlpha(mBeingBuilder.getRecommendedAlpha() * 4);
    } else if (mBeatMultipleToTrigger == 2) {
      setRandomColorWithAlpha(mBeingBuilder.getRecommendedAlpha() * 2);
    }
  }

  println("main: increaseHeat(): mBeatMultipleToTrigger: " + mBeatMultipleToTrigger);
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
      //clearScreen(); /// DEBUG
    }

    if (mCurrentBeat % (mBeatMultipleToTrigger * 2) == 0) {
      addBeing();
    }

    if (mCurrentBeat % 8 == 0) {
      setRandomColor();
    }

    if (mCurrentBeat % 32 == 0) {
      setRandomBeingBuilder();
    }
  }
}

private void resetBeats() {
  mCurrentBeat = 0;
  mLastBeatMillis = 0;
}

private void addBeing() {
  if (mBeings.size() >= mBeingBuilder.getRecommendedMaxNumber()) {
    return;
  }

  final float x = random(displayWidth);
  final float y = random(displayHeight);
  mBeings.add(mBeingBuilder.build(x, y));
}

private void setRandomColorWithAlpha(final int alpha) {
  stroke(getRandomColorWithAlpha(alpha));
}

private void setRandomColor() {
  stroke(getRandomColor());
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