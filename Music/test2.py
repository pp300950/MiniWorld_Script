import wave
import struct

def process_wav(filename):
    with wave.open(filename, "rb") as wav_file:
        num_frames = wav_file.getnframes()  # จำนวน sample ทั้งหมด
        audio_data = wav_file.readframes(num_frames)  # อ่านข้อมูลทั้งหมด
        
        print(f"Expected size: {num_frames * 2} bytes, Actual size: {len(audio_data)} bytes")

        if len(audio_data) != num_frames * 2:
            raise ValueError("Audio data size mismatch!")

        samples = struct.unpack(f"{num_frames}h", audio_data)
    return samples

process_wav("song.wav")
