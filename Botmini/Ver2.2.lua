math.randomseed(os.time())

-- สร้าง Q-Table
local Q_table = {}
for i = -1000000, 1000000 do
    Q_table[i] = {}
    for j = -1000000, 1000000 do
        Q_table[i][j] = {}
        for action = -1000000, 2000000 do
            Q_table[i][j][action] = math.random() * 0.1 -- ตั้งค่า Q-Value เริ่มต้นให้มีค่าเล็กน้อย
        end
    end
end

-- พารามิเตอร์การเรียนรู้ (20ตัวแปร)
local parameters = {}
for i = 1, 20 do
    parameters[i] = math.random() -- กำหนดค่าเริ่มต้นให้สุ่ม
end

local alpha = parameters[1]  -- Learning rate
local gamma = parameters[2]  -- Discount factor
local epsilon = parameters[3] -- Exploration rate
local epsilon_decay = parameters[4]
local epsilon_min = parameters[5]

-- หาค่า action ที่ดีที่สุด
function argmax(q_values)
    local max_action, max_q = nil, -math.huge
    for action, q_value in pairs(q_values) do
        if q_value > max_q then
            max_q = q_value
            max_action = action
        end
    end
    return max_action
end

-- เลือก Action โดยใช้ Epsilon-Greedy
function choose_action(num1, num2)
    if math.random() < epsilon then
        return math.random(-1000000, 2000000) -- สุ่มค่า
    else
        return argmax(Q_table[num1][num2])
    end
end

-- อัปเดต Q-Table
function update_q_table(num1, num2, action, reward)
    local max_next_q = argmax(Q_table[num1][num2])
    local old_q = Q_table[num1][num2][action]
    Q_table[num1][num2][action] = old_q + alpha * (reward + gamma * max_next_q - old_q)

    -- ปรับปรุงพารามิเตอร์ให้เหมาะสม
    parameters[1] = math.max(0.01, parameters[1] * 0.99)
    parameters[2] = math.min(0.99, parameters[2] * 1.01)
    parameters[3] = math.max(0.01, parameters[3] * 0.99)
    parameters[4] = math.max(0.00001, parameters[4] * 0.9999)
end

-- ฝึกโมเดล
function train_q_learning(epochs)
    local correct_count = 0
    for i = 1, epochs do
        local num1, num2 = math.random(-1000000, 1000000), math.random(-1000000, 1000000)
        local correct_answer = num1 + num2
        local action = choose_action(num1, num2)
        local reward = 1000000 - math.abs(action - correct_answer)
        if action == correct_answer then
            reward = reward + 1000 -- ให้รางวัลพิเศษถ้าคำตอบถูกต้อง
            correct_count = correct_count + 1
        end

        update_q_table(num1, num2, action, reward)
        
        -- ลด Epsilon ลง
        epsilon = math.max(epsilon_min, epsilon * epsilon_decay)
        
        if i % 5000 == 0 then
            print("Training iteration:", i, "Epsilon:", epsilon)
        end
        
        -- หยุดการฝึกหากตอบถูกเกิน 5 ครั้ง
        if correct_count >= 5 then
            print("เรียนรู้สำเร็จ! ค่าพารามิเตอร์ที่ได้:")
            for i, v in ipairs(parameters) do
                print("Parameter[" .. i .. "]: ", v)
            end
            return
        end
        
        -- ป้องกันการค้างของโค้ด
        if i % 10000 == 0 then
            io.flush()
        end
    end
end

-- ฝึกโมเดล 150,000 รอบ
train_q_learning(10000)

-- ฟังก์ชันทดสอบ
function test_bot(num1, num2)
    return argmax(Q_table[num1][num2])
end

-- ทดสอบโมเดล
for i = 1, 10 do
    local a, b = math.random(-1000000, 1000000), math.random(-1000000, 1000000)
    local pred = test_bot(a, b)
    print(a .. " + " .. b .. " = " .. pred .. " (ANS=" .. (a + b) .. ")")
end