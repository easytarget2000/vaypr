interface BeingBuilder {

  Being build();

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
    //mSymmetric = (int) random(3) % 2 == 0;
    mSymmetric = true;

    if ((int) random(2) % 2 == 0) {
      mPaintMode = Foliage.LINE_MODE;
    } else {
      mPaintMode = (int) random(4);
    }
  }

  Being build() {

    final Foliage foliage = new Foliage();

    switch ((int) random(4)) {
    case 0:
      foliage.initLine();
      break;
    default:
      foliage.initCircle();
    }

    return foliage;
  }

  int getRecommendedAlpha() {
    return 24;
  }

  int getRecommendedMaxNumber() {
    return 3;
  }
}

/**
 *
 */

class FlowerStickBuilder implements BeingBuilder {

  Being build() {
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

  Being build() {
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

  public Being build() {
    return new BambooTile(mTileSize, true);
  }

  public int getRecommendedAlpha() {
    return 16;
  }

  public int getRecommendedMaxNumber() {
    return 64;
  }
}

/**
 *
 */

class LineCollectionBuilder implements BeingBuilder {

  //private LineCollectionMode mMode = LineCollectionMode.values()[(int)random(LineCollectionMode.values().length)];
  private LineCollectionMode mMode = LineCollectionMode.BALL_O_WOOL;

  public Being build() {
    return new LineCollection(mMode);
  }

  public int getRecommendedAlpha() {
    return 32;
  }

  public int getRecommendedMaxNumber() {
    return mMode == LineCollectionMode.BALL_O_WOOL ? 8 : 3;
  }
}

/**
 *
 */

class GrillBuilder implements BeingBuilder {

  private boolean mDrawCircles = (int) random(2) % 2 == 0;

  public Being build() {
    return new Grill(mDrawCircles);
  }

  public int getRecommendedAlpha() {
    return 64;
  }

  public int getRecommendedMaxNumber() {
    return 12;
  }
}

/**
 *
 */

class SnailBuilder implements BeingBuilder {

  private float mCircleRadius = (width * 0.05f) + random(width * 0.05f);

  public Being build() {
    return new Snail(mCircleRadius);
  }

  public int getRecommendedAlpha() {
    return 32;
  }

  public int getRecommendedMaxNumber() {
    return 8;
  }
}