import controlP5.*;
import processing.svg.*;

import com.hamoid.*;
import java.text.SimpleDateFormat;
import java.util.Date;

String videoOutputDirName;
//String appState.timestamp = "0";  // nullで初期化

ControlP5 cp5;
PFont font;
State appState;

Table table;
int currentFrame = 0;
int drawLineTotalFrames;
float[] volumes;
float[] pitches;
float[] harmonics;
float[] entropies;

int volumesFactor = 3;

boolean clearBackground = true;

String[] paramNames = {
  "Particle Number", "Speed", "Line Alpha", "Line Weight",
  "Map Min", "Map Max", "Max Density", "Color Lines", "Show All Sections",
  "Edge Detection", "Gaussian Blur", "Volume ShiftValueX", "Volume ShiftValueY", "Point SerchRange", "Point SerchRangeMin", 
  "Point Subtract", "ClosestPointConnection","Curve Tightness", "Harmonic Factor"
};

void setup() {
  size(842,1190);
  smooth();
  frameRate(30);
  font = createFont("Arial", 14);
  
  appState = new State();
  
  appState.brightnessThreshhold = 30;
  
  //Volumeデータのインポート
  processVolumeData("input/csv/2408102/" + Constants.CSV_PATHS[0], volumesFactor);
  
  points = new ArrayList<PVector>(); // pointsを初期化
  interpolatedPoints = new ArrayList<PVector>(); // interpolatedPointsを初期化

  setupAudio(); // オーディオを初期化（再生はしない）
  setupBaseShape(); // ベースシェイプを初期化
  setupWaveShape(); // WaveShapeの初期化
  setupAudioReactiveLine();
  setupAudioWavePoint();

  appState.inputImage = createImage(Constants.GRID_WIDTH, Constants.GRID_HEIGHT, RGB);
  appState.grayImage = createImage(Constants.GRID_WIDTH, Constants.GRID_HEIGHT, RGB);
  loadImageAndConvertToGray(Constants.IMAGE_PATHS[appState.currentImageIndex]);

  if (appState.grayImage.width != Constants.GRID_WIDTH || appState.grayImage.height != Constants.GRID_HEIGHT) {
    appState.grayImage.resize(Constants.GRID_WIDTH, Constants.GRID_HEIGHT);
  }
  if (appState.inputImage.width != Constants.GRID_WIDTH || appState.inputImage.height != Constants.GRID_HEIGHT) {
    appState.inputImage.resize(Constants.GRID_WIDTH, Constants.GRID_HEIGHT);
  }

  setupControlPanel();
  initPointCloud();

  appState.AudioVisualMode = false; // 初期モードを設定
}

void paramUpdate() {
  float[] paramValues = {
    appState.particleNum, appState.speed, appState.lineAlpha, appState.lineWeight,
    appState.mapMin, appState.mapMax, appState.maxDensity, appState.colorLines ? 1 : 0, appState.showAllSections ? 1 : 0,
    appState.applyEdgeDetection ? 1 : 0, appState.gaussianBlurRadius, (float)appState.volumeShiftValueX, (float)appState.volumeShiftValueY, 
    (float)appState.pointSerchRange, (float)appState.pointSerchRangeMin, (float)appState.pointSubtract, appState.isClosestPointConnection ? 1 : 0, appState.curveTightness, appState.harmonicFactor
  };
  appState.paramValues = paramValues;
}

void draw() {

  if (clearBackground) {
    background(0);
  }
  if (appState.AudioVisualMode) {
    if (audioReactiveLineMode) {
      updateAudio();
      updateAudioReactiveLine();
      drawLineArtFullScreen();
    } else {
      if (clearBackground) {
        background(0);
      }
      pushMatrix();
      scale(2);
      updateAudio();
      updateAudioWavePoint();
      drawBaseShape();
      drawWaveOnShape();
      drawAudioWavePoint();
      popMatrix();
    }
    drawProgressBar(progress);
  } else {
    clearBackground = true;
    updateLineStyles();

    if (appState.showAllSections) {
      drawAllSections();
      if (appState.svgSave){
        appState.showAllSections = !appState.showAllSections;
        drawLineArtFullScreenSVGSave();        
        appState.showAllSections = !appState.showAllSections;
      }
      if (appState.allImgSave){
        appState.timestamp = getTimeStamp();
        background(0);
        drawAllSections();
        save("output/allImg/"+ appState.timestamp +"/line_art_" + appState.timestamp +""+".png");
        background(0);
        drawLineArtFullScreen();
        save("output/allImg/"+ appState.timestamp +"/line_art_" + appState.timestamp +"line"+".png");
        background(0);    
        drawPointArtFullScreen();
        save("output/allImg/"+ appState.timestamp +"/line_art_" + appState.timestamp +"point"+".png");
        appState.allImgSave = !appState.allImgSave;
      }
    } else {
      //drawLineArtFullScreen();
      drawPointArtFullScreen();
    }
    if (appState.svgSave){
        drawLineArtFullScreenSVGSave();        
    }
    if (appState.pointsSave){
        drawLineArtFullScreenPointsSave();
    }
    if (appState.linesInfosSave){
        drawLineArtFullScreenLinesInfosSave();
    }
    for (int i = 0; i < appState.speed; i++) createConnection(appState.connectionMode);
  }
  if (!appState.audioReactiveMode) {
    displayProgress();
  }
  paramUpdate();
}

