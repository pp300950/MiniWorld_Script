-- ฟังก์ชันกระตุ้น ReLU
function relu(x)
    return math.max(0, x)
end

-- อนุพันธ์ของ ReLU
function relu_derivative(x)
    return x > 0 and 1 or 0
end

-- สุ่มค่าน้ำหนักสำหรับโหนดซ่อน (3 โหนด)
local w1, w2, w3 = random_weight(), random_weight(), random_weight()
local b1, b2, b3 = random_weight(), random_weight(), random_weight()

-- Forward Pass (คำนวณค่าจากอินพุตไปยังโหนดซ่อน)
local hidden1 = relu(x1 * w1 + x2 * w2 + b1)
local hidden2 = relu(x1 * w1 + x2 * w2 + b2)
local hidden3 = relu(x1 * w1 + x2 * w2 + b3)

-- เอาผลลัพธ์จากโหนดซ่อน ไปคำนวณหาเอาต์พุต
local output = (hidden1 + hidden2 + hidden3) / 3
