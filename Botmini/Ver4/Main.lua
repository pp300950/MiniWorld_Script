-- เครือข่ายประสาทเทียมสำหรับการบวก โดยใช้ Gradient Descent แบบง่ายใน Lua
-- ฟังก์ชันกระตุ้น (Linear Activation)
function linear(x)
    return x  --ไม่มีการแปลงค่าหมาะสำหรับงานคาดการณ์ค่า (Regression)
end

--Linear
function linear_derivative(x)
    return 1  --อนุพันธ์ของ x คือ 1 เสมอ
end

--กำหนดค่าน้ำหนักแบบสุ่ม
math.randomseed(os.time())
function random_weight()
    return math.random() * 2 - 1  --ค่าสุ่มระหว่าง -1 ถึง 1
end

--ข้อมูลสำหรับการฝึก
local inputs = {{0,0}, {0,1}, {1,0}, {1,1}, {2,2}, {3,3}, {4,5}}  -- คู่ตัวเลขที่จะนำมาบวก
local outputs = {0, 1, 1, 2, 4, 6, 9}  -- ผลลัพธ์ที่คาดหวัง

--กำหนดค่าน้ำหนักเริ่มต้นและค่าไบแอสแบบสุ่ม
local w1, w2, b = random_weight(), random_weight(), random_weight()
local learning_rate = 0.01  
local epochs = 10000  

--วนลูปฝึกโมเดล
for epoch = 1, epochs do
    local total_error = 0  --ค่าความผิดพลาดสะสมในแต่ละรอบ
    for i = 1, #inputs do
        local x1, x2 = inputs[i][1], inputs[i][2]  --ดึงค่าข้อมูลอินพุต
        local target = outputs[i]  --ค่าผลลัพธ์ที่คาดหวัง

        local weighted_sum = x1 * w1 + x2 * w2 + b  
        local prediction = linear(weighted_sum) 

        --คำนวณค่าความผิดพลาด
        local error = target - prediction
        total_error = total_error + math.abs(error)  --รวมค่าความผิดพลาดทั้งหมด

        local dcost_dpred = -error  
        local dpred_dz = linear_derivative(prediction)  --อนุพันธ์ของฟังก์ชัน Linear

        local dz_dw1 = x1  --นุพันธตาม w1
        local dz_dw2 = x2  --อนุพันตาม w2
        local dz_db = 1  --อนุพันตาม b

        --อัปเดตค่าน้ำหนักและค่าไบแอด
        w1 = w1 - learning_rate * dcost_dpred * dpred_dz * dz_dw1
        w2 = w2 - learning_rate * dcost_dpred * dpred_dz * dz_dw2
        b  = b  - learning_rate * dcost_dpred * dpred_dz * dz_db
    end

    if epoch % 1000 == 0 then
        print("รอบที่:", epoch, "ข้อผิดพลาดรวม:", total_error)
    end
end

--แสดงค่าพารามิเตอร์ที่ฝึกแล้ว
print("\nค่าพารามิเตอร์ที่ฝึกแล้ว:")
print("w1:", w1)
print("w2:", w2)
print("b:", b)

--ทดสอบ
print("\nผลลัพธ์ของโมเดลที่ฝึกแล้ว:")
for i = 1, #inputs do
    local x1, x2 = inputs[i][1], inputs[i][2]  --ดึงอินพุต
    local weighted_sum = x1 * w1 + x2 * w2 + b  --ผลรวมถ่วงน้ำหนัก
    local prediction = linear(weighted_sum)  --Linear Activation
    print("อินพุต:", x1, x2, "ผลลัพธ์ที่ทำนาย:", prediction) 
end
