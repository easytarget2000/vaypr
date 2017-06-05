class Architecture extends Being {
  
  private static final int MAX_AGE = 640;
  
  Architecture() {
    
  }
  
  boolean drawIfAlive(color c) {
    return mAge++ < MAX_AGE;
  }
  
}