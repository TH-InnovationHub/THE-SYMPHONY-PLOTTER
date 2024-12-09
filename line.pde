// Line.pde

class Line {
  PVector start, end, middle;
  float sw;
  float baseSw = random(0.1, 0.25);
  float alpha = 255;
  color c;
  float totalDistance;

  Line(PVector start, PVector end) {
    this.start = start;
    this.end = end;
    //setMiddle(0);
    sw = baseSw;
    totalDistance = PVector.dist(start, end);
  }

  void setMiddle(float pitch, float harmonic) {
    //float dis = PVector.dist(start, end) * random(0.25, 0.75);
    float h = harmonic + 1;
    h = pow(h, 2);
     float dis = PVector.dist(start, end) * map(h, 1.0, 2.0, 0.25, 0.75 * appState.harmonicFactor);
     
     //float dis = PVector.dist(start, end) * map(harmonic, 0.0, 0.4, 0.25, 0.75)  * appState.harmonicFactor;

    float angle = atan2(end.y - start.y, end.x - start.x);
    //float randomAngle = random(-PI / 6, PI / 6);
    float randomAngle = map(pitch, 0.0, 10000.0, -PI/3, PI/3);
    //float randomAngle =  PI / 6 * (volume + 0.1) ;

    float x = start.x + cos(angle + randomAngle) * dis;
    float y = start.y + sin(angle + randomAngle) * dis;
    middle = new PVector(x, y);
  }

  void setStrokeWeightAndColor(color[] img, int w, int h) {
    color c1 = img[(int)start.y * w + (int)start.x];
    color c2 = img[(int)end.y * w + (int)end.x];
    color c_ = lerpColor(c1, c2, 0.5);
    if (middle != null) {
      int x = (int) constrain(middle.x, 0, w - 1);
      int y = (int) constrain(middle.y, 0, h - 1);
      color c3 = img[y * w + x];
      c_ = lerpColor(c_, c3, 0.25);
    }
    if (appState.colorLines) {
      c = color(red(c_), green(c_), blue(c_), alpha);
    } else {
      c = color(255, alpha);
    }
    sw = baseSw * appState.lineWeight;
  }

  void updateStyle(float newAlpha, float newWeight, boolean newColorLines) {
    alpha = newAlpha;
    sw = baseSw * newWeight;
    if (newColorLines) {
      c = color(red(c), green(c), blue(c), alpha);
    } else {
      c = color(255, alpha);
    }
  }

  void strokeStyle() {
    stroke(c);
    strokeWeight(sw);
  }

  void draw() {
    line(start.x, start.y, end.x, end.y);
  }

  void drawSmooth(float volume, float pitch, float harmonic, float entropy) {
    if (middle == null) setMiddle(pitch, harmonic);
    noFill();
    
    //curveTightness(tmpT);
    //curveTightness(appState.curveTightness);
    
    curveTightness(entropy * -appState.curveTightness);
    
    //curveTightness(-1.0);

    beginShape();
    curveVertex(start.x, start.y);
    curveVertex(start.x, start.y);
    curveVertex(middle.x  + volume * appState.volumeShiftValueX, middle.y + volume * appState.volumeShiftValueY);
    curveVertex(end.x, end.y);
    curveVertex(end.x, end.y);
    endShape();
  }
  
  
  PVector getPoint(float t) {
    if (middle == null) setMiddle(0, 0);
    float total = PVector.dist(start, middle) + PVector.dist(middle, end);
    if (t <= PVector.dist(start, middle) / total) {
      return PVector.lerp(start, middle, t * total / PVector.dist(start, middle));
    } else {
      return PVector.lerp(middle, end, (t * total - PVector.dist(start, middle)) / PVector.dist(middle, end));
    }
  }
}



class AudioReactiveLine extends Line {
  float progress = 0;
  
  AudioReactiveLine(PVector start, PVector end) {
    super(start, end);
  }
  
  void drawProgressInShape(float globalProgress) {
    float lineProgress = min(1, max(0, (globalProgress - progress) / 0.01)); // 0.01は各ラインの描画時間（調整可能）
    PVector currentEnd = PVector.lerp(start, end, lineProgress);
    if (appState.lineMode == 0) {
      // スムーズモード
      PVector currentMiddle = PVector.lerp(start, middle, lineProgress);
      curveVertex(start.x, start.y);
      curveVertex(currentMiddle.x, currentMiddle.y);
      curveVertex(currentEnd.x, currentEnd.y);
    } else {
      // 直線モード
      vertex(currentEnd.x, currentEnd.y);
    }
  }
}
