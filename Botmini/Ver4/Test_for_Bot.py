import random

# ฟังก์ชันกระตุ้น (Linear Activation)
def linear(x):
    return x  

# ค่าพารามิเตอร์ที่ฝึกแล้ว
w1 = 0.55218498186502
w2 = 0.5174137488447
b = 0.96361142029463

# ฟังก์ชันทำนายผลลัพธ์
def predict(x1, x2):
    weighted_sum = x1 * w1 + x2 * w2 + b
    return linear(weighted_sum)

# ฟังก์ชันสำหรับการสร้างโจทย์การบวกเลขแบบสุ่ม
def generate_question(difficulty_level):
    # กำหนดขอบเขตตัวเลขตามระดับความยาก
    if difficulty_level == 1:
        num1 = random.randint(0, 10)   # เลขหลักหน่วย
        num2 = random.randint(0, 10)
    elif difficulty_level == 2:
        num1 = random.randint(10, 100)  # เลขหลักสิบ
        num2 = random.randint(10, 100)
    elif difficulty_level == 3:
        num1 = random.randint(100, 1000)  # เลขหลักร้อย
        num2 = random.randint(100, 1000)
    else:
        num1 = random.randint(1000, 1000000)  # เลขหลักพันล้าน
        num2 = random.randint(1000, 1000000)
    return num1, num2

# ฟังก์ชันแสดงกราฟข้อความ
def display_graph(correct, total):
    accuracy = correct / total * 100
    graph = "=" * int(accuracy / 2) + ">"  # แสดงกราฟเป็นข้อความ
    print(f"\nกราฟความแม่นยำ: {graph}")
    print(f"ความแม่นยำ: {accuracy:.2f}% จาก {total} คำถาม")

# เริ่มต้นเล่นกับบอท
def start_quiz():
    correct_answers = 0
    wrong_answers = 0
    total_questions = 0
    difficulty_level = 1  # เริ่มที่ระดับง่ายที่สุด

    # จนกว่าผู้ใช้จะตอบผิด 3 ครั้ง
    while wrong_answers < 3:
        total_questions += 1
        num1, num2 = generate_question(difficulty_level)
        print(f"\nคำถาม: {num1} + {num2} = ?")
        
        # ขอคำตอบจากผู้ใช้
        user_answer = int(input("กรุณาตอบ: "))
        
        # คำนวณคำตอบที่ถูกต้อง
        correct_answer = num1 + num2
        
        # ตรวจสอบคำตอบของผู้ใช้
        if user_answer == correct_answer:
            print("คำตอบถูกต้อง!")
            correct_answers += 1
        else:
            print(f"คำตอบผิด! คำตอบที่ถูกต้องคือ {correct_answer}")
            wrong_answers += 1
        
        # เพิ่มระดับความยากขึ้นเรื่อย ๆ
        if total_questions % 5 == 0:
            difficulty_level += 1
            print(f"เพิ่มความยากเป็นระดับ {difficulty_level}")

    # แสดงกราฟความแม่นยำ
    display_graph(correct_answers, total_questions)

# เริ่มการทดสอบ
start_quiz()
