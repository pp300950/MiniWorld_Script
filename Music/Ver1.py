import os
import wave
import struct
import subprocess
import yt_dlp
import numpy as np  # ใช้ numpy สำหรับการคำนวณ FFT

# ค่าความถี่ของโน้ตดนตรี
NOTE_FREQS = {
    "โด": 261.63, "เร": 293.66, "มี": 329.63, "ฟา": 349.23,
    "ซอล": 392.00, "ลา": 440.00, "ที": 493.88,
    "โดสูง": 523.25, "เรสูง": 587.33  # แก้ "เลสูง" เป็น "เรสูง"
}

# ฟังก์ชันคำนวณโน้ตจากความถี่
def get_note_from_freq(freq):
    closest_note = min(NOTE_FREQS, key=lambda note: abs(NOTE_FREQS[note] - freq))
    return closest_note

# ดาวน์โหลด YouTube เป็น MP3
def download_youtube_audio(url, output_mp3="song.mp3"):
    ydl_opts = {
        'format': 'bestaudio/best',
        'extractaudio': True,
        'audioquality': 1,
        'outtmpl': output_mp3,
        'postprocessors': [{
            'key': 'FFmpegExtractAudio',
            'preferredcodec': 'mp3',
            'preferredquality': '192',
        }],
        'ffmpeg_location': r"C:\Users\Administrator\Desktop\ffmpeg-master-latest-win64-gpl-shared\bin",
    }

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        ydl.download([url])

    return output_mp3  # ✅ Return ชื่อไฟล์ที่ถูกดาวน์โหลด

# แปลง MP3 เป็น WAV
def convert_mp3_to_wav(input_mp3, output_wav="song.wav"):
    ffmpeg_path = r"C:\Users\Administrator\Desktop\ffmpeg-master-latest-win64-gpl-shared\bin\ffmpeg"

    if not os.path.exists(input_mp3):  # ✅ ตรวจสอบไฟล์ให้ถูกต้อง
        raise FileNotFoundError(f"ไฟล์ {input_mp3} ไม่พบในระบบ")

    command = [ffmpeg_path, '-i', input_mp3, '-ar', '44100', '-ac', '1', '-y', output_wav]
    try:
        subprocess.run(command, check=True)  # ✅ ใช้ check=True
    except subprocess.CalledProcessError as e:
        print(f"❌ เกิดข้อผิดพลาดในการแปลง MP3: {e}")

# วิเคราะห์ไฟล์ WAV และคืนค่าเป็นสตริงเดียว (คั่นด้วย |)
def process_wav(file_path):
    with wave.open(file_path, 'rb') as wav_file:
        sample_rate = wav_file.getframerate()
        num_frames = wav_file.getnframes()
        num_channels = wav_file.getnchannels()
        sample_width = wav_file.getsampwidth()
        
        audio_data = wav_file.readframes(num_frames)

        format_str = f"{num_frames * num_channels}h"
        samples = struct.unpack(format_str, audio_data)

        if num_channels == 2:
            samples = np.array(samples).reshape(-1, 2)
            samples = samples.mean(axis=1).astype(np.int16)

        result = []
        window_size = sample_rate // 10  # วิเคราะห์เป็นช่วงละ 0.1 วินาที
        
        for i in range(0, len(samples), window_size):
            window = samples[i:i + window_size]
            if len(window) < window_size:
                break

            # ใช้ FFT เพื่อหาความถี่
            freqs = np.fft.rfftfreq(len(window), 1 / sample_rate)
            fft_vals = np.abs(np.fft.rfft(window))
            peak_freq = freqs[np.argmax(fft_vals)]
            
            if peak_freq < 20 or peak_freq > 5000:  # ✅ กรอง noise
                continue  

            # คำนวณโน้ตที่ใกล้เคียง
            note = get_note_from_freq(abs(peak_freq))

            # บันทึกค่า (เวลา/โน้ต)
            timestamp = round(i / sample_rate, 2)
            result.append(f"{timestamp}s: {note}")
    
    return " | ".join(result)  # ✅ เปลี่ยนเป็นสตริงเดียวคั่นด้วย "|"

# บันทึกผลลงไฟล์ (ข้อมูลทั้งหมดอยู่บรรทัดเดียว)
def save_to_txt(data, output_file):
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(data)  # ✅ บันทึกเป็นบรรทัดเดียว

# ส่วนหลักของโปรแกรม
youtube_url = 'https://youtu.be/HFwYA86t-d4?si=lhR-klfMbD7O_IB9'

# 1. ดาวน์โหลด MP3
mp3_file = download_youtube_audio(youtube_url)

# 2. แปลงเป็น WAV
convert_mp3_to_wav(mp3_file, output_wav="song.wav")

# 3. วิเคราะห์ไฟล์เสียง
notes_data = process_wav("song.wav")

# 4. บันทึกเป็น TXT
save_to_txt(notes_data, "music_notes.txt")

print("✅ แปลงเสร็จแล้ว! ดูไฟล์ music_notes.txt")
