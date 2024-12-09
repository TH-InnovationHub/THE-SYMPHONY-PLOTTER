// PointCloud.pde

void initPointCloud() {
  currentFrame  = 0;
  appState.pc = new ArrayList<PVector>();
  appState.originalPc = new ArrayList<PVector>();
  appState.lines = new ArrayList<Line>();
  
  int _w = Constants.CANVAS_WIDTH;
  int _h = Constants.CANVAS_HEIGHT;
  if (true) {
    _w = Constants.GRID_WIDTH;
    _h = Constants.GRID_HEIGHT;
  }

  PVector[] targets = findTargets(appState.particleNum, appState.grayImage);

  // targetsの最後からappState.tract分の要素を削除
  //int newLength = max(0, targets.length - appState.pointSubtract);
  int newLength = max(0, targets.length);

  PVector[] modifiedTargets = new PVector[newLength];
  for (int i = 0; i < newLength; i++) {
    modifiedTargets[i] = targets[i];
  }

  // 新しいリストを作成してtargetsの先頭に要素を追加
  ArrayList<PVector> targetList = new ArrayList<PVector>();
  //targetList.add(new PVector(0, _h / 2));
  //targetList.add(new PVector(200, _h / 2));
  
  // modifiedTargetsの要素を追加
  for (PVector target : modifiedTargets) {
    targetList.add(target);
  }
  
  //// 最後に新しい要素を追加
  //targetList.add(new PVector(_w - 200, _h / 2));
  //targetList.add(new PVector(_w, _h / 2));

  // targetListの要素をappState.pcとappState.originalPcに追加
  for (PVector target : targetList) {
    appState.pc.add(target);
    appState.originalPc.add(target.copy());
  }
  
  // デバッグ用出力
  println("appState.pc size: " + appState.pc.size());
  println("appState.originalPc size: " + appState.originalPc.size());
  println("First element in appState.pc: " + appState.pc.get(0));
  println("Last element in appState.pc: " + appState.pc.get(appState.pc.size() - 1));
}



