import random

# ฟังก์ชันกระตุ้น (Linear Activation)
def linear(x):
    return x  

# ค่าพารามิเตอร์ที่ฝึกแล้ว
w1=     0.4972227467934
w2=     0.49850404146627
b=      0.0030442658154439

# ฟังก์ชันทำนายผลลัพธ์
def predict(x1, x2):
    weighted_sum = x1 * w1 + x2 * w2 + b
    return linear(weighted_sum)

# ฟังก์ชันสำหรับการสร้างโจทย์การบวกเลขแบบสุ่ม
def generate_question(difficulty_level=1):
    if difficulty_level == 1:
        num1 = random.randint(0, 10)
        num2 = random.randint(0, 10)
    elif difficulty_level == 2:
        num1 = random.randint(10, 100)
        num2 = random.randint(10, 100)
    elif difficulty_level == 3:
        num1 = random.randint(100, 1000)
        num2 = random.randint(100, 1000)
    else:
        num1 = random.randint(1, 1000000)
        num2 = random.randint(1, 1000000)
    return num1, num2
# ฟังก์ชันทดสอบความสามารถของบอท
def test_bot_capability():
    correct_answers = 0
    wrong_answers = 0
    total_questions = 1000  # จำนวนรอบที่ต้องการให้ทำ
    max_value = 50
    difficulty_level = 1  # เริ่มต้นระดับความยาก

    print("\nเริ่มการทดสอบความสามารถของบอท!\n")
    print("=" * 40)

    for i in range(1, total_questions + 1):
        # สุ่มตัวเลขสองตัวโดยเพิ่มระดับความยาก
        num1 = random.randint(1, max_value * difficulty_level)
        num2 = random.randint(1, max_value * difficulty_level)

        correct_answer = num1 + num2

        # การปรับสเกลตัวเลขเป็นค่าระหว่าง 0 ถึง 1 เพื่อการทำนาย
        x1, x2 = num1 / (max_value * difficulty_level), num2 / (max_value * difficulty_level)
        predicted_answer = predict(x1, x2) * (2 * max_value * difficulty_level)

        # ตรวจสอบว่าคำตอบที่ทำนายถูกต้องหรือไม่
        if round(predicted_answer) == correct_answer:
            correct_answers += 1
            result = "[ถูกต้อง]"
        else:
            wrong_answers += 1
            result = f"[ผิด] คำตอบที่ถูกต้องคือ {correct_answer}"

        # แสดงผลลัพธ์
        print(f"โจทย์ {i}: {num1} + {num2} = {round(predicted_answer)} --> {result}")

        # หยุดลูปถ้าตอบผิดครบ 3 ครั้ง
        if wrong_answers >= 3:
            print("\n[การทดสอบสิ้นสุด: บอทตอบผิดครบ 3 ครั้ง]\n")
            break

        # เพิ่มระดับความยากทุกๆ 5 ข้อ โดยทวีคูณ
        if i % 5 == 0:
            difficulty_level *= 2  # ทวีคูณความยาก
            print("\nเพิ่มระดับความยากแบบทวีคูณ!\n")
            print("-" * 40)

    # คำนวณค่าความแม่นยำโดยใช้ total_questions เป็นฐาน
    accuracy = (correct_answers / total_questions) * 100
    print(f"\nผลลัพธ์: ตอบถูก {correct_answers} ข้อ จากทั้งหมด {total_questions} ข้อ")
    print(f"ความแม่นยำ: {accuracy:.2f}%")

    summarize_results("ทดสอบความสามารถ", total_questions, correct_answers, wrong_answers,accuracy)
    
# ฟังก์ชันทดสอบความแม่นยำของบอท
def test_bot_accuracy():
    correct_answers = 0
    wrong_answers = 0
    total_questions = 0
    max_value = 50
    
    print("\nเริ่มการทดสอบความแม่นยำของบอท!\n")
    print("=" * 40)

    while wrong_answers < 50 and correct_answers < 1000:  # เพิ่มเงื่อนไขว่าถ้าตอบถูกครบ 1000 ข้อ ให้หยุด
        total_questions += 1
        
        # เพิ่มเลข 9 ลงไปในหลักของการสุ่มทุกๆ 5 ข้อ
        if total_questions % 5 == 0:
            num1 = random.randint(1, 99) * 10000 * 99999999  # เพิ่ม 999 ที่หลักท้าย
            num2 = random.randint(1, 99) * 10000 * 99999999  # เพิ่ม 999 ที่หลักท้าย
        else:
            num1 = random.randint(1, 99)
            num2 = random.randint(1, 99)
        
        correct_answer = num1 + num2

        x1, x2 = num1 / max_value, num2 / max_value
        predicted_answer = predict(x1, x2) * (2 * max_value)

        if round(predicted_answer) == correct_answer:
            correct_answers += 1
            result = "[ถูกต้อง]"
        else:
            wrong_answers += 1
            result = f"[ผิด] คำตอบที่ถูกต้องคือ {correct_answer}"

        print(f"โจทย์: {num1} + {num2} = {round(predicted_answer)} --> {result}")
        
        # แสดงความแม่นยำในแต่ละรอบ
        accuracy = (correct_answers / 1000) * 100

        print(f"ความแม่นยำหลังจากตอบ {total_questions} ข้อ: {accuracy:.2f}%")

    # สรุปผลลัพธ์หลังจากทดสอบเสร็จ
    summarize_results("ทดสอบความแม่นยำ", total_questions, correct_answers, wrong_answers,accuracy)

# ฟังก์ชันสรุปผลลัพธ์
def summarize_results(mode, total_questions, correct_answers, wrong_answers,accuracy):
    print(f"\nผลการทดสอบโมเดล ({mode}):")
    print("+----------------------+------------+")
    print("| รายการ               | จำนวน      |")
    print("+----------------------+------------+")
    print(f"| จำนวนคำถามทั้งหมด      | {total_questions:<10} |")
    print(f"| คำตอบที่ถูกต้อง          | {correct_answers:<10} |")
    print(f"| คำตอบที่ผิด             | {wrong_answers:<10} |")
    print("+----------------------+------------+")
    print(f"| ความแม่นยำ            | {accuracy:.2f}%     |")
    print("+----------------------+------------+")

# เริ่มการทดสอบ
print("เริ่มการทดสอบ\n")
test_bot_capability()
test_bot_accuracy()
