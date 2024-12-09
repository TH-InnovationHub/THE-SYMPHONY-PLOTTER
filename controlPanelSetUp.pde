//ControlPanelSetUp.pde
void setupControlPanel() {
  cp5 = new ControlP5(this);

  int sliderWidth = 100;
  int sliderHeight = 20;
  int fontSize = 12;
  ControlFont font = new ControlFont(createFont("Arial", fontSize), fontSize);

  int y = 10;
  int groupMargin = 5;

  addSlider("particleNum", "Particle Number", 10, 25000, appState.particleNum, 10, y, sliderWidth, sliderHeight, font);
  y += sliderHeight + groupMargin;
  
  //addSlider("volumesFactor", "Volumes Factor", 1, 10, appState.volumesFactor, 10, y, sliderWidth, sliderHeight, font);
  //y += sliderHeight + groupMargin;

  addSlider("speed", "Speed", 1, 100, appState.speed, 10, y, sliderWidth, sliderHeight, font);
  y += sliderHeight + groupMargin;

  addSlider("lineAlpha", "Line Alpha", 0, 255, appState.lineAlpha, 10, y, sliderWidth, sliderHeight, font);
  y += sliderHeight + groupMargin;

  addSlider("lineWeight", "Line Weight", 0.1, 10, appState.lineWeight, 10, y, sliderWidth, sliderHeight, font);
  y += sliderHeight + groupMargin;

  addSlider("mapMin", "Map Min", 0, 100, appState.mapMin, 10, y, sliderWidth, sliderHeight, font);
  y += sliderHeight + groupMargin;

  addSlider("mapMax", "Map Max", -100, 100, appState.mapMax, 10, y, sliderWidth, sliderHeight, font);
  y += sliderHeight + groupMargin;
  
  
  addSlider("brightnessThreshhold", "brightnessThreshhold", 0, 100, appState.brightnessThreshhold, 10, y, sliderWidth, sliderHeight, font);
  y += sliderHeight + groupMargin;
    
  addSlider("harmonicFactor", "harmonicFactor", 1f, 10f, appState.harmonicFactor, 10, y, sliderWidth, sliderHeight, font);
  y += sliderHeight + groupMargin;
  
  addSlider("curveTightness", "curveTightness", -20.0, 20.0, appState.curveTightness, 10, y, sliderWidth, sliderHeight, font);
  y += sliderHeight + groupMargin;
  
  addSlider("pointSerchRange", "pointSerchRange", 1, 100, appState.pointSerchRange, 10, y, sliderWidth, sliderHeight, font);
  y += sliderHeight + groupMargin;
  
  addSlider("pointSerchRangeMin", "pointSerchRangeMin", 1, 100, appState.pointSerchRangeMin, 10, y, sliderWidth, sliderHeight, font);
  y += sliderHeight + groupMargin;
  
  addSlider("pointSubtract", "pointSubtract", 1, 1000, appState.pointSubtract, 10, y, sliderWidth, sliderHeight, font);
  y += sliderHeight + groupMargin;
  
  addSlider("volumeShiftValueX", "volumeShiftValueX", -100, 100, appState.volumeShiftValueX, 10, y, sliderWidth, sliderHeight, font);
  y += sliderHeight + groupMargin;
  
  addSlider("volumeShiftValueY", "volumeShiftValueY", -100, 100, appState.volumeShiftValueY, 10, y, sliderWidth, sliderHeight, font);
  y += sliderHeight + groupMargin;
  
  addToggle("isClosestPointConnection", "ClosestPoint Connection", appState.isClosestPointConnection, 10, y, sliderWidth, sliderHeight, font);
  y += sliderHeight + groupMargin;

  addToggle("colorLines", "Color Lines", appState.colorLines, 10, y, sliderWidth, sliderHeight, font);
  y += sliderHeight + groupMargin;

  addToggle("showAllSections", "Show All Sections", appState.showAllSections, 10, y, sliderWidth, sliderHeight, font);
  y += sliderHeight + groupMargin;

  addBang("changeImage", "Change Image", 10, y, sliderWidth, sliderHeight, font);
  y += sliderHeight + groupMargin;

  //addToggle("mode", "LINE Mode Straight", appState.lineMode == 1, 10, y, sliderWidth, sliderHeight, font);
  //y += sliderHeight + groupMargin;

  //addToggle("connectionMode", "Connection Mode Ordered", appState.connectionMode == 1, 10, y, sliderWidth, sliderHeight, font);
  //y += sliderHeight + groupMargin;

  //addSlider("maxDensity", "Max Density", 0, 100, appState.maxDensity, 10, y, sliderWidth, sliderHeight, font);
  //y += sliderHeight + groupMargin;

  //addToggle("edgeDetection", "Edge Detection", appState.applyEdgeDetection, 10, y, sliderWidth, sliderHeight, font);
  //y += sliderHeight + groupMargin;
  
  

  //addSlider("gaussianBlur", "Gaussian Blur", 0, 10, appState.gaussianBlurRadius, 10, y, sliderWidth, sliderHeight, font);
  //y += sliderHeight + groupMargin;

  //addToggle("audioVisualMode", "Audio Visual Mode", appState.AudioVisualMode, 10, y, sliderWidth, sliderHeight, font);
  //y += sliderHeight + groupMargin;

  //addToggle("audioReactiveLineMode", "Audio Reactive Line Mode", audioReactiveLineMode, 10, y, sliderWidth, sliderHeight, font);
  //y += sliderHeight + groupMargin;

  //addBang("saveImage", "Save Image", 10, y, sliderWidth, sliderHeight, font);
  //y += sliderHeight + groupMargin;
  
  addBang("saveVideo", "Save Video", 10, y, sliderWidth, sliderHeight, font);
  y += sliderHeight + groupMargin;
  
  //addBang("saveSVG", "Save SVG", 10, y, sliderWidth, sliderHeight, font);
  //y += sliderHeight + groupMargin;
  
  //addBang("savePoints", "Save Points", 10, y, sliderWidth, sliderHeight, font);
  //y += sliderHeight + groupMargin;


  //addBang("saveLinesInfos", "Save Lines Infos", 10, y, sliderWidth, sliderHeight, font);
  //y += sliderHeight + groupMargin;
  
  addBang("saveAllInfos", "Save All Infos", 10, y, sliderWidth, sliderHeight, font);


}

