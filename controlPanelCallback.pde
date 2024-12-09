//ControlPanelCallback
void setParticleNum(float value) {
  appState.particleNum = int(value);
  initPointCloud();
}

//void setVolumesFactor(int value) {
//  appState.volumesFactor = int(value);
//  initPointCloud();
//}

void setSpeed(float value) {
  appState.speed = int(value);
}

void setLineAlpha(float value) {
  appState.lineAlpha = value;
  updateLineStyles();
}

void setLineWeight(float value) {
  appState.lineWeight = value;
  updateLineStyles();
}

void setMapMin(float value) {
  appState.mapMin = value;
  initPointCloud();
}

void setMapMax(float value) {
  appState.mapMax = value;
  initPointCloud();
}

void setBrightnessThreshhold(int value) {
  appState.brightnessThreshhold = (int)value;
  initPointCloud();
}



void setVolumeShiftValueX(float value) {
  appState.volumeShiftValueX = value;
}

void setVolumeShiftValueY(float value) {
  appState.volumeShiftValueY = value;
}

void toggleIsClosestPointConnection (boolean value) {
  appState.isClosestPointConnection = value;
  initPointCloud();
}

void setPointSerchRange(int value) {
  appState.pointSerchRange = value;
  initPointCloud();
}

void setPointSerchRangeMin(int value) {
  appState.pointSerchRangeMin = value;
  initPointCloud();
}

void setCurveTightness(float value) {
  appState.curveTightness = value;
  //initPointCloud();
}

void setPointSubtract(int value) {
  appState.pointSubtract = value;
  initPointCloud();
}

void setHarmonicFactor(float value) {
  appState.harmonicFactor = value;
  initPointCloud();
}


void setMaxDensity(float value) {
  appState.maxDensity = value;
  initPointCloud();
}

void toggleColorLines(boolean value) {
  appState.colorLines = value;
  updateLineStyles();
  initPointCloud();
}

void toggleShowAllSections(boolean value) {
  appState.showAllSections = value;
}

void changeImage() {
  appState.currentImageIndex = (appState.currentImageIndex + 1) % Constants.IMAGE_PATHS.length;
  loadImageAndConvertToGray(Constants.IMAGE_PATHS[appState.currentImageIndex]);
  processVolumeData("input/csv/2408102/" + Constants.CSV_PATHS[appState.currentImageIndex], volumesFactor);
  if (appState.grayImage.width != Constants.GRID_WIDTH || appState.grayImage.height != Constants.GRID_HEIGHT) {
    appState.grayImage.resize(Constants.GRID_WIDTH, Constants.GRID_HEIGHT);
  }
  if (appState.inputImage.width != Constants.GRID_WIDTH || appState.inputImage.height != Constants.GRID_HEIGHT) {
    appState.inputImage.resize(Constants.GRID_WIDTH, Constants.GRID_HEIGHT);
  }
  initPointCloud();
}

void toggleMode(boolean value) {
  appState.lineMode = value ? 1 : 0;
}

void toggleConnectionMode(boolean value) {
  appState.connectionMode = value ? 1 : 0;
  initPointCloud();
}

void toggleEdgeDetection(boolean value) {
  appState.applyEdgeDetection = value;
  applyFilters();
}

void setGaussianBlur(float value) {
  appState.gaussianBlurRadius = int(value);
  applyFilters();
}

void saveImage(String _name) {
  String filename = videoOutputDirName + "/line_art_" + appState.timestamp + _name +".png";
  save(filename);
  println("Image saved as " + filename);
}

void saveVideo() {
  appState.speed = 1;
  videoOutputDirName = "./output/ " + appState.timestamp;
  initPointCloud();
  // VideoExportの初期化
  appState.videoExporting = true;
  
  File dir = new File(videoOutputDirName);
  if (!dir.exists()) {
    dir.mkdirs();
  }
}

void saveSVG() {
  appState.svgSave = true;
}

void savePoints() {
  appState.pointsSave = true;
}

void saveLinesInfos() {
  appState.linesInfosSave = true;
}



void updateLineStyles() {
  for (Line line : appState.lines) {
    line.updateStyle(appState.lineAlpha, appState.lineWeight, appState.colorLines);
  }
}

void applyFilters() {
  // 初回はinputImageをコピーして開始
  if (appState.grayImage == null) {
    appState.grayImage = appState.inputImage.copy();
  }

  PImage tempImage = appState.grayImage.copy();  // 一時的な画像を作成

  if (appState.applyEdgeDetection) {
    tempImage = applySobelFilter(tempImage);
    addImages(appState.grayImage, tempImage);  // フィルタ結果を加算
  }

  if (appState.gaussianBlurRadius > 0) {
    tempImage = applyGaussianBlur(tempImage, appState.gaussianBlurRadius);
    addImages(appState.grayImage, tempImage);  // フィルタ結果を加算
  }

  initPointCloud();
}
void multiplyImages(PImage baseImage, PImage mulImage) {
  baseImage.loadPixels();
  mulImage.loadPixels();
  
  for (int i = 0; i < baseImage.pixels.length; i++) {
    // 画像の各ピクセルを乗算（255でスケーリング）
    int baseColor = baseImage.pixels[i];
    int mulColor = mulImage.pixels[i];
    
    int r = (int)(red(baseColor) * red(mulColor) / 255.0);
    int g = (int)(green(baseColor) * green(mulColor) / 255.0);
    int b = (int)(blue(baseColor) * blue(mulColor) / 255.0);
    
    baseImage.pixels[i] = color(r, g, b);
  }
  
  baseImage.updatePixels();
}

// 2つの画像をピクセルごとに加算するヘルパー関数
void addImages(PImage baseImage, PImage addImage) {
  baseImage.loadPixels();
  addImage.loadPixels();
  
  for (int i = 0; i < baseImage.pixels.length; i++) {
    // 画像の各ピクセルを加算（範囲を考慮）
    int baseColor = baseImage.pixels[i];
    int addColor = addImage.pixels[i];
    
    int r = min(255, (int)(red(baseColor) + red(addColor) * 0.5));
    int g = min(255, (int)(green(baseColor) + green(addColor)* 0.5));
    int b = min(255, (int)(blue(baseColor) + blue(addColor)* 0.5));
    
    baseImage.pixels[i] = color(r, g, b);
  }
  
  baseImage.updatePixels();
}


void toggleAudioVisualMode(boolean value) {
  appState.AudioVisualMode = value;
  resetVisualization();
}

void toggleAudioReactiveLineMode(boolean value) {
  audioReactiveLineMode = value;
  if (audioReactiveLineMode) {
    initPointCloud();
    calculateAudioReactiveLineSpeed();
  }
}
