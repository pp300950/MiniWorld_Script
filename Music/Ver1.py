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
    "โดสูง": 523.25, "เลสูง": 587.33
}

# ฟังก์ชันคำนวณโน้ตจากความถี่
def get_note_from_freq(freq):
    closest_note = min(NOTE_FREQS, key=lambda note: abs(NOTE_FREQS[note] - freq))
    return closest_note

# ดาวน์โหลด YouTube เป็น MP3
def download_youtube_audio(url, output_mp3="song"):
    ydl_opts = {
        'format': 'bestaudio/best',  # เลือกเสียงที่ดีที่สุด
        'extractaudio': True,  # กำหนดให้ดาวน์โหลดเป็นไฟล์เสียง
        'audioquality': 1,  # คุณภาพเสียงสูงสุด
        'outtmpl': output_mp3,  # ใช้ชื่อไฟล์ที่กำหนดไว้แทน
        'postprocessors': [{  # แปลงไฟล์เสียงให้เป็น MP3
            'key': 'FFmpegExtractAudio',
            'preferredcodec': 'mp3',
            'preferredquality': '192',  # คุณภาพของ MP3
        }],
        'ffmpeg_location': r"C:\Users\Administrator\Desktop\ffmpeg-master-latest-win64-gpl-shared\bin",  # เส้นทางที่เก็บ ffmpeg
    }

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        ydl.download([url])


# แปลง MP3 เป็น WAV
def convert_mp3_to_wav(input_mp3, output_wav="song.wav"):
    ffmpeg_path = r"C:\Users\Administrator\Desktop\ffmpeg-master-latest-win64-gpl-shared\bin\ffmpeg"
    command = [ffmpeg_path, '-i', input_mp3, output_wav, '-y']
    subprocess.run(command)
    
    if not mp3_file or not output_wav:
        raise ValueError("ไฟล์ mp3 หรือ output_wav ไม่ถูกต้อง")

    # ตรวจสอบว่ามีไฟล์ mp3 จริง
    if not os.path.exists(mp3_file):
        raise FileNotFoundError(f"ไฟล์ {mp3_file} ไม่พบในระบบ")

    # สร้างคำสั่งสำหรับการแปลง
    command = [
        'ffmpeg',  # ใช้ ffmpeg ในการแปลงไฟล์
        '-i', mp3_file,  # ไฟล์ที่ต้องการแปลง
        output_wav  # ไฟล์เป้าหมาย
    ]
    
    # ตรวจสอบให้แน่ใจว่า command ไม่เป็น None
    if command:
        print(f"กำลังรันคำสั่ง: {' '.join(command)}")  # พิมพ์คำสั่งที่รันเพื่อดีบัก
        subprocess.run(command)
    else:
        raise ValueError("คำสั่งสำหรับ ffmpeg ไม่ถูกต้อง")

# วิเคราะห์เสียงจากไฟล์ WAV
def process_wav(file_path):
    with wave.open(file_path, 'rb') as wav_file:
        sample_rate = wav_file.getframerate()
        num_frames = wav_file.getnframes()
        audio_data = wav_file.readframes(num_frames)

        # แปลงข้อมูลเสียงเป็นตัวเลข
        samples = struct.unpack(f"{num_frames}h", audio_data)
        
        result = []
        window_size = sample_rate // 10  # วิเคราะห์เป็นช่วงละ 0.1 วินาที
        
        # ใช้ FFT เพื่อหาค่าความถี่ที่แม่นยำกว่า
        for i in range(0, len(samples), window_size):
            window = samples[i:i + window_size]
            if len(window) < window_size:
                break

            # ใช้ FFT เพื่อหาความถี่
            freqs = np.fft.fftfreq(len(window), 1 / sample_rate)
            fft_vals = np.abs(np.fft.fft(window))
            peak_freq = freqs[np.argmax(fft_vals)]  # ค่าความถี่ที่มีค่าสูงสุด
            
            # คำนวณโน้ตที่ใกล้เคียง
            note = get_note_from_freq(abs(peak_freq))

            # บันทึกค่า (เวลา/โน้ต)
            timestamp = round(i / sample_rate, 2)  # แปลงเป็นวินาที
            result.append(f"{timestamp}s: {note}")
    
    return result

# บันทึกผลลงไฟล์
def save_to_txt(data, output_file):
    with open(output_file, "w", encoding="utf-8") as f:
        for line in data:
            f.write(line + "\n")

# ส่วนหลักของโปรแกรม
youtube_url = 'https://youtu.be/HFwYA86t-d4?si=lhR-klfMbD7O_IB9'  # URL ของ YouTube

# 1. ดาวน์โหลด MP3 และรับชื่อไฟล์ที่ดาวน์โหลด
mp3_file = download_youtube_audio(youtube_url)

# 2. แปลงเป็น WAV
# เรียกใช้ฟังก์ชันแปลงไฟล์
convert_mp3_to_wav(mp3_file, output_wav="song.wave")  # ตั้งชื่อไฟล์ที่ต้องการที่นี่


# 3. วิเคราะห์ไฟล์เสียง
notes_data = process_wav(f"{mp3_file.replace('.mp3', '.wav')}")

# 4. บันทึกเป็น TXT
save_to_txt(notes_data, "music_notes.txt")

print("✅ แปลงเสร็จแล้ว! ดูไฟล์ music_notes.txt")