void addSlider(String name, String label, float min, float max, float defaultValue, int x, int y, int width, int height, ControlFont font) {
  cp5.addSlider(name)
     .setPosition(x, y)
     .setSize(width, height)
     .setRange(min, max)
     .setValue(defaultValue)
     .setColorValue(color(255))
     .setColorBackground(color(100, 100, 100))
     .setColorActive(color(150, 150, 150))
     .setFont(font)
     .setLabel(label)
     .plugTo(this, "set" + capitalize(name))
     .getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER).setPaddingX(160);
}

void addToggle(String name, String label, boolean defaultValue, int x, int y, int width, int height, ControlFont font) {
  cp5.addToggle(name)
     .setPosition(x, y)
     .setSize(width, height)
     .setValue(defaultValue)
     .setColorLabel(color(255))
     .setColorBackground(color(100, 100, 100))
     .setColorActive(color(150, 150, 150))
     .setFont(font)
     .setLabel(label)
     .plugTo(this, "toggle" + capitalize(name))
     .getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER).setPaddingX(160);
}

void addBang(String name, String label, int x, int y, int width, int height, ControlFont font) {
  cp5.addBang(name)
     .setPosition(x, y)
     .setSize(width, height)
     .setLabel(label)
     .setColorLabel(color(255))
     .setColorBackground(color(100, 100, 100))
     .setColorActive(color(150, 150, 150))
     .plugTo(this, name)
     .setFont(font)
     .getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER).setPaddingX(160);
}
