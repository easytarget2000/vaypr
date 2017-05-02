interface BeingBuilder {

  Being build(final float x, final float y);

  int getRecommendedAlpha();

  int getRecommendedMaxNumber();
}

/**
 *
 */

class FoliageBuilder implements BeingBuilder {

  private boolean mSymmetric;

  private int mPaintMode;

  FoliageBuilder() {
    mSymmetric = (int) random(3) % 2 == 0;

    if ((int) random(2) % 2 == 0) {
      mPaintMode = Foliage.LINE_MODE;
    } else {
      mPaintMode = (int) random(4);
    }
  }

  Being build(final float x, final float y) {

    final Foliage foliage = new Foliage();
    foliage.setSymmetric(mSymmetric);
    foliage.setRectMode(mPaintMode);
    switch ((int) random(5)) {
    //case 0:
      //foliage.initGrill();
    default:
      foliage.initCircle();
    }

    foliage.setImage(loadImage("q02.png"));
    return foliage;
  }

  int getRecommendedAlpha() {
    return mSymmetric ? 100 : 16;
  }

  int getRecommendedMaxNumber() {
    return 1; // /DEBUG;
  }
}

/**
 *
 */

class FlowerStickBuilder implements BeingBuilder {

  Being build(final float x, final float y) {
    return new FlowerStick();
  }

  int getRecommendedAlpha() {
    return 64;
  }

  int getRecommendedMaxNumber() {
    return 64;
  }
}

/**
 *
 */

class RadarCollectionBuilder implements BeingBuilder {

  Being build(final float x, final float y) {
    final int displaySize = max(displayWidth, displayHeight);
    return new RadarCollection();
  }

  int getRecommendedAlpha() {
    return 32;
  }

  int getRecommendedMaxNumber() {
    return 32;
  }
}

/**
 *
 */

class BambooTilesBuilder implements BeingBuilder {

  private float mTileSize;

  BambooTilesBuilder() {
    final float displaySize = max(displayWidth, displayHeight);
    mTileSize = displaySize / (10f + (float) floor(random(10)));
  }

  public Being build(float x, float y) {
    return new BambooTile(mTileSize, true);
  }

  public int getRecommendedAlpha() {
    return 16;
  }

  public int getRecommendedMaxNumber() {
    return 64;
  }
}