void mousePressed() {
  // Mouse press handling if needed
}

void keyPressed() {
  switch (key) {
    case 'a': initPointCloud(); break;
    case 'd': toggleControlP5(); break;
    case 's': saveAllInfos(); break;
    case 'f': appState.showAllSections = !appState.showAllSections; break;
    case 'g': appState.allImgSave = !appState.allImgSave; break;
  }
}

void saveAll() {
  // セーブ時に一度だけタイムスタンプを生成
  if (appState.timestamp == "0") {
    appState.timestamp = getTimeStamp();
  }
  
  drawLineArtFullScreenSVGSave();
  drawLineArtFullScreenPointsSave();
  drawLineArtFullScreenLinesInfosSave();
  
  // セーブ後にタイムスタンプをクリア
  
}

public void saveAllInfos() {
  if (appState.timestamp == "0") {
    appState.timestamp = getTimeStamp();
  }
  appState.svgSave = true;
  appState.pointsSave = true;
  appState.linesInfosSave = true;
}

void drawAllSections() {
  image(appState.inputImage, 0, 0, Constants.GRID_WIDTH, Constants.GRID_HEIGHT);
  image(appState.grayImage, Constants.GRID_WIDTH, 0, Constants.GRID_WIDTH, Constants.GRID_HEIGHT);
  drawSection(0, Constants.GRID_HEIGHT, appState.originalPc, new PVectorDrawer(), Constants.GRID_WIDTH, Constants.GRID_HEIGHT);
  drawSection(Constants.GRID_WIDTH, Constants.GRID_HEIGHT, appState.lines, new LineDrawer(), Constants.GRID_WIDTH, Constants.GRID_HEIGHT);
}

void drawLineArtFullScreen() {
  drawSection(0, 0, appState.lines, new LineDrawer(), Constants.CANVAS_WIDTH, Constants.CANVAS_HEIGHT);
}

void drawPointArtFullScreen() {
  drawSection(0, 0, appState.originalPc, new PVectorDrawer(), Constants.CANVAS_WIDTH, Constants.CANVAS_HEIGHT);
}

void drawLineArtFullScreenSVGSave() {
    // タイムスタンプ付きのディレクトリを作成
    videoOutputDirName = "output/" + appState.timestamp;
    File outputDir = new File(videoOutputDirName);
    outputDir.mkdirs();  // ディレクトリを作成
    
    saveImage("");

    String filename = "line_art_" + appState.timestamp + ".svg";
    println("Saved SVG as " + filename);
    beginRecord(SVG, videoOutputDirName + "/" + filename);
    drawLineArtFullScreen();
    endRecord(); 
    
    
    PrintWriter file;
    file = createWriter(videoOutputDirName + "/line_art_" + appState.timestamp + ".csv");
    
    for (int i = 0; i < paramNames.length; i++) {
      file.print(paramNames[i]);
      file.print(",");
      file.println(appState.paramValues[i]);
    }

    file.flush();
    file.close();

    
    appState.svgSave = false;
    
}

void drawLineArtFullScreenPointsSave() {
    PrintWriter file;
    file = createWriter(videoOutputDirName + "/line_art_points_" + appState.timestamp + ".csv");
    
    for (int i = 0; i < appState.originalPc.size(); i++) {
      file.print(appState.originalPc.get(i).x);
      file.print(",");
      file.print(appState.originalPc.get(i).y);
      file.print(",");
      file.print(appState.originalPc.get(i).z);
      file.print(",");
      file.println(volumes[i]);
    }
    file.flush();
    file.close();
    
    println("save points csv as " + videoOutputDirName + "/line_art_points_" + appState.timestamp + ".csv");
    appState.pointsSave = false;
}

void drawLineArtFullScreenLinesInfosSave() {
    PrintWriter file;
    file = createWriter(videoOutputDirName + "/line_art_lines_infos_" + appState.timestamp + ".csv");
    
    for (int i = 0; i < appState.lines.size(); i++) {
      file.print(appState.lines.get(i).start.x);
      file.print(",");
      file.print(appState.lines.get(i).start.y);
      file.print(",");
      file.print(appState.lines.get(i).middle.x);
      file.print(",");
      file.print(appState.lines.get(i).middle.y);
      file.print(",");
      file.print(appState.lines.get(i).end.x);
      file.print(",");
      file.print(appState.lines.get(i).end.y);
      file.print(",");
      file.print(volumes[i]);
      file.print(",");
      file.print(appState.volumeShiftValueX);
      file.print(",");
      file.print(appState.volumeShiftValueY);
      file.print(",");
      file.print(appState.lines.get(i).sw);
      file.print(",");
      file.println(appState.lines.get(i).sw);
    }
    file.flush();
    file.close();
    
    println("save lines infos csv as " + videoOutputDirName + "/line_art_lines_infos_" + appState.timestamp + ".csv");
    appState.linesInfosSave = false;
    appState.timestamp = "0";
}

