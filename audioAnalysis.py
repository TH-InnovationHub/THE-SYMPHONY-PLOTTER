import numpy as np
import scipy.io.wavfile as wav
import pandas as pd
from scipy.signal import find_peaks
from datetime import datetime
import os
import librosa
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import sounddevice as sd

# 各特徴量の計算関数

def spectral_centroid(signal, sample_rate):
    magnitudes = np.abs(np.fft.rfft(signal))
    frequencies = np.fft.rfftfreq(len(signal), 1.0/sample_rate)
    return np.sum(frequencies * magnitudes) / np.sum(magnitudes)

def spectral_flatness(signal):
    magnitudes = np.abs(np.fft.rfft(signal))
    geometric_mean = np.exp(np.mean(np.log(magnitudes + 1e-10)))  # Avoid log(0)
    arithmetic_mean = np.mean(magnitudes)
    return geometric_mean / arithmetic_mean

def spectral_contrast(signal, sample_rate):
    S = np.abs(librosa.stft(signal))
    contrast = librosa.feature.spectral_contrast(S=S, sr=sample_rate)
    return contrast.mean(axis=1)  # 帯域ごとの平均値

def calculate_harmonic_strength(signal, sample_rate):
    magnitudes = np.abs(np.fft.rfft(signal))
    frequencies = np.fft.rfftfreq(len(signal), 1.0/sample_rate)
    
    peaks, _ = find_peaks(magnitudes, height=0)
    if len(peaks) == 0:
        return 0
    
    fundamental_freq = frequencies[peaks[0]]
    
    harmonic_strengths = []
    for i in range(2, 6):
        harmonic_freq = fundamental_freq * i
        harmonic_index = np.argmin(np.abs(frequencies - harmonic_freq))
        harmonic_strengths.append(magnitudes[harmonic_index])
    
    harmonic_strength_value = np.sum(harmonic_strengths) / np.sum(magnitudes)
    
    return harmonic_strength_value

def spectral_entropy(signal, sample_rate):
    magnitudes = np.abs(np.fft.rfft(signal))
    magnitudes = magnitudes / np.sum(magnitudes)  # 正規化
    spectral_entropy = -np.sum(magnitudes * np.log2(magnitudes + 1e-10))  # エントロピー計算
    return spectral_entropy

def tonal_density(signal):
    magnitudes = np.abs(np.fft.rfft(signal))
    density = np.sum(magnitudes > np.mean(magnitudes))  # 平均よりも強い成分の数
    return density

def process_wav(file_path, fps=30):
    sample_rate, data = wav.read(file_path)
    
    if data.ndim > 1:
        data = data.mean(axis=1)
    
    # 音源を正規化
    data = data / np.max(np.abs(data))
    
    frame_duration = 1 / fps
    frame_samples = int(frame_duration * sample_rate)
    
    features = {
        'Frame': [],
        'Volume': [],
        'Harmonic Strength': [],
        'Spectral Centroid (Hz)': [],
        'Spectral Flatness': [],
        'Spectral Contrast': [],
        'Spectral Entropy': [],
        'Tonal Density': [],
        'Pitch (Hz)': []
    }
    
    for start in range(0, len(data), frame_samples):
        frame = data[start:start + frame_samples]
        if len(frame) == frame_samples:
            volume = np.sum(np.abs(frame)) / len(frame)
            harmonic_strength_value = calculate_harmonic_strength(frame, sample_rate)
            centroid = spectral_centroid(frame, sample_rate)
            flatness = spectral_flatness(frame)
            contrast = spectral_contrast(frame, sample_rate)
            entropy = spectral_entropy(frame, sample_rate)
            density = tonal_density(frame)
            pitch = find_peaks(np.abs(np.fft.rfft(frame)), height=0)[0][0] * sample_rate / len(frame)
            
            features['Frame'].append(start // frame_samples)
            features['Volume'].append(volume)
            features['Harmonic Strength'].append(harmonic_strength_value)
            features['Spectral Centroid (Hz)'].append(centroid)
            features['Spectral Flatness'].append(flatness)
            features['Spectral Contrast'].append(contrast.mean())  # 複数の帯域の平均をとる
            features['Spectral Entropy'].append(entropy)
            features['Tonal Density'].append(density)
            features['Pitch (Hz)'].append(pitch)
    
    df = pd.DataFrame(features)
    return df, sample_rate, data  # 正規化後のデータを返す

# ファイル名を生成する関数

def generate_output_filename(input_file):
    base_name = os.path.splitext(os.path.basename(input_file))[0]
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    return f"{base_name}_{timestamp}.csv"

# リアルタイムでの可視化

def animate(i, df, lines):
    frame = i
    if frame >= len(df):
        return

    for line, feature_name in zip(lines, df.columns[1:]):
        line.set_data(df['Frame'][:frame], df[feature_name][:frame])
    
    return lines

def visualize_features_realtime(df, sample_rate, data, fps=30):
    fig, axs = plt.subplots(4, 2, figsize=(14, 10))
    fig.subplots_adjust(hspace=0.5)
    
    feature_names = ['Volume', 'Harmonic Strength', 'Spectral Centroid (Hz)', 'Spectral Flatness', 
                     'Spectral Contrast', 'Spectral Entropy', 'Tonal Density', 'Pitch (Hz)']
    
    lines = []
    for ax, feature_name in zip(axs.flat, feature_names):
        ax.set_title(feature_name)
        ax.set_xlim(0, len(df))
        ax.set_ylim(df[feature_name].min(), df[feature_name].max())
        line, = ax.plot([], [], lw=2)
        lines.append(line)
    
    frame_interval = 1000 / fps  # フレームごとの間隔をミリ秒で計算
    ani = animation.FuncAnimation(fig, animate, frames=len(df), fargs=(df, lines), interval=frame_interval, blit=True)
    
    # 音声を再生しながら可視化
    sd.play(data, sample_rate)
    
    plt.show()
    sd.wait()

# 使用例

file_path = 'romio.wav'
output_filename = generate_output_filename(file_path)

# ステップ1: 特徴量を計算してCSVに保存
df, sample_rate, data = process_wav(file_path)
df = df[['Frame', 'Volume', 'Harmonic Strength', 'Spectral Centroid (Hz)', 'Spectral Flatness', 
         'Spectral Contrast', 'Spectral Entropy', 'Tonal Density', 'Pitch (Hz)']]  # 列の順番を指定
df.to_csv(output_filename, index=False)
print(f"Features saved to {output_filename}")

# ステップ2: 保存されたデータを読み込み、リアルタイムで可視化
df = pd.read_csv(output_filename)
visualize_features_realtime(df, sample_rate, data, fps=30)
