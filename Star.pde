class Star extends Being {
  
  /**
  * 
  */
  
  private static final float SIZE_FACTOR = 0.01f;
  
  private float mx;
  
  private float y;
  
  private float size = 128f; //width * SIZE_FACTOR * 0.5f + random(width * SIZE_FACTOR * 0.9f);
  
  private float xVelocity = 1f;
  
  private float yVelocity = 1f;
  
  /**
  * 
  */
  
  Star() {
    mx = random(width);
    y = random(height);
  }
  
  boolean drawIfAlive(color c) {
    background(0);
    update();
    configureAndDraw(c);
    return true;
    //return x > 0 && x < width && y > 0 && y < height;
  }
  
  private void update() {
    mx += xVelocity;
    y += yVelocity;
  }
  
  private void configureAndDraw(color c) {
    fill(c);
    noStroke();
    
    ellipse(mx, y, size, size);
  }
}