import os
import subprocess

# เพิ่ม path ที่เก็บ ffmpeg.exe
os.environ["PATH"] += os.pathsep + r"C:\Users\Administrator\Desktop\ffmpeg-master-latest-win64-gpl-shared\bin"

# ทดสอบการใช้งาน ffmpeg
subprocess.run(["ffmpeg", "-version"])
