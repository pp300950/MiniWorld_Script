-- แจ้งผู้เล่นเมื่อเริ่มเกม
Chat:sendSystemMsg("#Yเกม 24 เริ่มต้นแล้ว! กรุณาป้อนตัวเลข 4 ตัวที่คั่นด้วยเครื่องหมายจุลภาค (,) เพื่อหาผลลัพธ์ 24.")
-- ฟังก์ชันคำนวณผลลัพธ์ของนิพจน์ที่กำหนด และแสดงลำดับการคำนวณ
function compute(a, op, b)
    local result
    if a == nil or b == nil then
        return nil -- ถ้า a หรือ b เป็น nil, ให้คืนค่า nil
    end
    
    if op == "+" then result = a + b
    elseif op == "-" then result = a - b
    elseif op == "*" then result = a * b
    elseif op == "/" then
        if b == 0 then return nil end  -- ป้องกันหารด้วย 0
        result = a / b
    end
    return result
end

-- ฟังก์ชันค้นหาวิธีที่ได้ผลลัพธ์ 24 พร้อมแสดงลำดับการคำนวณ
function find_24(numbers)
    local ops = {"+", "-", "*", "/"}
    
    -- สร้างทุกการเรียงลำดับของตัวเลข
    for i = 1, 4 do
        for j = 1, 4 do
            if j ~= i then
                for k = 1, 4 do
                    if k ~= i and k ~= j then
                        for l = 1, 4 do
                            if l ~= i and l ~= j and l ~= k then
                                local a, b, c, d = numbers[i], numbers[j], numbers[k], numbers[l]
                                
                                -- ทดลองใช้ทุกตัวดำเนินการ
                                for _, op1 in ipairs(ops) do
                                    for _, op2 in ipairs(ops) do
                                        for _, op3 in ipairs(ops) do
                                            
                                            -- ทดลองทุกการใส่วงเล็บ
                                            local r1 = compute(a, op1, b)
                                            if r1 then
                                                local r2 = compute(r1, op2, c)
                                                if r2 then
                                                    local r3 = compute(r2, op3, d)
                                                    if r3 and math.abs(r3 - 24) < 1e-6 then
                                                        -- ใช้ Chat:sendSystemMsg แทนการ print
                                                        Chat:sendSystemMsg(string.format("พบวิธี: ((%d %s %d) %s %d) %s %d = 24", a, op1, b, op2, c, op3, d))
                                                    end
                                                end
                                            end
                                            
                                            local r1 = compute(a, op1, compute(b, op2, compute(c, op3, d)))
                                            if r1 and math.abs(r1 - 24) < 1e-6 then
                                                -- ใช้ Chat:sendSystemMsg แทนการ print
                                                Chat:sendSystemMsg(string.format("พบวิธี: %d %s (%d %s (%d %s %d)) = 24", a, op1, b, op2, c, op3, d))
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

-- ฟังก์ชันจัดการอินพุตจากผู้เล่น
ScriptSupportEvent:registerEvent([=[Player.NewInputContent]=], function(event)
    local inputText = event.content  -- ข้อความที่ผู้เล่นพิมพ์ในช่องแชท
    
    -- แจ้งผู้เล่นว่าให้ป้อนข้อมูลในลักษณะใด
    if inputText == "" then
        Chat:sendSystemMsg("กรุณาป้อนตัวเลข 4 ตัว เช่น '8, 3, 3, 1' เพื่อหาผลลัพธ์ 24.")
    else
        -- แปลงข้อความที่ป้อนเป็นตัวเลข
        local numbers = {}
        for num in string.gmatch(inputText, "%d+") do
            table.insert(numbers, tonumber(num))
        end
        
        -- ตรวจสอบว่าผู้เล่นป้อนข้อมูลครบ 4 ตัวหรือไม่
        if #numbers == 4 then
            find_24(numbers)
        else
            Chat:sendSystemMsg("#Rกรุณาป้อนตัวเลข 4 ตัวที่คั่นด้วยเครื่องหมายจุลภาค (,) เช่น '8, 3, 3, 1'")
        end
    end
end)