void displayProgress() {
  if(!appState.debugUIVisible || !appState.showAllSections){
    return;
  }
  
  if (!appState.pc.isEmpty()) {
    fill(255);
    noStroke();
    String txt = "Processing";
    if (frameCount % 3 == 0) txt += ".  ";
    else if (frameCount % 3 == 1) txt += ".. ";
    else txt += "...";
    txt += " [" + nf((float) (appState.particleNum - appState.pc.size()) / (float) appState.particleNum * 100.0, 0, 2) + "%]";
    text(txt, 20, 800);
  }
  fill(255);
  textAlign(LEFT, TOP);
  int y = 1000;
  
  for (int i = 0; i < paramNames.length; i++) {
    text(paramNames[i] + ": " + appState.paramValues[i], 20, y);
    y += 20;
  }
  text("TIMESTAMP: " + appState.timestamp,20,y);
  y += 20;
  text("FPS: " + frameRate,20,y);
}

void resetVisualization() {
  points.clear(); // ポイントをクリア
  interpolatedPoints.clear(); // 近似直線をクリア

  if (appState.AudioVisualMode) {
    generateBaseShape();
    setupWaveShape(); 
    setupAudioWavePoint();
    if (audioReactiveLineMode) {
      initPointCloud();
      setupAudioReactiveLine();
      calculateAudioReactiveLineSpeed();
    }
    if (player != null) {
      player.play(); // オーディオ再生を開始
    }
  } else {
    initPointCloud(); // PointCloudを再生成
    if (player != null) {
      pauseAndResetAudio();
    }
  }
}

void stop() {
  if (appState.AudioVisualMode) {
    stopAudio();
  }
  super.stop();
}

void drawProgressBar(float progress) {
  int barWidth = width - 40;
  int barHeight = 20;
  int x = 20;
  int y = height - 40;
  
  // Draw background
  fill(50);
  noStroke();
  rect(x, y, barWidth, barHeight);
  
  // Draw progress
  fill(255);
  rect(x, y, barWidth * progress, barHeight);
  
  // Draw progress text
  fill(255);
  textAlign(CENTER, CENTER);
  text(nf(progress * 100, 0, 2) + "%", width / 2, y + barHeight / 2 - 20);
}

void toggleControlP5() {
  appState.debugUIVisible = !appState.debugUIVisible;
  if (appState.debugUIVisible) {
    cp5.show();
  } else {
    cp5.hide();
  }
}

// volumesのデータを処理する関数
void processVolumeData(String csvFilePath, int factor) {
  table = loadTable(csvFilePath, "header");

  // フレームの総数を取得
  drawLineTotalFrames = table.getRowCount() * factor;

  // ボリュームデータを配列に格納
  volumes = new float[drawLineTotalFrames];
  pitches = new float[drawLineTotalFrames];
  harmonics = new float[drawLineTotalFrames];
  entropies = new float[drawLineTotalFrames];

  int index = 0;

  for (int i = 0; i < table.getRowCount(); i++) {
    TableRow row = table.getRow(i);
    float volume = row.getFloat("Volume");
    float pitch = row.getFloat("Spectral Centroid (Hz)");
    float harmonic = row.getFloat("Harmonic Strength");
    float entropy = row.getFloat("Spectral Entropy");

    // `factor` 回繰り返し同じvolume値をvolumesに代入
    for (int j = 0; j < factor; j++) {
      volumes[index] = volume * 20.0;
      pitches[index] = pitch;
      harmonics[index] = harmonic * 1.0;
      entropies[index] = entropy;

      if (volumes[index] < 0.1) {
        volumes[index] = 0;
      }

      index++;
    }
  }

  appState.particleNum = drawLineTotalFrames;
  println("particleNum", appState.particleNum);
  println("drawLineTotalFrames", drawLineTotalFrames);
}

// 中央値を計算し表示する関数
float calculateAndDisplayMedian(float[] array) {
  float median = getMedian(array);
  println("Median Volume: " + median);
  return median;
}

// 中央値を計算する関数
float getMedian(float[] array) {
  float[] sortedArray = bubbleSort(array);

  int middle = sortedArray.length / 2;
  if (sortedArray.length % 2 == 0) {
    return (sortedArray[middle - 1] + sortedArray[middle]) / 2.0;
  } else {
    return sortedArray[middle];
  }
}

// バブルソートを使って配列をソートする関数
float[] bubbleSort(float[] array) {
  float[] sortedArray = array.clone();
  int n = sortedArray.length;
  for (int i = 0; i < n-1; i++) {
    for (int j = 0; j < n-i-1; j++) {
      if (sortedArray[j] > sortedArray[j+1]) {
        float temp = sortedArray[j];
        sortedArray[j] = sortedArray[j+1];
        sortedArray[j+1] = temp;
      }
    }
  }
  return sortedArray;
}

String getTimeStamp() {
  SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd_HHmmss");
  return sdf.format(new Date());
}
