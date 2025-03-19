import yt_dlp

# ใส่ URL ของ YouTube ที่ต้องการดาวน์โหลด
url = 'https://youtu.be/HFwYA86t-d4?si=lhR-klfMbD7O_IB9'  # เปลี่ยน URL นี้เป็นของจริง

options = {
    'format': 'bestaudio/best',  # เลือกเสียงที่ดีที่สุด
    'extractaudio': True,  # กำหนดให้ดาวน์โหลดเป็นไฟล์เสียง
    'audioquality': 1,  # คุณภาพเสียงสูงสุด
    'outtmpl': '%(title)s.%(ext)s',  # ชื่อไฟล์ที่ดาวน์โหลด
    'postprocessors': [{  # แปลงไฟล์เสียงให้เป็น MP3
        'key': 'FFmpegExtractAudio',
        'preferredcodec': 'mp3',
        'preferredquality': '192',  # คุณภาพของ MP3
    }],
    'ffmpeg_location': r"C:\Users\Administrator\Desktop\ffmpeg-master-latest-win64-gpl-shared\bin",  # เส้นทางที่เก็บ ffmpeg
    
}

# ดาวน์โหลดไฟล์
with yt_dlp.YoutubeDL(options) as ydl:
    ydl.download([url])
