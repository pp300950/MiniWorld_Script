-- ฟังก์ชันกระตุ้น (Linear Activation)
function linear(x)
    return x  
end

-- ค่าพารามิเตอร์ที่ฝึกแล้ว
local w1 = 0.49999924345161
local w2 = 0.49999960074013
local b  = 8.2487500410537e-07

-- ฟังก์ชันทำนายผลลัพธ์
function predict(x1, x2)
    local weighted_sum = x1 * w1 + x2 * w2 + b
    return linear(weighted_sum)
end

-- ทดสอบโมเดลที่ฝึกแล้ว
print("\nผลลัพธ์ของโมเดลที่ฝึกแล้ว:")
local test_cases = {{60, 70}, {80, 90}, {100, 110}, {150, 200}}
local max_value = 50  -- ใช้ค่าสูงสุดเดิมที่ใช้ normalize

for _, case in ipairs(test_cases) do
    local x1, x2 = case[1] / max_value, case[2] / max_value  -- Normalize อินพุต
    local prediction = predict(x1, x2) * (2 * max_value)  -- ย้อนค่ากลับจาก normalize
    print("อินพุต:", case[1], case[2], "ผลลัพธ์ที่ทำนาย:", math.floor(prediction + 0.5))  
end
