// Utils.pde

int getClosestIndex(PVector start, ArrayList<PVector> lookup) {
  float closestDist = width * height;
  int closestIndex = 0;

  for (int i = 0; i < lookup.size(); i++) {
    float dis = PVector.dist(start, lookup.get(i));
    if (dis < closestDist) {
      closestDist = dis;
      closestIndex = i;
    }
  }
  return closestIndex;
}

int getClosestIndex(PVector start, int n, ArrayList<PVector> lookup) {
  float[] closestDist = new float[n];
  int[] closestIndex = new int[n];

  for (int i = 0; i < n; i++) {
    closestDist[i] = width * height;
    closestIndex[i] = 0;
  }

  float dis;
  float disMin = width * height, disMax = disMin * 2;

  for (int i = 0; i < lookup.size(); i++) {
    dis = PVector.dist(start, lookup.get(i));
    if (dis < disMin) {
      disMin = dis;
      closestDist[0] = dis;
      closestIndex[0] = i;
    } else if (dis > disMin && dis < disMax) {
      int index = i;
      for (int j = 0; j < n - 1; j++) {
        if (closestDist[j] < dis && closestDist[j + 1] > dis) {
          index = j + 1;
          break;
        }
      }
      for (int j = n - 1; j > 0; j--) {
        if (j == index) {
          closestDist[j] = dis;
          closestIndex[j] = i;
          break;
        } else if (j > 1) {
          closestIndex[j] = closestIndex[j - 1];
          closestDist[j] = closestDist[j - 1];
        }
      }
      disMax = closestDist[n - 1];
    }
  }

  return closestIndex[(int) random(n)];
}

int getFarthestIndexWithinDistance(PVector start, float maxDistance, ArrayList<PVector> lookup) {
  float farthestDist = 0;
  int farthestIndex = -1;

  for (int i = 0; i < lookup.size(); i++) {
    float dis = PVector.dist(start, lookup.get(i));
    if (dis <= maxDistance && dis > farthestDist) {
      farthestDist = dis;
      farthestIndex = i;
    }
  }
  return farthestIndex;
}


void drawSection(int xOffset, int yOffset, ArrayList<?> items, Drawer drawer, int width, int height) {
  pushMatrix();
  translate(xOffset, yOffset);
  scale(width / float(Constants.GRID_WIDTH), height / float(Constants.GRID_HEIGHT)); // スケール調整
  
  for (int i = 0; i < items.size(); i++) {
     float volume = 0;
     float pitch = 0;
     float harmonic = 0;     
     float entropy = 0;

     if(i < drawLineTotalFrames){
        volume = volumes[i];
        pitch = pitches[i];
        harmonic = harmonics[i];
        entropy = entropies[i];
     }
     drawer.draw(items.get(i), volume, pitch, harmonic, entropy);
  }
  //for (Object item : items) {
  //  drawer.draw(item);
  //}
  popMatrix();
}

public interface Drawer<T> {
  //void draw(T item);
  void draw(T item, float volume, float pitch , float harmonic,  float entropy);
}

class LineDrawer implements Drawer<Line> {
  public void draw(Line line, float volume, float pitch, float harmonic, float entropy) {
    line.strokeStyle();
    if (appState.lineMode == 1) line.draw();
    if (appState.lineMode == 0) line.drawSmooth(volume, pitch, harmonic, entropy);
  }
}

class PVectorDrawer implements Drawer<PVector> {
  public void draw(PVector pos, float volume, float pitch, float harmonic, float entropy) {
    strokeWeight(1);
    noFill();
    stroke(255, 255);
    point(pos.x, pos.y);
  }
}
String capitalize(String str) {
  if (str == null || str.isEmpty()) {
    return str;
  }
  return Character.toUpperCase(str.charAt(0)) + str.substring(1);
}
