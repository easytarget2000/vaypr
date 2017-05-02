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