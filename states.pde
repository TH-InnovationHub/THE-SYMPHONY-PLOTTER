// State.pde
public class State {
  public boolean showImage = true;
  public boolean closeLine = false;
  public boolean colorLines = false;
  public boolean showAllSections = true;
  public boolean debugUIVisible = true;

  public int currentImageIndex = 0;
  public int lineMode = 0;
  public int connectionMode = 0;
  
  public int pointSerchRange = 4;
  public int pointSerchRangeMin = 1;
  public int pointSubtract = 10;
  
  public float harmonicFactor = 1.1;

  public int particleNum = 9090;
  public int speed = 10000;
  public float lineAlpha = 255;
  public float lineWeight = 2;
  public float mapMin = 95;
  public float mapMax = 0;
  
  public int brightnessThreshhold = 30;
  
  public boolean isClosestPointConnection = true;
  
  public float volumeShiftValueX  = 0;
  public float volumeShiftValueY  = 0;


  public boolean applyEdgeDetection = false;
  public int gaussianBlurRadius = 0;

  public boolean AudioVisualMode = false; // 追加
  public boolean audioReactiveMode = false;
  public boolean videoExporting = false;


  public ArrayList<PVector> pc;
  public ArrayList<PVector> originalPc;
  public ArrayList<Line> lines;

  public PImage inputImage;
  public PImage grayImage;

  public float maxDensity = 100;

  public State() {
    pc = new ArrayList<PVector>();
    originalPc = new ArrayList<PVector>();
    lines = new ArrayList<Line>();
  }

  // Add other methods as needed
  
  public boolean svgSave = false;
  public boolean allImgSave = false;
  public boolean pointsSave = false;
  public boolean linesInfosSave = false;
  //public boolean allInfosSave = false;
  
  public float curveTightness = 0.33;
  
  public float[] paramValues = {
    particleNum, speed, lineAlpha, lineWeight,
    mapMin, mapMax, maxDensity, colorLines ? 1 : 0, showAllSections ? 1 : 0,
    applyEdgeDetection ? 1 : 0, gaussianBlurRadius, (float)volumeShiftValueX, (float)volumeShiftValueY, 
    (float)pointSerchRange, (float)pointSerchRangeMin, (float)pointSubtract, isClosestPointConnection ? 1 : 0, curveTightness, (float)harmonicFactor
  };
  
  public String timestamp = "0";
}
