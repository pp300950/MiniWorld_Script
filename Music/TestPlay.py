import numpy as np
import sounddevice as sd

# ทดสอบการเล่นเสียง
frequency = 261.63  # โน้ต C4 (โด)
duration = 1.0  # 1 วินาที

# สร้างคลื่นเสียง
t = np.linspace(0, duration, int(44100 * duration), endpoint=False)
wave = 0.5 * np.sin(2 * np.pi * frequency * t)  # สร้างคลื่นเสียงแบบ sine wave

# เล่นคลื่นเสียง
sd.play(wave)
sd.wait()  # รอจนกว่าเสียงจะเล่นเสร็จ
