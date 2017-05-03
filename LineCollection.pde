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