// ImageProcessing.pde

void loadImageAndConvertToGray(String path) {
  try {
    appState.inputImage = loadImage(Constants.IMAGE_FOLDER + path);
    if (appState.inputImage == null) {
      throw new RuntimeException("Image loading failed.");
    }
    appState.grayImage = createImage(appState.inputImage.width, appState.inputImage.height, RGB);
    appState.inputImage.loadPixels();
    appState.grayImage.loadPixels();
    for (int i = 0; i < appState.inputImage.pixels.length; i++) {
      float avg = (red(appState.inputImage.pixels[i]) + green(appState.inputImage.pixels[i]) + blue(appState.inputImage.pixels[i])) / 3;
      appState.grayImage.pixels[i] = color(avg);
    }
    //println("input",appState.grayImage);
    //println("gray",appState.inputImage);

    appState.grayImage = appState.inputImage;
    appState.grayImage.updatePixels();
    //appState.inputImage.updatePixels();
  } catch (Exception e) {
    println("Error loading image: " + e.getMessage());
    // Optional: Display an error message on the screen or revert to a default image
  }
}

PImage applySobelFilter(PImage img) {
  PImage result = createImage(img.width, img.height, RGB);
  img.loadPixels();
  result.loadPixels();
  int w = img.width;
  int h = img.height;

  for (int x = 1; x < w-1; x++) {
    for (int y = 1; y < h-1; y++) {
      float gx = (-1 * brightness(img.pixels[(x-1) + (y-1) * w])) + (-2 * brightness(img.pixels[(x-1) + y * w])) + (-1 * brightness(img.pixels[(x-1) + (y+1) * w])) +
                 (1 * brightness(img.pixels[(x+1) + (y-1) * w])) + (2 * brightness(img.pixels[(x+1) + y * w])) + (1 * brightness(img.pixels[(x+1) + (y+1) * w]));
      float gy = (-1 * brightness(img.pixels[(x-1) + (y-1) * w])) + (-2 * brightness(img.pixels[x + (y-1) * w])) + (-1 * brightness(img.pixels[(x+1) + (y-1) * w])) +
                 (1 * brightness(img.pixels[(x-1) + (y+1) * w])) + (2 * brightness(img.pixels[x + (y+1) * w])) + (1 * brightness(img.pixels[(x+1) + (y+1) * w]));
      float g = sqrt(gx * gx + gy * gy);
      result.pixels[x + y * w] = color(g);
    }
  }
  result.updatePixels();
  return result;
}

PImage applyGaussianBlur(PImage img, int radius) {
  PImage result = img.copy();
  result.filter(BLUR, radius);
  return result;
}
