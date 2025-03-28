--ฟังก์ชันกระตุ้น
function linear(x)
    return x  
end
--อนุพันธ์ของฟังก์ชันLinear
function linear_derivative(x)
    return 1  
end

--กำหนดค่าน้ำหนักแบบสุ่ม
math.randomseed(os.time())
function random_weight()
    return math.random() * 0.1 - 0.05  --ลดขนาดน้ำหนักเริ่มต้น
end

--ข้อมูลสำหรับการฝึก 
local inputs = {}
local outputs = {}
local max_value = 50  --ค่าสูงสุดของข้อมูล

for i = 0, max_value do
    for j = 0, max_value do
        table.insert(inputs, {i / max_value, j / max_value})  --Normalize อินพุต
        table.insert(outputs, {(i + j) / (2 * max_value)})  --Normalize เอาต์พุต
    end
end

--กำหนดค่าน้ำหนักเริ่มต้น
local w1, w2, b = random_weight(), random_weight(), random_weight()
local learning_rate = 0.001  --ลดอัตราการเรียนรู้
local epochs = 1000

--วนลูปฝึกโมเดล
for epoch = 1, epochs do
    local total_error = 0
    for i = 1, #inputs do
        local x1, x2 = inputs[i][1], inputs[i][2]
        local target = outputs[i][1]

        --คำนวณไปข้างหน้า
        local weighted_sum = x1 * w1 + x2 * w2 + b
        local prediction = linear(weighted_sum)

        --ตรวจNaN
        if prediction ~= prediction then
            print("พบ NaN ที่ epoch:", epoch, "x1:", x1, "x2:", x2)
            os.exit()
        end

        local error = prediction - target
        total_error = total_error + math.abs(error)

        local dcost_dpred = error
        local dpred_dz = linear_derivative(weighted_sum)

        local dz_dw1 = x1
        local dz_dw2 = x2
        local dz_db = 1

        --อัปเดตค่าน้ำหนักและค่าไบแอส
        w1 = w1 - learning_rate * dcost_dpred * dpred_dz * dz_dw1
        w2 = w2 - learning_rate * dcost_dpred * dpred_dz * dz_dw2
        b  = b  - learning_rate * dcost_dpred * dpred_dz * dz_db
    end

    if epoch % 5000 == 0 then
        print("รอบที่:", epoch, "ข้อผิดพลาดรวม:", total_error)
    end
end

print("\nค่าพารามิเตอร์ที่ฝึกแล้ว:")
print("w1:", string.format("%.10f", w1))
print("w2:", string.format("%.10f", w2))
print("b:", string.format("%.15f", b))

print("\nผลลัพธ์ของโมเดลที่ฝึกแล้ว:")
local test_cases = {{1, 1}, {6, 4}, {10, 11}, {16550, 200}}
for _, case in ipairs(test_cases) do
    local x1, x2 = case[1] / max_value, case[2] / max_value  --Normalize อินพุต
    local weighted_sum = x1 * w1 + x2 * w2 + b 
    local prediction = linear(weighted_sum) * (2 * max_value)  --ย้อนค่ากลับ
    print("อินพุต:", case[1], case[2], "ผลลัพธ์ที่ทำนาย:", math.floor(prediction + 0.5))
end
