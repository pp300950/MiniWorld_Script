local q_table = {}  -- ตาราง Q-learning
local alpha = 0.1   -- Learning rate
local gamma = 0.9   -- Discount factor
local epsilon = 0.1 -- Exploration rate
local token_experience = 0
local training_rounds = 50000  

-- ฟังก์ชันเลือก action
function choose_action(state)
    if math.random() < epsilon then
        return math.random(2, 40)  
    else
        local best_action = 2  
        local max_q_value = -math.huge
        
        q_table[state] = q_table[state] or {}  
        
        for action = 2, 40 do
            local q_value = q_table[state][action] or 0
            if q_value > max_q_value then
                best_action = action
                max_q_value = q_value
            end
        end
        return best_action
    end
end

-- ฟังก์ชันอัปเดต Q-table
function update_q_table(state, action, reward, next_state)
    q_table[state] = q_table[state] or {}
    q_table[next_state] = q_table[next_state] or {}
    
    local max_q_value_next = -math.huge
    for a = 2, 40 do
        local q_value_next = q_table[next_state][a] or 0
        if q_value_next > max_q_value_next then
            max_q_value_next = q_value_next
        end
    end

    local current_q_value = q_table[state][action] or 0
    local new_q_value = current_q_value + alpha * (reward + gamma * max_q_value_next - current_q_value)

    q_table[state][action] = new_q_value
end

-- ฟังก์ชันฝึกบอท
function train_bot(rounds)
    for i = 1, rounds do
        local num1 = math.random(1, 20)
        local num2 = math.random(1, 20)
        local correct_answer = num1 + num2
        local state = num1 .. "_" .. num2

        local action = choose_action(state)

        local reward = (action == correct_answer) and 1 or -1
        update_q_table(state, action, reward, state)

        if reward == 1 then
            token_experience = token_experience + 1
        end
    end
end

train_bot(training_rounds)  

-- ฟังก์ชันแปลง Q-table เป็น JSON (บันทึกเฉพาะค่าที่มีประโยชน์)
function q_table_to_json()
    local json = "{\n"
    local first_entry = true

    for state, actions in pairs(q_table) do
        local best_action, max_q_value = nil, -math.huge

        -- ค้นหา action ที่มีค่า Q-value สูงสุด
        for action, q_value in pairs(actions) do
            if q_value > max_q_value then
                best_action = action
                max_q_value = q_value
            end
        end

        -- บันทึกเฉพาะ action ที่ดีที่สุด และต้องมีค่า Q-value สูงพอสมควร
        if best_action and max_q_value > 0.5 then  -- กำหนดเงื่อนไข Q-value > 0.5 เพื่อคัดข้อมูลที่มีประโยชน์จริง ๆ
            if not first_entry then
                json = json .. ",\n"
            end
            first_entry = false

            json = json .. string.format('  "%s": {"%d": %.4f}', state, best_action, max_q_value)
        end
    end

    json = json .. "\n}"
    return json
end

-- ฟังก์ชันบันทึก Q-table ลงไฟล์
function save_q_table(filename)
    local file = io.open(filename, "w")
    if file then
        file:write(q_table_to_json())
        file:close()
        print("Optimized Q-table saved to " .. filename)
    else
        print("Error saving Q-table!")
    end
end

save_q_table("bot_qtable_optimized.json")

-- ฟังก์ชันทดสอบบอท
function test_bot(num1, num2)
    local state = num1 .. "_" .. num2
    q_table[state] = q_table[state] or {}

    return choose_action(state) 
end

-- ตัวอย่างการทดสอบ
print("3 + 5 =", test_bot(3, 5))
print("10 + 7 =", test_bot(10, 7))
print("15 + 4 =", test_bot(15, 4))

print("199999 + 1 =", test_bot(199999, 1))