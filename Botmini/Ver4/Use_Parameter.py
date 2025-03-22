# ฟังก์ชันกระตุ้น (Linear Activation)
def linear(x):
    return x  

# ค่าพารามิเตอร์ที่ฝึกแล้ว


w1=     0.55218498186502
w2=     0.5174137488447
b=      0.96361142029463

# ฟังก์ชันทำนายผลลัพธ์
def predict(x1, x2):
    weighted_sum = x1 * w1 + x2 * w2 + b
    return linear(weighted_sum)

# ทดสอบโมเดลที่ฝึกแล้ว
print("\nผลลัพธ์ของโมเดลที่ฝึกแล้ว:")
test_cases = [[60, 70], [80, 90], [100, 110], [150, 200] ,[15326223130, 20000]]
max_value = 50  # ใช้ค่าสูงสุดเดิมที่ใช้ normalize

for case in test_cases:
    x1, x2 = case[0] / max_value, case[1] / max_value  # Normalize อินพุต
    prediction = predict(x1, x2) * (2 * max_value)  # ย้อนค่ากลับจาก normalize
    print(f"อินพุต: {case[0]}, {case[1]} ผลลัพธ์ที่ทำนาย: {round(prediction)}")  