void createConnection(int cMode) {
  //if (appState.lines.isEmpty() && appState.pc.size() > 2) {
  //  PVector start;
  //  int startIndex = (int) random(appState.pc.size());
  //  start = appState.pc.get(startIndex);
  //  appState.pc.remove(startIndex);
  //  appState.lines.add(new Line(start, start));
  //  appState.lines.get(appState.lines.size() - 1).setStrokeWeightAndColor(appState.inputImage.pixels, appState.inputImage.width, appState.inputImage.height);
  //} else {
  //  if (!appState.pc.isEmpty()) {
  //    int range = 1;

  //    if (currentFrame < drawLineTotalFrames && volumes.length > 2) {
  //      float volume = volumes[currentFrame];
  //      range = (int) (volume * 20);
  //    }

  //    PVector start = appState.lines.get(appState.lines.size() - 1).end;
  //    PVector end;

  //    int index = getFarthestIndexWithinDistance(start, range, appState.pc);
  //    index = cMode == 0 ? getClosestIndex(start, range, appState.pc) : getClosestIndex(start, appState.pc);

  //    // 見つからなかった場合は最も近いポイントを使用
  //    if (index == -1) {
  //      index = getClosestIndex(start, appState.pc);
  //    }

  //    end = appState.pc.get(index);
  //    appState.pc.remove(index);
  //    appState.lines.add(new Line(start, end));
  //    appState.lines.get(appState.lines.size() - 1).setStrokeWeightAndColor(appState.inputImage.pixels, appState.inputImage.width, appState.inputImage.height);
  //    currentFrame++;
  //  }
  //}
  
  if (appState.lines.isEmpty() && appState.pc.size() > 2) {
    //PVector start, end;
    PVector start;
    int startIndex = (int) random(appState.pc.size());
    //startIndex = 0; //最初の点固定
    start = appState.pc.get(startIndex);
    appState.pc.remove(startIndex);
    //int endIndex = getClosestIndex(start, appState.pc);
    //endIndex = appState.pc.size() - 1;
    //end = appState.pc.get(endIndex);
    //appState.pc.remove(endIndex);
    appState.lines.add(new Line(start, start));
    appState.lines.get(appState.lines.size() - 1).setStrokeWeightAndColor(appState.inputImage.pixels, appState.inputImage.width, appState.inputImage.height);
     //if(appState.videoExporting){
     //    String fileName = String.format("frames/frame-%05d.jpg", currentFrame);
     //    save(fileName);
     //    //saveFrame(videoOutputDirName + "/frame-#####.jpg");
     // }

  } else {
    if(appState.pc.size() < appState.pointSubtract){
        appState.pc.clear();
        if(appState.videoExporting){
           //videoExport.endMovie();
           appState.videoExporting =false;
           //videoExport = null;
        }
    }else if (!appState.pc.isEmpty()) {
      int range = 1;
       //print(volumes.length);

      if(currentFrame < drawLineTotalFrames  && volumes.length > 2){
        //print(volumes[currentFrame]);
        float volume = volumes[currentFrame];
        //float pitch = pitches[currentFrame];
        //float harmonic = harmonics[currentFrame];
        //float entropy = entropies[currentFrame];

         range = (int)(volume * (appState.pointSerchRange)) + appState.pointSerchRangeMin;
      }
      PVector start = appState.lines.get(appState.lines.size() - 1).end, end;
      int index = cMode == 0 ? getClosestIndex(start, range, appState.pc) : getClosestIndex(start, appState.pc);
      if(!appState.isClosestPointConnection){
           index = getFarthestIndexWithinDistance(start, range, appState.pc);
      }
      //int index = getFarthestIndexWithinDistance(start, range, appState.pc);
       if (index == -1) {
        index = getClosestIndex(start, appState.pc);
      }
      //int index = cMode == 0 ? getClosestIndex(start, appState.pointSerchRange, appState.pc) : getClosestIndex(start, appState.pc);

      end = appState.pc.get(index);
      appState.pc.remove(index);
      appState.lines.add(new Line(start, end));
      appState.lines.get(appState.lines.size() - 1).setStrokeWeightAndColor(appState.inputImage.pixels, appState.inputImage.width, appState.inputImage.height);
     
      if(appState.videoExporting){
        String fileName = String.format(videoOutputDirName + "/frame-%05d.jpg", currentFrame);
        save(fileName);
        //saveFrame(videoOutputDirName + "/frame-#####.jpg");
      }
      currentFrame++;
    }
  }
  
  
  
//  if (appState.lines.isEmpty() && appState.pc.size() > 2) {
//    // 最初の接続: 最初の点を固定し、探索を開始
//    PVector start, end, secondLast;
//    start = appState.pc.get(0); // 最初の点を固定
//    appState.pc.remove(0);
//    end = appState.pc.get(appState.pc.size() - 1); // 最後の点を固定
//    appState.pc.remove(appState.pc.size() - 1);

//    // 最後から2番目の点を見つける
//    int secondLastIndex = getClosestIndex(end, appState.pc);
//    secondLast = appState.pc.get(secondLastIndex);
//    appState.pc.remove(secondLastIndex);

//    // 最後の点と最後から2番目の点を一時的に先頭に追加（中間の接続から除外するため）
//    appState.pc.add(0, end);
//    appState.pc.add(0, secondLast);

//    appState.lines.add(new Line(start, start)); // ダミーラインを追加して開始点を記録
//  } else if (appState.pc.size() > 2) {
//    // 中間の接続: 残りの点を接続（最後の点を除外）
//    PVector start = appState.lines.get(appState.lines.size() - 1).end;
//    ArrayList<PVector> tempPc = new ArrayList<>(appState.pc);
//    tempPc.remove(0); // 最後の点を一時的に除外
//    tempPc.remove(0); // 最後から2番目の点を一時的に除外
//    int index = cMode == 0 ? getClosestIndex(start, appState.pointSerchRange, tempPc) : getClosestIndex(start, tempPc);
//    PVector end = tempPc.get(index);
//    appState.pc.remove(end);
//    appState.lines.add(new Line(start, end));
//    appState.lines.get(appState.lines.size() - 1).setStrokeWeightAndColor(appState.inputImage.pixels, appState.inputImage.width, appState.inputImage.height);
   
//} else if (appState.pc.size() == 2) {
//    // 最後から2番目の接続
//    PVector start = appState.lines.get(appState.lines.size() - 1).end;
//    PVector secondLast = appState.pc.get(0); // 最後から2番目の点を固定
//    appState.pc.remove(0);
//    appState.lines.add(new Line(start, secondLast));
//    appState.lines.get(appState.lines.size() - 1).setStrokeWeightAndColor(appState.inputImage.pixels, appState.inputImage.width, appState.inputImage.height);
//  } else if (appState.pc.size() == 1) {
//    // 最後の接続: 最後の点を固定
//    PVector start = appState.lines.get(appState.lines.size() - 1).end;
//    PVector end = appState.pc.get(0); // 最後の点を固定
//    appState.pc.remove(0);
//    appState.lines.add(new Line(start, end));
//    appState.lines.get(appState.lines.size() - 1).setStrokeWeightAndColor(appState.inputImage.pixels, appState.inputImage.width, appState.inputImage.height);
//  }

  // 最後にすべての点が接続されたら、最初と最後を結ぶ
  //if (appState.closeLine && appState.pc.isEmpty() && !appState.lines.isEmpty()) {
  //  PVector start = appState.lines.get(appState.lines.size() - 1).end;
  //  PVector end = appState.lines.get(0).start;
  //  appState.lines.add(new Line(start, end));
  //  appState.lines.get(appState.lines.size() - 1).setStrokeWeightAndColor(appState.inputImage.pixels, appState.inputImage.width, appState.inputImage.height);
  //}

 
}

PVector[] findTargets(int n, PImage img) {
  img.loadPixels();
  println("Searching for targets");
  PVector[] target = new PVector[n];

  PVector pos;
  for (int i = 0; i < target.length; i++) {
    pos = target(img.pixels, (int) random(img.width), (int) random(img.height), img.width, img.height, 0);
    target[i] = pos;
  }

  return target;
}
//PVector target(int[] colors, int x, int y, int W, int H, int depth) {
//  while (depth < 15) {
//    int index = y * W + x;
//    color c = colors[index];

//    if (isValidTarget(brightness(c))) {
//      return new PVector(x, y);
//    }

//    x = (int) random(W);
//    y = (int) random(H);
//    depth++;
//  }
//  return new PVector(x, y); // 見つからなかった場合、最後の位置を返す
//}

PVector target(int[] colors, int x, int y, int W, int H, int depth) {
  PVector pos = new PVector(0, 0);
  int index = y * W + x;
  color c = colors[index];

  if (depth == 15 || isValidTarget(brightness(c))) {
    pos.x = x;
    pos.y = y;
  } else {
    pos = target(colors, (int) random(W), (int) random(H), W, H, depth++); //再起的処理
  }

  return pos;
}

boolean isValidTarget(float fbrightness) {
  if (fbrightness < appState.brightnessThreshhold) return false;
  float value = map(fbrightness, 0, 255, appState.mapMin, appState.mapMax);

  float iRandom = random(0, value);
  return iRandom <= 1;
}
