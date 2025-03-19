local result, value = VarLib2:getGlobalVarByName(4, "group1")

-- ตารางสำหรับเก็บตัวแปรที่ประกาศ
local variables = {}
local index = 0
local IfElse = false

local function evaluateCondition(condition)
    -- แทนค่าตัวแปรในเงื่อนไข
    --print("Work !!!")
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
    --print("#### Function is Use")
    IfElse = true

    if string.match(command, "^%s*var%s+([%w_]+)%s+(%a+)%s*=%s*(.+)%s*$") then
        local varName, varType, varValue = string.match(command, "^%s*var%s+([%w_]+)%s+(%a+)%s*=%s*(.+)%s*$")

        -- รองรับตัวแปรประเภท `num`
        if varType == "num" then
            local numericValue = tonumber(varValue)
            if numericValue then
                variables[varName] = numericValue
              --print("Declare variables: " .. varName .. " = " .. numericValue)
             -- Chat:sendSystemMsg("ประกาศตัวแปร: " .. varName .. " = " .. numericValue)
            else
                --print("Error: The value of the variable " .. varName .. " is not a valid number")
                Chat:sendSystemMsg("#Rข้อผิดพลาด: ค่าของตัวแปร " .. varName .. " ไม่ใช่ตัวเลขที่ถูกต้อง")
            end
        elseif varType == "str" then
            varValue = string.match(varValue, '^"(.-)"$') or varValue -- กำจัดเครื่องหมายคำพูด
            variables[varName] = varValue
            --print("Declare variables: " .. varName .. " = " .. varValue)
          --  Chat:sendSystemMsg("ประกาศตัวแปร: " .. varName .. " = " .. varValue)
        else
            --print("Variable types are not supported: " .. varType)
            Chat:sendSystemMsg("#Rประเภทตัวแปรไม่รองรับ: " .. varType)
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
                --print("Error: Unable to process expression - " .. result)
                Chat:sendSystemMsg("#Rข้อผิดพลาด: ไม่สามารถประมวลผลนิพจน์ได้ - " .. result)
                return nil
            end
        end

        local value = evaluateExpression(expression)
        if value ~= nil then
            variables[varName] = value
            --print("Update variables: " .. varName .. " = " .. value)
           -- Chat:sendSystemMsg("อัปเดตตัวแปร: " .. varName .. " = " .. value)
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
                    result = result .. "#Rไม่พบตัวเเปร"
                end
            end
        end
        --print("Sys print: " .. result)
       
       Chat:sendSystemMsg("#G" .. result)
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
        --print("Loveeeee")
        -- ตรวจสอบคำสั่ง var
        if string.match(command, "^%s*var%s+([%w_]+)%s+(%a+)%s*=%s*(.+)%s*$") then
            local varName, varType, varValue = string.match(command, "^%s*var%s+([%w_]+)%s+(%a+)%s*=%s*(.+)%s*$")

            -- รองรับตัวแปรประเภท `num`
            if varType == "num" then
                local numericValue = tonumber(varValue)
                if numericValue then
                    variables[varName] = numericValue
                    --print("Declare variables: " .. varName .. " = " .. numericValue)
                --    Chat:sendSystemMsg("ประกาศตัวแปร: " .. varName .. " = " .. numericValue)
                else
                    --print("Error: The value of the variable " .. varName .. " is not a valid number")
                    Chat:sendSystemMsg("#Rข้อผิดพลาด: ค่าของตัวแปร " .. varName .. " ไม่ใช่ตัวเลขที่ถูกต้อง")
                end
            elseif varType == "str" then
                varValue = string.match(varValue, '^"(.-)"$') or varValue -- กำจัดเครื่องหมายคำพูด
                variables[varName] = varValue
                --print("Declare variables: " .. varName .. " = " .. varValue)
           --     Chat:sendSystemMsg("ประกาศตัวแปร: " .. varName .. " = " .. varValue)
            else
                --print("Variable types are not supported: " .. varType)
                Chat:sendSystemMsg("#Rประเภทตัวแปรไม่รองรับ: " .. varType)
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
                    --print("Error: Unable to process expression - " .. result)
                    Chat:sendSystemMsg("#Rข้อผิดพลาด: ไม่สามารถประมวลผลนิพจน์ได้ - " .. result)
                    return nil
                end
            end

            local value = evaluateExpression(expression)
            if value ~= nil then
                variables[varName] = value
                --print("Update Variable: " .. varName .. " = " .. value)
             --   Chat:sendSystemMsg("อัปเดตตัวแปร: " .. varName .. " = " .. value)
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

            -- ตรวจสอบเงื่อนไข
        elseif string.match(command, "^%s*if%s+(.+)%s+then%s*$") then
            --print("///// if-else work //////") -- Debug
            IfElse = true
            local condition = string.match(command, "^%s*if%s+(.+)%s+then%s*$")
            local evalCondition = evaluateCondition(condition)
            local executeBlock = evalCondition
            local insideIfBlock = evalCondition -- ใช้ตรวจสอบว่าเงื่อนไข if-elseif ผ่านแล้วหรือยัง

            --print("If condition:", condition, "=>", evalCondition) -- Debug

            -- ใช้ลูปเพื่อเช็คเงื่อนไขต่อไปเรื่อยๆ
            local nextIndex = index + 1
            while nextIndex <= #commands do
                local nextCommand = commands[nextIndex]

                -- ตรวจสอบ elseif
                if string.match(nextCommand, "^%s*elseif%s+(.+)%s+then%s*$") then
                    --print("####  Else If ####")
                    local elseifCondition = string.match(nextCommand, "^%s*elseif%s+(.+)%s+then%s*$")

                    if insideIfBlock then
                        executeBlock = false -- ถ้า if ก่อนหน้าผ่านแล้ว ข้าม elseif
                    else
                        evalCondition = evaluateCondition(elseifCondition)
                        executeBlock = evalCondition
                        if evalCondition then
                            insideIfBlock = true
                        end
                    end

                    -- ตรวจสอบ else
                elseif string.match(nextCommand, "^%s*else%s*$") then
                    --print("####  Else ####")
                    if not insideIfBlock then
                        executeBlock = true -- ทำงานเฉพาะถ้า if และ elseif ไม่ผ่านเลย
                        insideIfBlock = true
                    else
                        executeBlock = false -- ป้องกัน else ทำงานซ้ำ
                    end

                    -- ตรวจสอบว่าเป็น end (จบเงื่อนไข if-elseif-else)
                elseif string.match(nextCommand, "^%s*end%s*$") then
                    --print("##### End of if-elseif-else #####")
                    break -- ออกจากลูปทันที

                    -- ประมวลผลคำสั่งภายใน if-elseif-else
                elseif executeBlock then
                    --print("Executing:", nextCommand) -- Debug
                    processCommand(nextCommand)
                end

                nextIndex = nextIndex + 1 -- ไปยังคำสั่งถัดไป
            end

            -- ตรวจสอบคำสั่ง print
        elseif string.match(command, "^%s*print%s*%((.-)%)%s*$") and (IfElse == false) then
            --print("Use Print")
            if not insideConditionBlock then -- ปริ้นต์ได้เฉพาะเมื่อไม่ได้อยู่ในเงื่อนไข if
                --print("#Gทำงาน ปริ้นต์")
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
                            result = result .. "ไม่พบตัวเเปร"
                        end
                    end
                end
                --print("Sys print: " .. result)
                Chat:sendSystemMsg("#G" .. result)
            end
        end
    end
    -- print("#Bดีบั๊ค: " .. index)
else
    --print("Value not found", 0)
    Chat:sendSystemMsg("#Rไม่พบค่า", 0)
end
