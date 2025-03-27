math.randomseed(os.time())

function linear(x)
    return x
end

-- ค่าพารามิเตอร์ที่ฝึกแล้ว
w1 = 0.3896200904417
w2 = 0.43518750954113
b = 0.1238546632071

-- ฟังก์ชันทำนายผลลัพธ์
function predict(x1, x2)
    local weighted_sum = x1 * w1 + x2 * w2 + b
    return linear(weighted_sum)
end

function generate_question(difficulty_level)
    local ranges = {
        {0, 10}, {10, 100}, {100, 1000}, {1000, 10000}, {10000, 100000},
        {1000000, 10000000}, {1000000000, 10000000000}, {100000000000000, 1000000000000000},
        {1, 100000000000000000000}
    }
    local min_val, max_val = table.unpack(ranges[math.min(difficulty_level, #ranges)])
    return math.random(min_val, max_val), math.random(min_val, max_val)
end

function test_bot_capability()
    local correct_answers, wrong_answers, total_questions = 0, 0, 1000
    local max_value, difficulty_level = 50, 1
    
    print("\nเริ่มการทดสอบความสามารถของบอท!\n")
    print(string.rep("=", 40))
    
    for i = 1, total_questions do
        local num1, num2 = math.random(1, max_value * difficulty_level), math.random(1, max_value * difficulty_level)
        local correct_answer = num1 + num2
        local x1, x2 = num1 / (max_value * difficulty_level), num2 / (max_value * difficulty_level)
        local predicted_answer = predict(x1, x2) * (2 * max_value * difficulty_level)
        
        if math.floor(predicted_answer + 0.5) == correct_answer then
            correct_answers = correct_answers + 1
            result = "[ถูกต้อง]"
        else
            wrong_answers = wrong_answers + 1
            result = "[ผิด] คำตอบที่ถูกต้องคือ " .. correct_answer
        end
        
        print("โจทย์ " .. i .. ": " .. num1 .. " + " .. num2 .. " = " .. math.floor(predicted_answer + 0.5) .. " --> " .. result)

        -- ป้องกันการค้างหากค่าผิดมากเกินไป
        if wrong_answers >= 3 then
            print("\n[การทดสอบสิ้นสุด: บอทตอบผิดครบ 3 ครั้ง]\n")
            break
        end
        
        if i % 5 == 0 then
            difficulty_level = difficulty_level * 2
            print("\nเพิ่มระดับความยากแบบทวีคูณ!\n")
            print(string.rep("-", 40))
        end
    end
    
    local accuracy = (correct_answers / total_questions) * 100
    summarize_results("ทดสอบความสามารถ", total_questions, correct_answers, wrong_answers, accuracy)
end

function test_bot_accuracy()
    local correct_answers, wrong_answers, total_questions, max_value = 0, 0, 0, 50
    
    print("\nเริ่มการทดสอบความแม่นยำของบอท!\n")
    print(string.rep("=", 40))
    
    while wrong_answers < 5 and correct_answers < 1000 do
        total_questions = total_questions + 1
        
        local num1, num2
        if total_questions % 5 == 0 then
            num1 = math.random(1, 99) * 10000 * 99999999
            num2 = math.random(1, 99) * 10000 * 99999999
        else
            num1 = math.random(1, 99)
            num2 = math.random(1, 99)
        end
        
        local correct_answer = num1 + num2
        local x1, x2 = num1 / max_value, num2 / max_value
        local predicted_answer = predict(x1, x2) * (2 * max_value)
        
        if math.floor(predicted_answer + 0.5) == correct_answer then
            correct_answers = correct_answers + 1
            result = "[ถูกต้อง]"
        else
            wrong_answers = wrong_answers + 1
            result = "[ผิด] คำตอบที่ถูกต้องคือ " .. correct_answer
        end
        
        print("โจทย์: " .. num1 .. " + " .. num2 .. " = " .. math.floor(predicted_answer + 0.5) .. " --> " .. result)
        local accuracy = (correct_answers / 1000) * 100
        print("ความแม่นยำหลังจากตอบ " .. total_questions .. " ข้อ: " .. string.format("%.2f", accuracy) .. "%")
        
    end
    
    local accuracy = (correct_answers / 1000) * 100
    summarize_results("ทดสอบความแม่นยำ", total_questions, correct_answers, wrong_answers, accuracy)
end

function summarize_results(mode, total_questions, correct_answers, wrong_answers, accuracy)
    print("\nผลการทดสอบโมเดล (" .. mode .. "):")
    print("+----------------------------+------------+")
    print("| รายการ                   | จำนวน    |")
    print("+----------------------------+------------+")
    print("| จำนวนคำถามทั้งหมด   | " .. total_questions .. "          |")
    print("| คำตอบที่ถูกต้อง         | " .. correct_answers .. "          |")
    print("| คำตอบที่ผิด              | " .. wrong_answers .. "          |")
    print("+----------------------------+------------+")
    print("| ความแม่นยำ              | " .. string.format("%.2f", accuracy) .. "%    |")
    print("+----------------------------+------------+")
end

print("เริ่มการทดสอบเเล้วหน้าาาา\n")
test_bot_capability()
test_bot_accuracy()
