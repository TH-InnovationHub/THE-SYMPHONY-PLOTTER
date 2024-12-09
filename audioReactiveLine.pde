//AudioReactiveLine
boolean audioReactiveLineMode = false;
float audioReactiveLineProgress = 0;
float audioReactiveLineSpeed;
float lastUpdateTime = 0;
int maxConnectionsPerFrame = 10; // 1フレームあたりの最大接続数

void setupAudioReactiveLine() {
  calculateAudioReactiveLineSpeed();
  lastUpdateTime = millis() / 1000.0;
}

void calculateAudioReactiveLineSpeed() {
  if (player != null && player.length() > 0) {
    audioReactiveLineSpeed = appState.particleNum / (player.length() / 1000.0); // 1秒あたりの接続数
  } else {
    audioReactiveLineSpeed = 1; // デフォルト値
  }
}

void updateAudioReactiveLine() {
  if (player != null && player.isPlaying()) {
    float currentTime = millis() / 1000.0;
    float deltaTime = currentTime - lastUpdateTime;
    lastUpdateTime = currentTime;

    int connectionsToMake = floor(audioReactiveLineSpeed * deltaTime);
    connectionsToMake = min(connectionsToMake, maxConnectionsPerFrame); // 1フレームあたりの最大接続数を制限
    
    for (int i = 0; i < connectionsToMake; i++) {
      if (!appState.pc.isEmpty()) {
        createAudioReactiveConnection();
      } else {
        break; // すべての点が接続されたら停止
      }
    }
    
    audioReactiveLineProgress = (float)player.position() / player.length();
  }
}

void createAudioReactiveConnection() {
  if (appState.lines.isEmpty() && appState.pc.size() > 2) {
    PVector start, end;
    int startIndex = (int) random(appState.pc.size());
    start = appState.pc.get(startIndex);
    appState.pc.remove(startIndex);
    int endIndex = getAudioReactiveIndex(start, appState.pc);
    end = appState.pc.get(endIndex);
    appState.pc.remove(endIndex);
    appState.lines.add(new Line(start, end));
    appState.lines.get(appState.lines.size() - 1).setStrokeWeightAndColor(appState.inputImage.pixels, appState.inputImage.width, appState.inputImage.height);
  } else {
    if (!appState.pc.isEmpty()) {
      PVector start = appState.lines.get(appState.lines.size() - 1).end, end;
      int index = getAudioReactiveIndex(start, appState.pc);
      end = appState.pc.get(index);
      appState.pc.remove(index);
      appState.lines.add(new Line(start, end));
      appState.lines.get(appState.lines.size() - 1).setStrokeWeightAndColor(appState.inputImage.pixels, appState.inputImage.width, appState.inputImage.height);
    }
  }
  if (appState.closeLine && appState.pc.isEmpty() && !appState.lines.isEmpty()) {
    PVector start = appState.lines.get(appState.lines.size() - 1).end;
    PVector end = appState.lines.get(0).start;
    appState.lines.add(new Line(start, end));
    appState.lines.get(appState.lines.size() - 1).setStrokeWeightAndColor(appState.inputImage.pixels, appState.inputImage.width, appState.inputImage.height);
  }
}

int getAudioReactiveIndex(PVector start, ArrayList<PVector> lookup) {
  int searchRange = floor(map(volumeAudio, 0, 1, 1, min(1000, lookup.size())));
  ArrayList<Integer> indicesPool = new ArrayList<Integer>();
  
  for (int i = 0; i < lookup.size(); i++) {
    indicesPool.add(i);
  }
  
  float closestDist = width * height;
  int closestIndex = 0;
  
  for (int i = 0; i < searchRange; i++) {
    if (indicesPool.isEmpty()) break;
    int randomPoolIndex = floor(random(indicesPool.size()));
    int randomLookupIndex = indicesPool.get(randomPoolIndex);
    indicesPool.remove(randomPoolIndex);
    
    float dis = PVector.dist(start, lookup.get(randomLookupIndex));
    if (dis < closestDist) {
      closestDist = dis;
      closestIndex = randomLookupIndex;
    }
  }
  
  return closestIndex;
}
