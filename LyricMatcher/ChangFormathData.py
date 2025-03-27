import re
import tkinter as tk
from tkinter import messagebox

# ฟังก์ชันล้างข้อความ, คัดลอก และล้างช่องป้อนข้อความ
def clean_and_copy():
    text = text_input.get("1.0", tk.END)  # ดึงข้อความจาก Text Widget
    cleaned_text = re.sub(r'\s+', ' ', text).strip()  # ลบช่องว่างและเว้นบรรทัด
    if cleaned_text:  # ตรวจสอบว่ามีข้อความให้คัดลอกหรือไม่
        root.clipboard_clear()
        root.clipboard_append(cleaned_text)
        root.update_idletasks()  # อัปเดตคลิปบอร์ด
        text_input.delete("1.0", tk.END)  # ล้างข้อความใน Text Widget
        messagebox.showinfo("Success", "ข้อความถูกคัดลอกแล้วและถูกล้างออก!")

# ฟังก์ชันวางข้อความ (Ctrl+V หรือกดปุ่ม "Paste")
def paste_text(event=None):
    try:
        text_input.insert(tk.INSERT, root.clipboard_get())  # วางข้อความที่ตำแหน่งเคอร์เซอร์
    except tk.TclError:
        pass  # ถ้าไม่มีข้อมูลในคลิปบอร์ด ให้ข้ามไป

# สร้างหน้าต่างหลัก
root = tk.Tk()
root.title("Text Cleaner")
root.geometry("400x300")

# ส่วน UI
text_input = tk.Text(root, height=10, width=50)
text_input.pack(pady=10)

# ปุ่มล้างและคัดลอกข้อความ
clean_button = tk.Button(root, text="Clean & Copy", command=clean_and_copy)
clean_button.pack(pady=5)

# ปุ่มวางข้อความจากคลิปบอร์ด
paste_button = tk.Button(root, text="Paste", command=paste_text)
paste_button.pack(pady=5)

# Bind Ctrl+V ให้สามารถวางข้อความได้
root.bind('<Control-v>', paste_text)

# เริ่มการทำงานของ GUI
root.mainloop()
