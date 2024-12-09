//AudioProcessor
import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer player;
float totalFrames;
float progress;
float volumeAudio;
float scaleFactor = 0; // スケールファクター
String audioFilePath = "input/audio/free-orchestra.mp3"; // オーディオファイルのパスを正しく設定

void setupAudio() {
  println("setupAudio() called"); // デバッグメッセージ
  minim = new Minim(this);

  try {
    // オーディオファイルをロード
    player = minim.loadFile(audioFilePath, 2048);
    if (player == null) {
      throw new Exception("Error: Could not load audio file");
    }

    // 曲の長さに基づいてフレーム数を計算
    totalFrames = player.length() / (1000.0 / 30.0); // 60フレーム/秒で計算
    if (totalFrames == 0) {
      throw new ArithmeticException("Error: totalFrames is zero");
    }
  } catch (Exception e) {
    println(e.getMessage());
    exit();
  }
}


void updateAudio() {
  // playerがnullでないことを確認
  if (player != null) {
    // オーディオ再生位置に基づいて描画角度を計算
    progress = (float)player.position() / player.length();

    // オーディオの現在のボリュームを取得
    volumeAudio = player.mix.level() * scaleFactor; // スケールを調整して振れ幅を大きくする

    // 再生が終了したらリセット
    if (player.position() >= player.length()) {
      player.rewind();
      player.play();
    }
  } else {
    println("Error: Audio player is not initialized");
  }
}
void pauseAndResetAudio() {
  if (player != null) {
    player.pause();
    player.cue(0); // 再生位置を最初に戻す
  }
}


void stopAudio() {
  if (player != null) {
    player.close();
  }
  minim.stop();
}
