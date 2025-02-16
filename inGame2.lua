local result, value = VarLib2:getGlobalVarByName(4, "group1")

-- ตารางสำหรับเก็บตัวแปรที่ประกาศ
local variables = {}
local index = 0

local function evaluateCondition(condition)
    -- แทนค่าตัวแปรในเงื่อนไข
    for varName, varValue in pairs(variables) do
        condition = string.gsub(condition, "%f[%w_]" .. varName .. "%f[%W_]", tostring(varValue))
    end

    local result = false

    -- ฟังก์ชันช่วยในการดึงค่าตัวแปรหรือเปลี่ยนเป็นตัวเลข
    local function getVarValue(var)
        if variables[var] then
            return variables[var]       -- ถ้าเป็นตัวแปร ให้ใช้ค่าของมัน
        else
            return tonumber(var) or var -- ถ้าเป็นตัวเลข แปลงเป็นตัวเลข มิฉะนั้นให้ใช้ค่าเดิม (สำหรับสตริง)
        end
    end

    -- ตรวจสอบประเภทของเงื่อนไข
    local var1, var2 = string.match(condition, "^%s*(%w+)%s*==%s*(%w+)%s*$")
    if var1 and var2 then
        if getVarValue(var1) == getVarValue(var2) then
            result = true
        end
    end

    var1, var2 = string.match(condition, "^%s*(%w+)%s*!=%s*(%w+)%s*$")
    if var1 and var2 then
        if getVarValue(var1) ~= getVarValue(var2) then
            result = true
        end
    end

    var1, var2 = string.match(condition, "^%s*(%w+)%s*<%s*(%w+)%s*$")
    if var1 and var2 then
        if getVarValue(var1) < getVarValue(var2) then
            result = true
        end
    end

    var1, var2 = string.match(condition, "^%s*(%w+)%s*>%s*(%w+)%s*$")
    if var1 and var2 then
        if getVarValue(var1) > getVarValue(var2) then
            result = true
        end
    end

    var1, var2 = string.match(condition, "^%s*(%w+)%s*<=%s*(%w+)%s*$")
    if var1 and var2 then
        if getVarValue(var1) <= getVarValue(var2) then
            result = true
        end
    end

    var1, var2 = string.match(condition, "^%s*(%w+)%s*>=%s*(%w+)%s*$")
    if var1 and var2 then
        if getVarValue(var1) >= getVarValue(var2) then
            result = true
        end
    end

    return result
end

local function processCommand(command)
    Chat:sendSystemMsg("#G ฟังชั่นถูกเรียกใช้ ")
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
    end
end

local insideConditionBlock = false -- เพิ่มตัวแปรควบคุม
local Test = 0

