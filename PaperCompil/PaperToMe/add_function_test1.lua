-- ชุดคำสั่งที่จะถูก Interpreter ประมวลผล
local value = [[
    var i num = 1@|&
    var Gg num = 5@|&
    var Ans num = 0@|&
    func multiply_table do@|&
        var local_i num = 1@|&
        for local_i = 1, 3 do@|&
            var func_Ans num = 0@|&
            func_Ans = local_i * Gg@|&
            print("Func: "+local_i+" X "+Gg+" = "+func_Ans)@|&
        end@|&
    endfunc@|&
    for i = 1, 2 do@|&
        Ans = i*Gg@|&
        print(i+" X "+Gg+" = "+Ans)@|&
        call multiply_table@|&
    end@|&
    print("End of program")
]]

-- Stack สำหรับเก็บขอบเขตของตัวแปร (แต่ละตารางใน stack คือหนึ่งขอบเขต)
local variables_stack = {{}} -- เริ่มต้นด้วยขอบเขต Global

-- ตารางสำหรับเก็บนิยามของฟังก์ชัน
local functions = {}

-- ฟังก์ชันช่วยในการดึงขอบเขตตัวแปรปัจจุบัน
local function getCurrentScope()
    return variables_stack[#variables_stack]
end

-- ฟังก์ชันช่วยในการค้นหาตัวแปรในขอบเขตปัจจุบันและขอบเขตแม่ๆ
local function findVariable(varName)
    for i = #variables_stack, 1, -1 do
        if variables_stack[i][varName] ~= nil then
            return variables_stack[i][varName]
        end
    end
    return nil -- ไม่พบตัวแปร
end

-- ฟังก์ชันช่วยในการกำหนดค่าตัวแปรในขอบเขตปัจจุบัน หรืออัปเดตหากมีอยู่ในขอบเขตแม่
local function setVariable(varName, value)
    for i = #variables_stack, 1, -1 do
        if variables_stack[i][varName] ~= nil then
            variables_stack[i][varName] = value
            return
        end
    end
    -- ถ้าไม่พบในขอบเขตแม่ใดๆ ให้กำหนดในขอบเขตปัจจุบัน
    getCurrentScope()[varName] = value
end

-- ฟังก์ชันสำหรับประเมินเงื่อนไข (เช่นใน if, while)
local function evaluateCondition(condition)
    -- แทนที่ชื่อตัวแปรด้วยค่าของมันจากขอบเขตปัจจุบัน
    local current_condition = condition
    for varName, varValue in pairs(getCurrentScope()) do
        current_condition = string.gsub(current_condition, "%f[%w_]" .. varName .. "%f[%W_]", tostring(varValue))
    end

    local result = false

    -- ฟังก์ชันช่วยในการดึงค่าตัวแปรหรือเปลี่ยนเป็นตัวเลข
    local function getVarValue(var)
        local val = findVariable(var) -- ใช้ findVariable เพื่อค้นหาค่าตัวแปร
        if val ~= nil then
            return val
        else
            return tonumber(var) or var
        end
    end

    -- ตรวจสอบประเภทของเงื่อนไข (==, !=, <, >, <=, >=)
    local var1, var2 = string.match(current_condition, "^%s*(%w+)%s*==%s*(%w+)%s*$")
    if var1 and var2 then
        if getVarValue(var1) == getVarValue(var2) then
            result = true
        end
    end

    var1, var2 = string.match(current_condition, "^%s*(%w+)%s*!=%s*(%w+)%s*$")
    if var1 and var2 then
        if getVarValue(var1) ~= getVarValue(var2) then
            result = true
        end
    end

    var1, var2 = string.match(current_condition, "^%s*(%w+)%s*<%s*(%w+)%s*$")
    if var1 and var2 then
        if getVarValue(var1) < getVarValue(var2) then
            result = true
        end
    end

    var1, var2 = string.match(current_condition, "^%s*(%w+)%s*>%s*(%w+)%s*$")
    if var1 and var2 then
        if getVarValue(var1) > getVarValue(var2) then
            result = true
        end
    end

    var1, var2 = string.match(current_condition, "^%s*(%w+)%s*<=%s*(%w+)%s*$")
    if var1 and var2 then
        if getVarValue(var1) <= getVarValue(var2) then
            result = true
        end
    end

    var1, var2 = string.match(current_condition, "^%s*(%w+)%s*>=%s*(%w+)%s*$")
    if var1 and var2 then
        if getVarValue(var1) >= getVarValue(var2) then
            result = true
        end
    end

    return result
end

-- Forward declaration สำหรับ executeCommandsBlock เพื่อให้สามารถเรียกใช้แบบ recursive ได้
local executeCommandsBlock

-- ฟังก์ชันสำหรับประมวลผลคำสั่งพื้นฐาน (var, assignment, print, call)
local function processCommand(command)
    local current_scope = getCurrentScope()

    -- การประกาศตัวแปร (var)
    if string.match(command, "^%s*var%s+([%w_]+)%s+(%a+)%s*=%s*(.+)%s*$") then
        local varName, varType, varValue = string.match(command, "^%s*var%s+([%w_]+)%s+(%a+)%s*=%s*(.+)%s*$")
        if varType == "num" then
            local numericValue = tonumber(varValue)
            if numericValue then
                current_scope[varName] = numericValue
                print("Declare variables: " .. varName .. " = " .. numericValue)
            else
                print("Error: The value of the variable " .. varName .. " is not a valid number.")
            end
        elseif varType == "str" then
            varValue = string.match(varValue, '^"(.-)"$') or varValue
            current_scope[varName] = varValue
            print("Declare variables: " .. varName .. " = " .. varValue)
        else
            print("Variable types are not supported.: " .. varType)
        end
    -- การกำหนดค่าตัวแปร (assignment)
    elseif string.match(command, "^%s*([%w_]+)%s*=%s*(.+)%s*$") then
        local varName, expression = string.match(command, "^%s*([%w_]+)%s*=%s*(.+)%s*$")

        local function evaluateExpression(expr)
            local current_expr = expr
            -- แทนที่ชื่อตัวแปรด้วยค่าของมันจากขอบเขตปัจจุบัน/ขอบเขตแม่
            for i = #variables_stack, 1, -1 do
                for vName, vValue in pairs(variables_stack[i]) do
                    if type(vValue) == "number" then
                        current_expr = string.gsub(current_expr, "%f[%w_]" .. vName .. "%f[%W_]", tostring(vValue))
                    end
                end
            end

            local status, result = pcall(function()
                local total = 0
                local parts = {}
                local operators = {}

                -- แยกนิพจน์ออกเป็นตัวเลขและเครื่องหมาย
                for num, op in string.gmatch(current_expr, "([%d%.]+)%s*([%+%-%*/]?)") do
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
                                if number == 0 then error("Division by zero") end -- ป้องกันหารด้วยศูนย์
                            total = total / number
                        end
                    end
                end
                return total
            end)

            if status then
                return result
            else
                print("Error: Unable to process expression '" .. expr .. "' - " .. result)
                return nil
            end
        end

        local value_expr = evaluateExpression(expression)
        if value_expr ~= nil then
            setVariable(varName, value_expr) -- ใช้ setVariable เพื่อจัดการขอบเขต
            print("Update variables: " .. varName .. " = " .. value_expr)
        end
    -- คำสั่ง Print
    elseif string.match(command, "^%s*print%s*%((.-)%)%s*$") then
        local expression = string.match(command, "^%s*print%s*%((.-)%)%s*$")
        local result_str = ""
        for part in string.gmatch(expression, '([^%+]+)') do
            part = part:match("^%s*(.-)%s*$")
            if string.match(part, '^".*"$') then
                result_str = result_str .. part:sub(2, -2)
            else
                local varValue = findVariable(part) -- ใช้ findVariable
                if varValue ~= nil then
                    result_str = result_str .. tostring(varValue)
                else
                    result_str = result_str .. "Variable '" .. part .. "' not found"
                end
            end
        end
        print("Sys print: " .. result_str)
    -- การเรียกใช้ฟังก์ชัน (call)
    elseif string.match(command, "^%s*call%s+([%w_]+)%s*$") then
        local func_name = string.match(command, "^%s*call%s+([%w_]+)%s*$")
        if functions[func_name] then
            print("Calling function: " .. func_name)
            table.insert(variables_stack, {}) -- Push ขอบเขตใหม่สำหรับฟังก์ชัน
            executeCommandsBlock(functions[func_name].body) -- เรียกใช้บล็อกคำสั่งของฟังก์ชัน
            table.remove(variables_stack) -- Pop ขอบเขตของฟังก์ชันออก
            print("Finished function: " .. func_name)
        else
            print("Error: Function '" .. func_name .. "' not found.")
        end
    end
end

-- ฟังก์ชันนี้จะประมวลผลบล็อกของคำสั่ง (เช่น บล็อกของ for loop, if block, function body)
function executeCommandsBlock(commands_block)
    local current_block_index = 1
    while current_block_index <= #commands_block do
        local command = commands_block[current_block_index]
        command = string.gsub(command, "^%s*(.-)%s*$", "%1") -- ตัดช่องว่างหัวท้าย

        -- For Loop
        if string.match(command, "^%s*for%s+([%w_]+)%s*=%s*(%d+),%s*(%d+)%s*do%s*$") then
            local varName, startVal, endVal = string.match(command, "^%s*for%s+(%w+)%s*=%s*(%d+),%s*(%d+)%s*do%s*$")
            startVal, endVal = tonumber(startVal), tonumber(endVal)

            local loopCommands = {}
            local i = current_block_index + 1
            local level = 0 -- สำหรับจัดการบล็อกที่ซ้อนกัน
            local loop_end_found = false
            while i <= #commands_block do
                local cmd = commands_block[i]
                if cmd:match("^%s*for%s+.*do%s*$") or cmd:match("^%s*while%s+.*do%s*$") or cmd:match("^%s*if%s+.*then%s*$") or cmd:match("^%s*func%s+.*do%s*$") then
                    level = level + 1
                elseif cmd:match("^%s*end%s*$") then
                    if level == 0 then
                        loop_end_found = true
                        break
                    else
                        level = level - 1
                    end
                end
                table.insert(loopCommands, cmd)
                i = i + 1
            end
            if not loop_end_found then
                print("Error: 'end' not found for for loop starting at line " .. current_block_index)
                return
            end

            for val = startVal, endVal do
                setVariable(varName, val) -- กำหนดค่าตัวแปร loop ในขอบเขตปัจจุบัน
                executeCommandsBlock(loopCommands) -- เรียกใช้บล็อกคำสั่งของ loop แบบ recursive
            end
            current_block_index = i -- ข้ามบล็อก loop ที่ถูกประมวลผลไปแล้ว
        -- While Loop
        elseif string.match(command, "^%s*while%s+(.+)%s+do%s*$") then
            local condition = string.match(command, "^%s*while%s+(.+)%s+do%s*$")

            local loopCommands = {}
            local i = current_block_index + 1
            local level = 0
            local loop_end_found = false
            while i <= #commands_block do
                local cmd = commands_block[i]
                if cmd:match("^%s*for%s+.*do%s*$") or cmd:match("^%s*while%s+.*do%s*$") or cmd:match("^%s*if%s+.*then%s*$") or cmd:match("^%s*func%s+.*do%s*$") then
                    level = level + 1
                elseif cmd:match("^%s*end%s*$") then
                    if level == 0 then
                        loop_end_found = true
                        break
                    else
                        level = level - 1
                    end
                end
                table.insert(loopCommands, cmd)
                i = i + 1
            end
            if not loop_end_found then
                print("Error: 'end' not found for while loop starting at line " .. current_block_index)
                return
            end

            while evaluateCondition(condition) do
                executeCommandsBlock(loopCommands)
            end
            current_block_index = i
        -- If-Elseif-Else Block
        elseif string.match(command, "^%s*if%s+(.+)%s+then%s*$") then
            local block_start_index = current_block_index
            local block_end_index = -1

            local level = 0
            local i = current_block_index + 1
            while i <= #commands_block do
                local cmd = commands_block[i]
                if cmd:match("^%s*if%s+.*then%s*$") or cmd:match("^%s*for%s+.*do%s*$") or cmd:match("^%s*while%s+.*do%s*$") or cmd:match("^%s*func%s+.*do%s*$") then
                    level = level + 1
                elseif cmd:match("^%s*end%s*$") then
                    if level == 0 then
                        block_end_index = i
                        break
                    else
                        level = level - 1
                    end
                end
                i = i + 1
            end

            if block_end_index == -1 then
                print("Error: 'end' not found for if block starting at line " .. block_start_index)
                return
            end

            local current_eval_index = block_start_index
            local executed_a_block = false

            while current_eval_index < block_end_index do
                local current_cmd_line = commands_block[current_eval_index]
                local condition_met = false
                local block_to_execute = {}
                local next_block_start_index = current_eval_index + 1

                if current_cmd_line:match("^%s*if%s+(.+)%s+then%s*$") then
                    local cond = string.match(current_cmd_line, "^%s*if%s+(.+)%s+then%s*$")
                    condition_met = evaluateCondition(cond)
                elseif current_cmd_line:match("^%s*elseif%s+(.+)%s+then%s*$") then
                    local cond = string.match(current_cmd_line, "^%s*elseif%s+(.+)%s+then%s*$")
                    if not executed_a_block then -- ประเมิน elseif ก็ต่อเมื่อบล็อกก่อนหน้า (if/elseif) ไม่ได้ถูกประมวลผล
                        condition_met = evaluateCondition(cond)
                    end
                elseif current_cmd_line:match("^%s*else%s*$") then
                    if not executed_a_block then -- ประมวลผล else ก็ต่อเมื่อบล็อกก่อนหน้า (if/elseif) ไม่ได้ถูกประมวลผล
                        condition_met = true
                    end
                else
                    current_eval_index = current_eval_index + 1
                    continue
                end

                -- รวบรวมคำสั่งสำหรับบล็อก if/elseif/else ปัจจุบัน
                local j = next_block_start_index
                local inner_level = 0
                while j <= block_end_index do
                    local next_cmd = commands_block[j]
                    if next_cmd:match("^%s*if%s+.*then%s*$") or next_cmd:match("^%s*for%s+.*do%s*$") or next_cmd:match("^%s*while%s+.*do%s*$") or next_cmd:match("^%s*func%s+.*do%s*$") then
                        inner_level = inner_level + 1
                    elseif next_cmd:match("^%s*end%s*$") then
                        if inner_level == 0 then
                            break -- พบจุดสิ้นสุดของบล็อกเงื่อนไขปัจจุบัน
                        else
                            inner_level = inner_level - 1
                        end
                    elseif inner_level == 0 and (next_cmd:match("^%s*elseif%s+.*then%s*$") or next_cmd:match("^%s*else%s*$")) then
                        break -- พบจุดเริ่มต้นของเงื่อนไขถัดไปในระดับเดียวกัน
                    end
                    table.insert(block_to_execute, next_cmd)
                    j = j + 1
                end

                if condition_met then
                    executeCommandsBlock(block_to_execute)
                    executed_a_block = true
                    break -- ออกจาก loop การประมวลผล if-elseif-else หลังจากประมวลผลไปหนึ่งบล็อก
                end
                current_eval_index = j -- เลื่อนไปยัง elseif/else/end ถัดไป
            end
            current_block_index = block_end_index -- ข้ามบล็อก if-elseif-else ทั้งหมด
        -- การประกาศฟังก์ชัน (func)
        elseif string.match(command, "^%s*func%s+([%w_]+)%s*do%s*$") then
            local func_name = string.match(command, "^%s*func%s+([%w_]+)%s*do%s*$")
            local func_body = {}
            local i = current_block_index + 1
            local func_end_found = false
            local level = 0 -- สำหรับจัดการบล็อกที่ซ้อนกันภายในฟังก์ชัน

            while i <= #commands_block do
                local cmd = commands_block[i]
                if cmd:match("^%s*for%s+.*do%s*$") or cmd:match("^%s*while%s+.*do%s*$") or cmd:match("^%s*if%s+.*then%s*$") or cmd:match("^%s*func%s+.*do%s*$") then
                    level = level + 1
                elseif cmd:match("^%s*endfunc%s*$") then
                    if level == 0 then
                        func_end_found = true
                        break
                    else
                        level = level - 1
                    end
                elseif cmd:match("^%s*end%s*$") then -- 'end' สำหรับบล็อกภายใน (for/while/if)
                    if level > 0 then
                        level = level - 1
                    end
                end
                table.insert(func_body, cmd)
                i = i + 1
            end
            if not func_end_found then
                print("Error: 'endfunc' not found for function '" .. func_name .. "' starting at line " .. current_block_index)
                return
            end
            functions[func_name] = { body = func_body }
            print("Declared function: " .. func_name)
            current_block_index = i -- ข้ามบล็อกฟังก์ชันที่ถูกประมวลผลไปแล้ว
        -- คำสั่งพื้นฐานอื่นๆ (var, assignment, print, call)
        else
            processCommand(command)
        end
        current_block_index = current_block_index + 1
    end
end

-- บล็อกการทำงานหลักของ Interpreter
if value then
    local commands = {}
    -- แยกคำสั่งโดยใช้ "@|&" เป็นตัวแบ่ง และกรองคำสั่งที่เป็นช่องว่างออก
    for cmd in string.gmatch(value, "([^@|&]+)") do
        local trimmed_cmd = string.gsub(cmd, "^%s*(.-)%s*$", "%1")
        if trimmed_cmd ~= "" then
            table.insert(commands, trimmed_cmd)
        end
    end
    executeCommandsBlock(commands)
else
    print("Value not found", 0)
end
