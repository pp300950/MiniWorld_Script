import numpy as np
import sounddevice as sd
import time

# ฟังก์ชันสร้างคลื่นเสียง
def generate_wave(frequency, duration, sample_rate=44100):
    t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
    wave = 0.5 * np.sin(2 * np.pi * frequency * t)  # สร้างคลื่นเสียงแบบ sine wave
    return wave

# ฟังก์ชันเล่นโน้ตตามเวลาที่กำหนด
def play_notes(sequence):
    # ความถี่ของโน้ตแต่ละตัว (Hz)
    notes = {
        "โด": 261.63,    # C4
        "เร": 293.66,    # D4
        "มี": 329.63,    # E4
        "ฟา": 349.23,    # F4
        "ซอล": 392.00,   # G4
        "ลา": 440.00,    # A4
        "ที": 493.88,    # B4
        "โดสูง": 523.25, # C5
        "เรสูง": 587.33  # D5
    }

    # สร้างคลื่นเสียงทั้งหมดที่จะเล่น
    full_wave = np.array([])  # คลื่นเสียงทั้งหมดที่รวมกัน
    for time_point, note in sequence:
        frequency = notes.get(note)
        if frequency:
            print(f"{time_point}s: {note}")
            wave = generate_wave(frequency, 0.5)  # สร้างคลื่นเสียง 0.5 วินาที
            full_wave = np.concatenate((full_wave, wave))  # รวมคลื่นเสียงทั้งหมด

    try:
        sd.play(full_wave)  # เล่นคลื่นเสียงทั้งหมดพร้อมกัน
        sd.wait()  # รอจนกว่าเสียงทั้งหมดจะเล่นเสร็จ
    except Exception as e:
        print(f"Error playing sound: {e}")

def process_input(input_string):
    sequence = []
    # แยกอินพุตที่เป็น string และแปลงเป็นลิสต์
    parts = input_string.split(" | ")
    
    # แยกเวลาและโน้ตในแต่ละส่วน
    for part in parts:
        # ใช้ split ที่แยกแค่ครั้งเดียว
        time_point, note = part.split(":", 1)
        sequence.append((float(time_point[:-1]), note.strip()))  # แปลงเวลาเป็น float และเพิ่มโน้ต
     
    # เรียกใช้ฟังก์ชันเล่นโน้ต
    play_notes(sequence)

# ตัวอย่างการป้อนข้อมูล
input_string = ""
process_input(input_string)