if value then
    -- สร้างอาเรย์เพื่อเก็บคำสั่งที่แยกออกมา
    local commands = {}

    -- แยกคำสั่งโดยใช้ "@|&" เป็นตัวแบ่ง
    for cmd in string.gmatch(value, "([^@|&]+)") do
        table.insert(commands, cmd)
    end

    -- ฟังก์ชันประมวลผลคำสั่งทีละบรรทัด
    for index, command in ipairs(commands) do
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
            if not insideConditionBlock then -- ปริ้นต์ได้เฉพาะเมื่อไม่ได้อยู่ในเงื่อนไข if
                --Chat:sendSystemMsg("#Gทำงาน ปริ้นต์")
                local expression = string.match(command, "^%s*print%s*%((.-)%)%s*$")

                -- แยกนิพจน์และคำนวณค่าตัวแปรที่ใช้
                local result = ""
                for part in string.gmatch(expression, '([^%+]+)') do
                    part = part:match("^%s*(.-)%s*$")  -- ตัดช่องว่างออก
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
            -- ตรวจสอบคำสั่ง for loop
        elseif string.match(command, "^%s*for%s+(%w+)%s*=%s*(%d+),%s*(%d+)%s*do%s*$") then
            local varName, startVal, endVal = string.match(command, "^%s*for%s+(%w+)%s*=%s*(%d+),%s*(%d+)%s*do%s*$")
            startVal, endVal = tonumber(startVal), tonumber(endVal)
            variables[varName] = startVal

            -- รวบรวมคำสั่งภายในลูป
            local loopCommands = {}
            local i = index + 1

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
                for index, loopCmd in ipairs(loopCommands) do
                    processCommand(loopCmd)
                end
            end

            -- ตรวจสอบคำสั่ง while loop
        elseif string.match(command, "^%s*while%s+(.+)%s+do%s*$") then
            local condition = string.match(command, "^%s*while%s+(.+)%s+do%s*$")

            -- รวบรวมคำสั่งภายในลูป
            local loopCommands = {}
            local i = index + 1
            while i <= #commands and not commands[i]:match("^%s*end%s*$") do
                table.insert(loopCommands, commands[i])
                i = i + 1
            end

            -- รันลูป
            while evaluateExpression(condition) do
                for index, loopCmd in ipairs(loopCommands) do
                    processCommand(loopCmd)
                end
            end
            -- ตรวจสอบคำสั่ง if else elseif
        elseif string.match(command, "^%s*if%s+(.+)%s+then%s*$") then
            local condition = string.match(command, "^%s*if%s+(.+)%s+then%s*$")
            local evalCondition = evaluateCondition(condition)
            local executeBlock = evalCondition
            local foundElse = false
            local insideIfBlock = false -- ป้องกันการรันซ้ำ
            insideConditionBlock = true -- ตั้งค่าเมื่อเข้า if

            local i = index + 1
            --local b = 0
            while i <= #commands do
                local nextCommand = commands[i]

                if string.match(nextCommand, "^%s*elseif%s+(.+)%s+then%s*$") then
                    if insideIfBlock then
                        executeBlock = false -- ปิดการทำงานของ elseif ถ้า if หรือ elseif ก่อนหน้านี้เป็นจริง
                    else
                        local elseifCondition = string.match(nextCommand, "^%s*elseif%s+(.+)%s+then%s*$")
                        evalCondition = evaluateCondition(elseifCondition)
                        executeBlock = evalCondition
                        if evalCondition then insideIfBlock = true end
                    end
                    break -- หยุดการทำงานของ `for`
                elseif string.match(nextCommand, "^%s*else%s*$") then
                    if insideIfBlock then
                        executeBlock = false -- ข้าม else ถ้ามีเงื่อนไขที่เป็นจริงก่อนหน้า
                    else
                        executeBlock = true
                        foundElse = true
                        insideIfBlock = true
                    end
                elseif string.match(nextCommand, "^%s*end%s*$") then
                    insideConditionBlock = false -- รีเซ็ตค่าเมื่อออกจาก if
                    break                        -- ออกจาก loop ทันทีเมื่อเจอ end
                elseif executeBlock and not insideIfBlock then
                    --b = b + 1
                    processCommand(nextCommand)
                    insideIfBlock = true -- ป้องกันการรันซ้ำ
                    --Chat:sendSystemMsg("#Gรอบ เงื่อนไขทำงาน: " .. b)
                    break                -- หยุดการตรวจสอบเงื่อนไขเพิ่มเติม
                end
                i = i + 1
            end
        elseif string.match(command, "^%s*end%s*$") then
            insideConditionBlock = false -- รีเซ็ตสถานะเมื่อเจอคำสั่ง end
            break        
        else
            Test = Test + 1
            Chat:sendSystemMsg("#Rคำสั่งไม่ถูกต้อง: " .. "#B รอบทำงาน" .. Test)
            --Chat:sendSystemMsg("#Bดีบั๊ค: " .. tostring(index))
        end
    end
   -- Chat:sendSystemMsg("#Bดีบั๊ค: " .. index)
else
    Chat:sendSystemMsg("#Rไม่พบค่า", 0)
end
