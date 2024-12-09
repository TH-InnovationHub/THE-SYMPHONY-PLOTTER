// AudioWavePoint.pde

PVector audioWavePoint;
float audioPointProgress = 0;
float audioPointSpeed;

void setupAudioWavePoint() {
  audioWavePoint = new PVector(0, 0);
  calculateAudioPointSpeed();
}

void calculateAudioPointSpeed() {
 audioPointSpeed = 1; // デフォルト値
}

void updateAudioWavePoint() {
 
}

void drawAudioWavePoint() {
  fill(255, 0, 0);
  noStroke();
  ellipse(audioWavePoint.x, audioWavePoint.y, 5, 5);
}

PVector getPointOnCurve(float t) {
  if (interpolatedPoints.size() < 4) {
    return new PVector(0, 0); // または適切なデフォルト位置
  }
  
  int numCurves = interpolatedPoints.size() - 3;
  float segment = t * numCurves;
  int i = floor(segment);
  float u = segment - i;
  
  i = constrain(i, 0, interpolatedPoints.size() - 4);
  
  PVector p0 = interpolatedPoints.get(i);
  PVector p1 = interpolatedPoints.get(i + 1);
  PVector p2 = interpolatedPoints.get(i + 2);
  PVector p3 = interpolatedPoints.get(i + 3);
  
  float x = curvePoint(p0.x, p1.x, p2.x, p3.x, u);
  float y = curvePoint(p0.y, p1.y, p2.y, p3.y, u);
  
  return new PVector(x, y);
}

PVector getTangentAtPoint(float t) {
  PVector point = getPointOnCurve(t);
  PVector nextPoint = getPointOnCurve((t + 0.01) % 1);
  return PVector.sub(nextPoint, point).normalize();
}

float getTotalCurveLength() {
  float totalLength = 0;
  for (int i = 0; i < interpolatedPoints.size() - 1; i++) {
    PVector p1 = interpolatedPoints.get(i);
    PVector p2 = interpolatedPoints.get((i + 1) % interpolatedPoints.size());
    totalLength += PVector.dist(p1, p2);
  }
  return totalLength;
}
