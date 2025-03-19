local value = [[
    var age num = 18@|&
    if age > 20@|&
    print("อายุมากกว่า 20")@|&
    else@|&
    print("อายุไม่ถึง 20")
]]

if value ~= nil and value ~= "" then
    -- ตารางสำหรับเก็บตัวแปร
    local variables = {}

    -- แยกคำสั่งออกจากกัน
    local commands = {}
    for cmd in string.gmatch(value, "([^@%|&]+)") do
        table.insert(commands, cmd)
    end

    -- ประมวลผลแต่ละคำสั่ง
    for _, command in ipairs(commands) do
        -- ตรวจสอบคำสั่ง var
        if string.match(command, "^%s*var%s+([%w_]+)%s+(%a+)%s*=%s*(.+)%s*$") then
            local varName, varType, varValue = string.match(command, "^%s*var%s+([%w_]+)%s+(%a+)%s*=%s*(.+)%s*$")

            -- รองรับตัวแปรประเภท `num`
            if varType == "num" then
                local numericValue = tonumber(varValue)
                if numericValue then
                    variables[varName] = numericValue
                    print("ประกาศตัวแปร: " .. varName .. " = " .. numericValue)
                else
                    print("ข้อผิดพลาด: ค่าของตัวแปร " .. varName .. " ไม่ใช่ตัวเลขที่ถูกต้อง")
                end
            elseif varType == "str" then
                varValue = string.match(varValue, '^"(.-)"$') or varValue -- กำจัดเครื่องหมายคำพูด
                variables[varName] = varValue
                print("ประกาศตัวแปร: " .. varName .. " = " .. varValue)
            else
                print("ประเภทตัวแปรไม่รองรับ: " .. varType)
            end

            -- ตรวจสอบคำสั่งกำหนดค่าให้ตัวแปร
        elseif string.match(command, "^%s*([%w_]+)%s*=%s*(.+)%s*$") then
            local varName, expression = string.match(command, "^%s*([%w_]+)%s*=%s*(.+)%s*$")

            -- แยกนิพจน์และประมวลผล
            local function evaluateExpression(expr)
                local result = expr

                -- แทนค่าตัวแปรลงในนิพจน์
                for varName, varValue in pairs(variables) do
                    if type(varValue) == "number" then
                        expr = string.gsub(expr, "%f[%w_]" .. varName .. "%f[%W_]", varValue)
                    end
                end

                -- รองรับการดำเนินการทางคณิตศาสตร์
                local status, result = pcall(function()
                    -- แทนการใช้ load() จะต้องคำนวณเอง
                    local total = 0
                    local parts = {}
                    local operators = {}

                    -- แยกนิพจน์ออกเป็นตัวเลขและเครื่องหมาย
                    for num, op in string.gmatch(expr, "([%d%.]+)%s*([%+%-%*/]?)") do
                        table.insert(parts, tonumber(num))
                        if op ~= "" then
                            table.insert(operators, op)
                        end
                    end

                    -- คำนวณค่าของนิพจน์
                    if #parts > 0 then
                        total = parts[1]
                        for i = 2, #parts do
                            local operator = operators[i - 1]
                            local number = parts[i]
                            if operator == "+" then
                                total = total + number
                            elseif operator == "-" then
                                total = total - number
                            elseif operator == "*" then
                                total = total * number
                            elseif operator == "/" then
                                total = total / number
                            end
                        end
                    end

                    return total
                end)

                if status then
                    return result
                else
                    print("ข้อผิดพลาด: ไม่สามารถประมวลผลนิพจน์ได้ - " .. result)
                    return nil
                end
            end

            local value = evaluateExpression(expression)
            if value ~= nil then
                variables[varName] = value
                print("อัปเดตตัวแปร: " .. varName .. " = " .. value)
            end

            -- ตรวจสอบคำสั่ง print
        elseif string.match(command, "^%s*print%s*%((.-)%)%s*$") then
            local expression = string.match(command, "^%s*print%s*%((.-)%)%s*$")

            -- แยกนิพจน์และคำนวณค่าตัวแปรที่ใช้
            local result = ""
            for part in string.gmatch(expression, '([^%+]+)') do
                part = part:match("^%s*(.-)%s*$")      -- ตัดช่องว่างออก
                if string.match(part, '^".*"$') then
                    result = result .. part:sub(2, -2) -- ถ้าเป็นสตริงก็นำมาใส่
                else
                    -- ถ้าไม่ใช่สตริง คาดว่ามันเป็นตัวแปร
                    local varValue = variables[part]
                    if varValue then
                        result = result .. varValue
                    else
                        result = result .. "ไม่พบตัวแปร"
                    end
                end
            end
            print("คำสั่ง print: " .. result)
            -- ตรวจสอบคำสั่ง if
        elseif string.match(command, "^%s*if%s+(.+)%s*$") then
            local condition = string.match(command, "^%s*if%s+(.+)%s*$")

            -- ตรวจสอบเงื่อนไข
            local function evaluateCondition(cond)
                -- แทนค่าตัวแปรในเงื่อนไข
                for varName, varValue in pairs(variables) do
                    cond = string.gsub(cond, "%f[%w_]" .. varName .. "%f[%W_]", tostring(varValue))
                end

                -- ประมวลผลเงื่อนไขด้วย load()
                local status, result = pcall(function()
                    return load("return " .. cond)()
                end)
                if status then
                    return result
                else
                    print("ข้อผิดพลาด: เงื่อนไขไม่ถูกต้อง - " .. cond)
                    return false
                end
            end

            -- ตรวจสอบว่าเงื่อนไขเป็นจริงหรือไม่
            if evaluateCondition(condition) then
                print("เงื่อนไขเป็นจริง: " .. condition)
            else
                print("เงื่อนไขเป็นเท็จ: " .. condition)
            end

            -- ตรวจสอบคำสั่ง else
        elseif string.match(command, "^%s*else%s*$") then
            print("เข้าสู่คำสั่ง else")
        else
            print("คำสั่งไม่ถูกต้อง: " .. command)
        end
    end
else
    print("value is nil or empty", 0)
end
