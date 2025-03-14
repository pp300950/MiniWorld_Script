-- ฟังก์ชันคำนวณผลลัพธ์ของนิพจน์ที่กำหนด และแสดงลำดับการคำนวณ
function compute(a, op, b)
    local result
    if a == nil or b == nil then
        return nil 
    end
    
    if op == "+" then result = a + b
    elseif op == "-" then result = a - b
    elseif op == "*" then result = a * b
    elseif op == "/" then
        if b == 0 then return nil end  --ป้องกันหารด้วย 0
        result = a / b
    end
    return result
end

function find_24(numbers)
    local ops = {"+", "-", "*", "/"}
    
    --สร้างทุกการเรียงลำดับของตัวเลข
    for i = 1, 4 do
        for j = 1, 4 do
            if j ~= i then
                for k = 1, 4 do
                    if k ~= i and k ~= j then
                        for l = 1, 4 do
                            if l ~= i and l ~= j and l ~= k then
                                local a, b, c, d = numbers[i], numbers[j], numbers[k], numbers[l]
                                
                                --ทดลองใช้ทุกตัวดำเนินการ
                                for _, op1 in ipairs(ops) do
                                    for _, op2 in ipairs(ops) do
                                        for _, op3 in ipairs(ops) do
                                            
                                            local r1 = compute(a, op1, b)
                                            if r1 then
                                                local r2 = compute(r1, op2, c)
                                                if r2 then
                                                    local r3 = compute(r2, op3, d)
                                                    if r3 and math.abs(r3 - 24) < 1e-6 then
                                                        print(string.format("find: ((%d %s %d) %s %d) %s %d = 24", a, op1, b, op2, c, op3, d))
                                                    end
                                                end
                                            end
                                            
                                            local r1 = compute(a, op1, compute(b, op2, compute(c, op3, d)))
                                            if r1 and math.abs(r1 - 24) < 1e-6 then
                                                print(string.format("find: %d %s (%d %s (%d %s %d)) = 24", a, op1, b, op2, c, op3, d))
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

numbers = {8, 1, 3, 3}
find_24(numbers)
