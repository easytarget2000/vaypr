class Holodeck extends Being {

  private static final int MAX_AGE = 512;

  private int mAgePerSection = MAX_AGE / 64;

  private int mNumberOfColumns = 96;//floor(16f + random(24f));

  private int mNumberOfRows = ceil((float) mNumberOfColumns * 0.562f);

  private float mColumnDistance = width / mNumberOfColumns;

  private float mRowDistance = height / mNumberOfRows;

  private int mDirectionAge = 32;

  private float mHorizontalDirection = getRandomDirection();

  private float mVerticalDirection = getRandomDirection();

  Holodeck() {
  }

  boolean drawIfAlive(color c) {
    //clear();
    
    if (++mAge % 2 != 0) {
      return true;
    }

    final float sectionAge = 0; //getSectionAge();

    //println("DEBUG: Holodeck: drawIfAlive(): sectionAge: " + sectionAge);
background(0);

    noFill();
    stroke(
        //colorWithNewAlpha(c, (int) (16f * (1f - sectionAge)))
                colorWithNewAlpha(c, 255)
      );

    for (int column = 0; column < mNumberOfColumns; column++) {

      final float columnX = (float) column * mColumnDistance + ((millis() / 1000f) % mColumnDistance);// + ((sectionAge * mColumnDistance) * mHorizontalDirection);

      line(
        columnX, 
        0f, 
        columnX, 
        height
        );
    }

    for (int row = 0; row < mNumberOfRows; row++) {
      final float rowY = (float) row * mRowDistance;// + (sectionAge * mRowDistance);// * mVerticalDirection;
      line(
        0f, 
        rowY, 
        width, 
        rowY
        );
    }

    if (mAge % mDirectionAge == 0) {
      mHorizontalDirection = getRandomDirection();
      mVerticalDirection = getRandomDirection();
    }

    return mAge < MAX_AGE;
  }


  private float getSectionAge() {
    return (mAge % mAgePerSection) / (float) mAgePerSection;
  }

  private float getRandomDirection() {
    if (random(2f) < 1f) {
      return -1f;
    } else {
      return 1f;
    }
  }
}