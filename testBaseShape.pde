//TestBaseShape.pde

ArrayList<PVector> basePoints; // ベースの形状を保存するリスト
int baseRadius = 300; // 基本半径
int shapeType = 0; // 図形の種類 0:円, 1:四角, 2:リサジュー図形

void setupBaseShape() {
  basePoints = new ArrayList<PVector>();
  generateBaseShape();
}

void generateBaseShapeFromLines() {
 basePoints.clear();
  if (appState.lines.isEmpty()) {
    // デフォルトの円形状を生成
    generateCircleBase();
  } else {
    for (Line line : appState.lines) {
      basePoints.add(line.start);
      if (line.middle != null) {
        basePoints.add(line.middle);
      }
      basePoints.add(line.end);
    }
  }
}

void generateBaseShape() {
  basePoints.clear();
  if (appState.lines.isEmpty()) {
    // デフォルトの円形状を生成
    generateCircleBase();
  } else {
    //generateLissajousBase();
    for (Line line : appState.lines) {
      //line.start.x *= 2.0;
      //line.start.y *= 2.0;
      //line.middle.x *= 2.0;
      //line.middle.y *= 2.0;
      //line.end.x *= 2.0;
      //line.end.y *= 2.0;
      // start, middle, endを使用して曲線のベースポイントを追加
      basePoints.add(line.start);
      if (line.middle != null) {
        basePoints.add(line.middle);
      }
      basePoints.add(line.end);
    }
  }
  //switch (shapeType) {
  //  case 0:
  //    generateCircleBase();
  //    break;
  //  case 1:
  //    generateSquareBase();
  //    break;
  //  case 2:
  //    generateLissajousBase();
  //    break;
  //}
}

void generateCircleBase() {
  int numPoints = 4; // 最低限の点数を設定
  for (int i = 0; i < numPoints; i++) {
    float theta = TWO_PI * i / numPoints;
    float baseX = cos(theta) * baseRadius;
    float baseY = sin(theta) * baseRadius;
    basePoints.add(new PVector(baseX, baseY));
  }
}

void generateSquareBase() {
  int numPointsPerSide = 9; // 最低限の点数を設定
  for (int i = 0; i < numPointsPerSide; i++) {
    basePoints.add(new PVector(map(i, 0, numPointsPerSide, -baseRadius, baseRadius), -baseRadius));
  }
  for (int i = 0; i < numPointsPerSide; i++) {
    basePoints.add(new PVector(baseRadius, map(i, 0, numPointsPerSide, -baseRadius, baseRadius)));
  }
  for (int i = 0; i < numPointsPerSide; i++) {
    basePoints.add(new PVector(map(i, 0, numPointsPerSide, baseRadius, -baseRadius), baseRadius));
  }
  for (int i = 0; i < numPointsPerSide; i++) {
    basePoints.add(new PVector(-baseRadius, map(i, 0, numPointsPerSide, baseRadius, -baseRadius)));
  }
}

void generateLissajousBase() {
  int numPoints = 36; // 最低限の点数を設定
  float a = 3;
  float b = 2;
  float delta = PI / 2;
  for (int i = 0; i < numPoints; i++) {
    float theta = TWO_PI * i / numPoints;
    float baseX = baseRadius * sin(a * theta + delta);
    float baseY = baseRadius * sin(b * theta);
    basePoints.add(new PVector(baseX, baseY));
  }
}

void drawBaseShape() {
  stroke(255, 0); // 半透明の白
  noFill();
  strokeWeight(0);

  beginShape();
  PVector first = basePoints.get(0);
  PVector last = basePoints.get(basePoints.size() - 1);
  curveVertex(last.x, last.y);
  for (PVector p : basePoints) {
    curveVertex(p.x, p.y);
  }
  curveVertex(first.x, first.y);
  curveVertex(basePoints.get(1).x, basePoints.get(1).y);
  endShape(CLOSE);
}
