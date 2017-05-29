class Holodeck extends Being {

  private static final int MAX_AGE = 512;

  private int mAgePerSection = MAX_AGE / 64;

  private float mNumberOfColumns = floor(4 + random(8));

  private float mNumberOfRows = floor(4 + random(8));

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

    final float sectionAge = getSectionAge();

    //println("DEBUG: Holodeck: drawIfAlive(): sectionAge: " + sectionAge);

    noFill();
    stroke(
        colorWithNewAlpha(c, (int) (16f * (1f - sectionAge)))
      );

    for (float column = 0f; column < mNumberOfColumns; column += 1f) {

      final float columnX = column * mColumnDistance + ((sectionAge * mColumnDistance) * mHorizontalDirection);

      line(
        columnX, 
        0f, 
        columnX, 
        height
        );
    }

    for (float row = 0f; row < mNumberOfRows; row += 1f) {
      final float rowY = row * mRowDistance + (sectionAge * mRowDistance) * mVerticalDirection;
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