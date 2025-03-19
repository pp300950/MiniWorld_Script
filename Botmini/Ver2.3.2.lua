math.randomseed(os.time())

-- Q-Table และ Momentum
local Q_table = {}
local momentum = {}

-- พารามิเตอร์การเรียนรู้
local alpha = 0.1   -- Learning rate
local gamma = 0.9   -- Discount factor
local epsilon = 0.5 -- Exploration rate
local epsilon_decay = 0.9999
local epsilon_min = 0.01
local momentum_rate = 0.9

-- แปลงลิสต์ตัวเลขเป็น key string
function list_to_key(num_list)
    return table.concat(num_list, ",")
end

-- เลือก Action โดยมี Exploration & Exploitation
function choose_action(num_list)
    local key = list_to_key(num_list)
    
    if not Q_table[key] or math.random() < epsilon then
        return math.random(-200, 200) -- สุ่มค่า
    end
    
    return Q_table[key] or 0
end

-- อัปเดต Q-Table และใช้ Gradient Descent + Momentum
function update_q_table(num_list, predicted, correct_answer)
    local key = list_to_key(num_list)
    if not Q_table[key] then Q_table[key] = 0 end
    if not momentum[key] then momentum[key] = 0 end
    
    local old_q = Q_table[key]
    local error = correct_answer - predicted
    local gradient = alpha * error
    
    -- ใช้ Momentum ในการปรับค่าการเรียนรู้
    momentum[key] = momentum_rate * momentum[key] + gradient
    Q_table[key] = old_q + momentum[key]
    
    -- ลด epsilon
    epsilon = math.max(epsilon_min, epsilon * epsilon_decay)
end

-- ฝึกโมเดล
function train_q_learning(epochs)
    for i = 1, epochs do
        local num_list = {}
        for j = 1, 2 do
            table.insert(num_list, math.random(-100, 100))
        end

        local correct_answer = 0
        for _, v in ipairs(num_list) do
            correct_answer = correct_answer + v
        end

        local predicted_answer = choose_action(num_list)
        update_q_table(num_list, predicted_answer, correct_answer)

        if i % 10000 == 0 then
            print("Training iteration:", i, "Epsilon:", epsilon)
        end
    end
end

train_q_learning(10000)

-- ฟังก์ชันทดสอบ
function test_bot(num_list)
    local key = list_to_key(num_list)
    
    if not Q_table[key] then
        return math.random(-50, 50) -- ให้มีความสุ่มบ้าง
    end
    
    return Q_table[key] or 0
end

-- ทดสอบโมเดล
for i = 1, 10 do
    local num_list = {}
    for j = 1, 2 do
        table.insert(num_list, math.random(-100, 100))
    end

    local pred = test_bot(num_list)
    local ans = 0
    for _, v in ipairs(num_list) do
        ans = ans + v
    end

    print(string.format("Predicted: %d | Actual: %d | %s", math.floor(pred), ans, (math.abs(pred - ans) <= 10) and "✔️ Close Enough" or "❌ Incorrect"))
end