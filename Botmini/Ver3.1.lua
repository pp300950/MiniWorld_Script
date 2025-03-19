math.randomseed(os.time())

-- 🧠 Neural Network Model (Simple DQN)
function createDQN(input_size, hidden_size, output_size)
    local model = {
        weights1 = {},
        biases1 = {},
        weights2 = {},
        biases2 = {}
    }

    -- 🎯 สุ่มค่าเริ่มต้นของน้ำหนักและ bias
    for i = 1, input_size do
        model.weights1[i] = {}
        for j = 1, hidden_size do
            model.weights1[i][j] = math.random() * 2 - 1
        end
    end
    for j = 1, hidden_size do
        model.biases1[j] = math.random() * 2 - 1
        model.weights2[j] = {}
        for k = 1, output_size do
            model.weights2[j][k] = math.random() * 2 - 1
        end
    end
    for k = 1, output_size do
        model.biases2[k] = math.random() * 2 - 1
    end

    return model
end

-- 🏼‍♂️ Forward Propagation (ReLU Activation)
function forward(model, input)
    local hidden = {}
    for j = 1, #model.weights1[1] do
        hidden[j] = model.biases1[j]
        for i = 1, #input do
            hidden[j] = hidden[j] + input[i] * model.weights1[i][j]
        end
        hidden[j] = math.max(0, hidden[j]) -- ReLU Activation
    end

    local output = {}
    for k = 1, #model.weights2[1] do
        output[k] = model.biases2[k]
        for j = 1, #hidden do
            output[k] = output[k] + hidden[j] * model.weights2[j][k]
        end
    end

    return output, hidden
end

-- 🛠 Backpropagation & Gradient Descent
function trainDQN(model, input, target, lr)
    local output, hidden = forward(model, input)
    local error_value = target - output[1]

    -- ปรับค่าชั้นที่ 2
    for j = 1, #model.weights2 do
        model.weights2[j][1] = model.weights2[j][1] + lr * error_value * hidden[j]
    end
    model.biases2[1] = model.biases2[1] + lr * error_value

    -- ปรับค่าชั้นที่ 1
    for i = 1, #input do
        for j = 1, #model.weights1[i] do
            if hidden[j] > 0 then
                model.weights1[i][j] = model.weights1[i][j] + lr * error_value * model.weights2[j][1] * input[i]
            end
        end
    end
end

-- 🎮 Deep Q-Network (DQN) Agent
DQNAgent = {}
DQNAgent.__index = DQNAgent

function DQNAgent:create(input_size)
    local agent = {}
    setmetatable(agent, DQNAgent)
    agent.model = createDQN(input_size, 64, 1)
    agent.gamma = 0.9
    agent.epsilon = 1.0
    agent.epsilon_min = 0.01
    agent.epsilon_decay = 0.999
    agent.memory = {}
    agent.batch_size = 64
    agent.learning_rate = 0.01
    return agent
end

function DQNAgent:choose_action(state)
    if math.random() < self.epsilon then
        return math.random(-200, 200)
    end

    local output, _ = forward(self.model, state)
    return math.floor(output[1] or 0)
end

function DQNAgent:store_experience(state, action, reward, next_state)
    table.insert(self.memory, {state, action, reward, next_state})
    if #self.memory > 10000 then table.remove(self.memory, 1) end
end

function DQNAgent:train()
    if #self.memory < self.batch_size then return end

    local batch = {}
    for i = 1, self.batch_size do
        table.insert(batch, self.memory[math.random(#self.memory)])
    end

    for _, experience in ipairs(batch) do
        local state, action, reward, next_state = experience[1], experience[2], experience[3], experience[4]
        local next_output, _ = forward(self.model, next_state)
        local target = reward + self.gamma * (next_output[1] or 0)
        trainDQN(self.model, state, target, self.learning_rate)
    end

    self.epsilon = math.max(self.epsilon_min, self.epsilon * self.epsilon_decay)
end

-- 🚀 ฝึกโมเดล DQN โดยใช้สูตร Dew = Dold + ΔD
function train_dqn(agent, epochs)
    local Dold = 0
    for i = 1, epochs do
        local deltaD = math.random(-100, 100)
        local Dew = Dold + deltaD
        local state = {Dold, deltaD}
        local action = agent:choose_action(state)
        local reward = -math.abs(action - Dew)

        agent:store_experience(state, action, reward, state)
        agent:train()

        Dold = Dew  -- อัปเดตค่า Dold
    end
end

-- 🧪 ทดสอบโมเดล
function test_dqn(agent, test_cases)
    for _, test in ipairs(test_cases) do
        local Dold, deltaD = test[1], test[2]
        local Dew = Dold + deltaD
        local state = {Dold, deltaD}
        local predicted = agent:choose_action(state)
        print(string.format("Dold: %.2f, ΔD: %.2f, : %.2f, true: %.2f", Dold, deltaD, predicted, Dew))

    end
end

-- 🔥 เริ่มต้นฝึก Agent
local agent = DQNAgent:create(2)
train_dqn(agent, 5000)

test_dqn(agent, {{10, 5}, {-20, 15}, {50, -10}, {-30, -20}, {100, 25}})