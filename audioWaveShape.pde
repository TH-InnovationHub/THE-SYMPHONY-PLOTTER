//AudioWaveShape.pde
ArrayList<PVector> points;
ArrayList<PVector> interpolatedPoints; // 近似直線を保存するリスト

void setupWaveShape() {
  points = new ArrayList<PVector>();
  interpolatedPoints = new ArrayList<PVector>();
  generateInterpolatedShape();
}

void generateInterpolatedShape() {
  interpolatedPoints.clear();
  ArrayList<PVector> allPoints = new ArrayList<PVector>();
  int numSteps = 100; // ステップ数を増やす
  for (int i = 0; i < basePoints.size(); i++) {
    PVector p0 = basePoints.get((i - 1 + basePoints.size()) % basePoints.size());
    PVector p1 = basePoints.get((i + basePoints.size()) % basePoints.size());
    PVector p2 = basePoints.get((i + 1 + basePoints.size()) % basePoints.size());
    PVector p3 = basePoints.get((i + 2 + basePoints.size()) % basePoints.size());

    for (int j = 0; j < numSteps; j++) {
      float t = j / (float) numSteps;
      float tt = t * t;
      float ttt = tt * t;

      float q0 = -ttt + 2.0 * tt - t;
      float q1 = 3.0 * ttt - 5.0 * tt + 2.0;
      float q2 = -3.0 * ttt + 4.0 * tt + t;
      float q3 = ttt - tt;

      float tx = 0.5 * (p0.x * q0 + p1.x * q1 + p2.x * q2 + p3.x * q3);
      float ty = 0.5 * (p0.y * q0 + p1.y * q1 + p2.y * q2 + p3.y * q3);

      allPoints.add(new PVector(tx, ty));
    }
  }
  
  float totalLength = 0;
  for (int i = 0; i < allPoints.size() - 1; i++) {
    totalLength += PVector.dist(allPoints.get(i), allPoints.get(i + 1));
  }

  if (totalLength == 0) return;

  float segmentLength = totalLength / totalFrames;
  float currentLength = 0;
  interpolatedPoints.add(allPoints.get(0));

  for (int i = 1; i < allPoints.size(); i++) {
    float dist = PVector.dist(allPoints.get(i - 1), allPoints.get(i));
    if (currentLength + dist >= segmentLength) {
      float t = (segmentLength - currentLength) / dist;
      float newX = lerp(allPoints.get(i - 1).x, allPoints.get(i).x, t);
      float newY = lerp(allPoints.get(i - 1).y, allPoints.get(i).y, t);
      interpolatedPoints.add(new PVector(newX, newY));
      currentLength = 0;
    } else {
      currentLength += dist;
    }
  }
}

float lastProgress = 0;

void drawWaveOnShape() {
  float startProgress = lastProgress;
  float endProgress = progress;
  
  // progressが0に戻った場合（曲の最後から最初に戻った場合）の処理
  if (endProgress < startProgress) {
    endProgress += 1.0;
  }
  
  int totalPoints = interpolatedPoints.size();
  float progressStep = 1.0 / totalPoints; // 1ステップあたりのprogress
  
  for (float p = startProgress; p <= endProgress; p += progressStep) {
    float cyclicProgress = p % 1.0;
    int currentIdx = floor(cyclicProgress * totalPoints);
    int nextIdx = (currentIdx + 1) % totalPoints;
    
    PVector base = interpolatedPoints.get(currentIdx);
    PVector nextBase = interpolatedPoints.get(nextIdx);
    
    PVector direction = PVector.sub(nextBase, base).normalize();
    PVector normal = new PVector(-direction.y, direction.x);
    float x = base.x + normal.x * volumeAudio * scaleFactor;
    float y = base.y + normal.y * volumeAudio * scaleFactor;
    points.add(new PVector(x, y));
  }
  
  // 図形の部分を描画
  stroke(100, 255);
  blendMode(ADD);
  strokeWeight(0.5);
  strokeCap(ROUND);
  blendMode(ADD);
  noFill();
  beginShape();
  for (PVector p : points) {
    curveVertex(p.x, p.y);
  }
  endShape();
  
  // オプション: 点の数が多くなりすぎないようにする
  int maxPoints = totalPoints * 2;
  while (points.size() > maxPoints) {
    points.remove(0);
  }
  
  lastProgress = progress;
}
