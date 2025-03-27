-- ตั้งค่าเริ่มต้น
math.randomseed(os.time())

-- ฟังก์ชันสร้างเมทริกซ์
function create_matrix(rows, cols)
    local matrix = {}
    for i = 1, rows do
        matrix[i] = {}
        for j = 1, cols do
            matrix[i][j] = (math.random() * 2 - 1) * 0.01 -- ค่าเริ่มต้นเล็ก ๆ
        end
    end
    return matrix
end

-- ฟังก์ชันคูณเมทริกซ์กับเวกเตอร์
function matmul(A, B)
    local result = {}
    for i = 1, #A do
        result[i] = 0
        for j = 1, #B do
            result[i] = result[i] + A[i][j] * B[j]
        end
    end
    return result
end

-- ฟังก์ชัน Activation (ReLU)
function relu(x)
    local out = {}
    for i = 1, #x do
        out[i] = math.max(0, x[i])
    end
    return out
end

-- โมเดล ANN
local ANN = {
    input_size = 2,
    hidden_size = 8,
    output_size = 39, -- 2 ถึง 40 มี 39 ค่า
    W1 = create_matrix(8, 2),
    W2 = create_matrix(39, 8),
    learning_rate = 0.01,
    momentum = 0.9,
    v_W1 = create_matrix(8, 2),
    v_W2 = create_matrix(39, 8)
}

-- ฟังก์ชันส่งข้อมูลผ่านเครือข่าย
function ANN:forward(state)
    local h = relu(matmul(self.W1, state))
    local q_values = matmul(self.W2, h)
    return q_values, h
end

-- ฟังก์ชันเลือก action
function choose_action(state)
    local q_values, _ = ANN:forward(state)
    if math.random() < 0.1 then
        return math.random(2, 40)
    else
        local max_q, best_action = -math.huge, 2
        for action = 2, 40 do
            local index = action - 1  -- ให้สอดคล้องกับขนาดของ W2
            if q_values[index] and q_values[index] > max_q then
                max_q = q_values[index]
                best_action = action
            end
        end
        return best_action
    end
end

-- ฟังก์ชันอัปเดตโมเดล ANN
function ANN:update(state, action, reward, next_state)
    local q_values, h = self:forward(state)
    local next_q_values, _ = self:forward(next_state)
    
    local target = {}
    for i = 1, #q_values do
        target[i] = q_values[i]
    end
    
    local max_next_q = -math.huge
    for a = 2, 40 do
        local index = a - 1
        if next_q_values[index] and next_q_values[index] > max_next_q then
            max_next_q = next_q_values[index]
        end
    end
    
    local index = action - 1
    target[index] = reward + 0.9 * max_next_q
    
    -- อัปเดตน้ำหนักด้วย SGD + Momentum
    for i = 1, #self.W2 do
        for j = 1, #h do
            local grad = (q_values[i] - target[i]) * h[j]
            self.v_W2[i][j] = self.momentum * self.v_W2[i][j] - self.learning_rate * grad
            self.W2[i][j] = self.W2[i][j] + self.v_W2[i][j]
        end
    end
    
    for i = 1, #self.W1 do
        for j = 1, #state do
            local grad = (q_values[index] - target[index]) * state[j]
            self.v_W1[i][j] = self.momentum * self.v_W1[i][j] - self.learning_rate * grad
            self.W1[i][j] = self.W1[i][j] + self.v_W1[i][j]
        end
    end
end

-- ฟังก์ชันฝึกโมเดล
function train_ann(epochs)
    for i = 1, epochs do
        local num1, num2 = math.random(1, 20), math.random(1, 20)
        local correct_answer = num1 + num2
        local state = {num1 / 20, num2 / 20}
        
        local action = choose_action(state)
        local reward = (action == correct_answer) and 1 or -0.1 -- ลดโทษเมื่อตอบผิด
        local next_state = state
        
        ANN:update(state, action, reward, next_state)
        
        if i % 5000 == 0 then
            print("Training iteration: " .. i)
        end
    end
end

-- เริ่มการฝึก
train_ann(100000)

-- ฟังก์ชันทดสอบบอท
function test_bot(num1, num2)
    local state = {num1 / 20, num2 / 20}
    return choose_action(state)
end

print("10 + 5 =", test_bot(10, 5))
