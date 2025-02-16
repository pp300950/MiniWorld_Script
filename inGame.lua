
####มีบัคที่การฟอลูป  เมื่อสั่งลุป1-3ครั้งระบบปริ้น 1-3เเต่เเถม3เพิ่มอีกตัว 



local result, value = VarLib2:getGlobalVarByName(4, "group1")

-- ตารางสำหรับเก็บตัวแปรที่ประกาศ
local variables = {}
if value then
    -- สร้างอาเรย์เพื่อเก็บคำสั่งที่แยกออกมา
    local commands = {}

    -- แยกคำสั่งโดยใช้ "@|&" เป็นตัวแบ่ง
    for cmd in string.gmatch(value, "([^@|&]+)") do
        table.insert(commands, cmd)
    end



    -- ฟังก์ชันประมวลผลคำสั่งทีละบรรทัด
    for _, command in ipairs(commands) do
        -- ตรวจสอบคำสั่ง var
        if string.match(command, "^%s*var%s+([%w_]+)%s+(%a+)%s*=%s*(.+)%s*$") then
            local varName, varType, varValue = string.match(command, "^%s*var%s+([%w_]+)%s+(%a+)%s*=%s*(.+)%s*$")

            -- รองรับตัวแปรประเภท `num`
            if varType == "num" then
                local numericValue = tonumber(varValue)
                if numericValue then
                    variables[varName] = numericValue
                    Chat:sendSystemMsg("ประกาศตัวแปร: " .. varName .. " = " .. numericValue)
                else
                    Chat:sendSystemMsg("ข้อผิดพลาด: ค่าของตัวแปร " .. varName .. " ไม่ใช่ตัวเลขที่ถูกต้อง")
                end
            elseif varType == "str" then
                varValue = string.match(varValue, '^"(.-)"$') or varValue -- กำจัดเครื่องหมายคำพูด
                variables[varName] = varValue
                Chat:sendSystemMsg("ประกาศตัวแปร: " .. varName .. " = " .. varValue)
            else
                Chat:sendSystemMsg("ประเภทตัวแปรไม่รองรับ: " .. varType)
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
                    Chat:sendSystemMsg("ข้อผิดพลาด: ไม่สามารถประมวลผลนิพจน์ได้ - " .. result)
                    return nil
                end
            end

            local value = evaluateExpression(expression)
            if value ~= nil then
                variables[varName] = value
                Chat:sendSystemMsg("อัปเดตตัวแปร: " .. varName .. " = " .. value)
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
            Chat:sendSystemMsg("คำสั่ง print: " .. result)
            -- ตรวจสอบคำสั่ง for loop
        elseif string.match(command, "^%s*for%s+(%w+)%s*=%s*(%d+),%s*(%d+)%s*do%s*$") then
            local varName, startVal, endVal = string.match(command, "^%s*for%s+(%w+)%s*=%s*(%d+),%s*(%d+)%s*do%s*$")
            startVal, endVal = tonumber(startVal), tonumber(endVal)
            variables[varName] = startVal

            -- รวบรวมคำสั่งภายในลูป

            local loopCommands = {}
            local i = _ + 1

            local function processCommand(command)
                if string.match(command, "^%s*var%s+([%w_]+)%s+(%a+)%s*=%s*(.+)%s*$") then
                    local varName, varType, varValue = string.match(command, "^%s*var%s+([%w_]+)%s+(%a+)%s*=%s*(.+)%s*$")

                    -- รองรับตัวแปรประเภท `num`
                    if varType == "num" then
                        local numericValue = tonumber(varValue)
                        if numericValue then
                            variables[varName] = numericValue
                            Chat:sendSystemMsg("ประกาศตัวแปร: " .. varName .. " = " .. numericValue)
                        else
                            Chat:sendSystemMsg("ข้อผิดพลาด: ค่าของตัวแปร " .. varName .. " ไม่ใช่ตัวเลขที่ถูกต้อง")
                        end
                    elseif varType == "str" then
                        varValue = string.match(varValue, '^"(.-)"$') or varValue -- กำจัดเครื่องหมายคำพูด
                        variables[varName] = varValue
                        Chat:sendSystemMsg("ประกาศตัวแปร: " .. varName .. " = " .. varValue)
                    else
                        Chat:sendSystemMsg("ประเภทตัวแปรไม่รองรับ: " .. varType)
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
                            Chat:sendSystemMsg("ข้อผิดพลาด: ไม่สามารถประมวลผลนิพจน์ได้ - " .. result)
                            return nil
                        end
                    end

                    local value = evaluateExpression(expression)
                    if value ~= nil then
                        variables[varName] = value
                        Chat:sendSystemMsg("อัปเดตตัวแปร: " .. varName .. " = " .. value)
                    end

                    -- ตรวจสอบคำสั่ง print
                elseif string.match(command, "^%s*print%s*%((.-)%)%s*$") then
                    local expression = string.match(command, "^%s*print%s*%((.-)%)%s*$")

                    -- แยกนิพจน์และคำนวณค่าตัวแปรที่ใช้
                    local result = ""
                    for part in string.gmatch(expression, '([^%+]+)') do
                        part = part:match("^%s*(.-)%s*$") -- ตัดช่องว่างออก
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
                    Chat:sendSystemMsg("คำสั่ง print: " .. result)
                end
            end
            while i <= #commands do
                if commands[i]:match("^%s*end%s*$") then
                    break -- หยุดเมื่อเจอ `end`
                end
                table.insert(loopCommands, commands[i])
                i = i + 1
            end


            -- รันลูป
            for i = startVal, endVal do
                variables[varName] = i
                for _, loopCmd in ipairs(loopCommands) do
                    processCommand(loopCmd)
                end
            end

            -- ตรวจสอบคำสั่ง while loop
        elseif string.match(command, "^%s*while%s+(.+)%s+do%s*$") then
            local condition = string.match(command, "^%s*while%s+(.+)%s+do%s*$")

            -- รวบรวมคำสั่งภายในลูป
            local loopCommands = {}
            local i = _ + 1
            while i <= #commands and not commands[i]:match("^%s*end%s*$") do
                table.insert(loopCommands, commands[i])
                i = i + 1
            end

            -- รันลูป
            while evaluateExpression(condition) do
                for _, loopCmd in ipairs(loopCommands) do
                    processCommand(loopCmd)
                end
            end
        else
            Chat:sendSystemMsg("คำสั่งไม่ถูกต้อง: " .. command)
        end
    end
else
    Chat:sendSystemMsg("ไม่พบค่า", 0)
end
