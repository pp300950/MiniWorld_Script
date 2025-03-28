--ฟังก์ชันกระตุ้น
function linear(x)
    return x  
end

--อนุพันธ์ของฟังก์ชัน Linear
function linear_derivative(x)
    return 1  
end

--ฟังก์ชันแปลงสตริงเป็นอาเรย์
function string_to_array(str)
    local array = {}
    for pair in string.gmatch(str, "[^|]+") do
        local x1, x2 = pair:match("%s*(%-?%d+%.?%d*)%s*,%s*(%-?%d+%.?%d*)%s*")
        if x1 and x2 then
            table.insert(array, {tonumber(x1), tonumber(x2)})
            print("อาเรย์ที่เเปลงเเล้ว"..array)
        else
            print("รูปแบบข้อมูลผิดพลาด:", pair)
        end
    end
    return array
end


--สุ่มค่าน้ำหนักเริ่มต้น
math.randomseed(os.time())
function random_weight()
    return math.random() * 0.1 - 0.05
end

--ข้อมูลสำหรับการฝึก 

local max_value = 50  --ค่าสูงสุดของข้อมูลที่จะใช้ในการเทรน

local inputs, outputs = {}, {}

--โหลดค่าที่บันทึกไว้ก่อนหน้า
local result_inputs, saved_inputs_str = VarLib2:getGlobalVarByName(4, "inputs")
local result_outputs, saved_outputs_str = VarLib2:getGlobalVarByName(4, "outputs")


--ตรวจสอบว่าข้อมูลที่โหลดมามีค่าและไม่ใช่สตริงว่าง
if saved_inputs_str ~= "" and saved_outputs_str ~= "" then
    --แปลงค่าที่โหลดเป็นอาเรย์
    inputs = saved_inputs_str
    outputs = saved_outputs_str
    print(" #Rมีข้อมูลอยู่เเล้วจร้า ")
else
    --ถ้ายังไม่มีค่าที่บันทึกไว้ ให้สร้างข้อมูลใหม่
inputs = ""
outputs = ""

for i = 0, max_value do
    for j = 0, max_value do
        --เพิ่มข้อมูลลงในสตริง inputs และ outputs
        inputs = inputs .. tostring(i / max_value) .. "," .. tostring(j / max_value) .. "|"
        outputs = outputs .. tostring((i + j) / (2 * max_value)) .. " "
    end
end

    --แปลงเป็นสตริงก่อนบันทึก
    VarLib2:setGlobalVarByName(4, "inputs", inputs)
    VarLib2:setGlobalVarByName(4, "outputs", outputs)
end

--โหลดค่าที่บันทึกไว้ก่อนหน้า
local _, w1 = VarLib2:getGlobalVarByName(3, "w1")
local _, w2 = VarLib2:getGlobalVarByName(3, "w2")
local _, b = VarLib2:getGlobalVarByName(3, "b")
local _, epochs = VarLib2:getGlobalVarByName(3, "epochs")
local _, learning_rate = VarLib2:getGlobalVarByName(3, "learning_rate")
local _, current_epoch = VarLib2:getGlobalVarByName(3, "current_epoch") -- เก็บรอบล่าสุดที่ฝึกไป

--ถ้าค่าที่โหลดมาเป็น nil หรือ 0 ให้กำหนดค่าเริ่มต้นใหม่
w1 = (w1 ~= nil and w1 ~= 0) and w1 or random_weight()
w2 = (w2 ~= nil and w2 ~= 0) and w2 or random_weight()
b = (b ~= nil and b ~= 0) and b or random_weight()
epochs = (epochs ~= nil and epochs ~= 0) and epochs or 0
learning_rate = (learning_rate ~= nil and learning_rate ~= 0) and learning_rate or 0.001
current_epoch = (current_epoch ~= nil and current_epoch ~= 0) and current_epoch or 0

--ฟังก์ชันแปลงสตริงเป็นค่าทีละคู่โดยไม่ต้องสร้างอาเรย์
function string_iter(str)
    return string.gmatch(str, "[^|]+")
end

--ฟังก์ชันดึงค่าผลลัพธ์ออกจากสตริงทีละค่า
function output_iter(str)
    return string.gmatch(str, "%-?%d+%.?%d*")
end

--เริ่มเทรน
print("#Bเริ่มเทรน")
epochs = epochs + 1
local total_error = 0

local input_iterator = string_iter(inputs)
local output_iterator = output_iter(outputs)

for pair in input_iterator do  -- ใช้iteratorแทนอาเรย์
    local x1, x2 = pair:match("%s*(%-?%d+%.?%d*)%s*,%s*(%-?%d+%.?%d*)%s*")
    local target = output_iterator()
    if x1 and x2 and target then
        x1, x2, target = tonumber(x1), tonumber(x2), tonumber(target)
        
        --คำนวณไปข้างหน้า
        local weighted_sum = x1 * w1 + x2 * w2 + b
        local prediction = linear(weighted_sum)

        --ตรวจ NaN
        if prediction ~= prediction then
            print("พบ NaN ที่ epoch:", "x1:", x1, "x2:", x2)
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
    else
        print("รูปแบบข้อมูลผิดพลาด:", pair)
    end
end

--อัปเดตค่ารอบปัจจุบัน
if epochs % 10 == 0 then
    print("รอบที่:", epochs, "ข้อผิดพลาดรวม:", total_error)
end

--บันทึกค่าตัวแปร
VarLib2:setGlobalVarByName(3, "current_epoch", current_epoch)
VarLib2:setGlobalVarByName(3, "w1", w1)
VarLib2:setGlobalVarByName(3, "w2", w2)
VarLib2:setGlobalVarByName(3, "b", b)
VarLib2:setGlobalVarByName(3, "epochs", epochs)
VarLib2:setGlobalVarByName(3, "learning_rate", learning_rate)
VarLib2:setGlobalVarByName(3, "total_error", total_error)
print("เก็บค่าละ")

--ค่าที่ฝึกแล้ว
print("\nค่าพารามิเตอร์ที่ฝึกแล้ว:")
print("w1=", w1)
print("w2=", w2)
print("b=", b)

--ผลการทดสอบ
print("\nผลลัพธ์ของโมเดลที่ฝึกแล้ว:")
local test_cases = {{1, 1}, {6, 4}, {19, 59}, {1650, 200}, {9951, 12559}}

local results = {}  -- สร้างตารางเก็บสตริงของแต่ละบรรทัด

for _, case in ipairs(test_cases) do
    local x1, x2 = case[1] / max_value, case[2] / max_value
    local weighted_sum = x1 * w1 + x2 * w2 + b 
    local prediction = linear(weighted_sum) * (2 * max_value) 
    local rounded_prediction = math.floor(prediction + 0.5)

    -- ต่อสตริงและเพิ่มลงในตาราง
    table.insert(results, "input: " .. case[1] .. " + " .. case[2] .. " = " .. rounded_prediction .. " | "..case[1]+case[2])
end

-- รวมผลลัพธ์ทั้งหมดเป็นสตริงเดียว โดยใช้ "\n" เป็นตัวคั่นบรรทัด
local final_result = table.concat(results, "\n")

print(final_result)  -- แสดงผล
VarLib2:setGlobalVarByName(4, "final_result", final_result)