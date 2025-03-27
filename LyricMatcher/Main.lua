-- ฐานข้อมูลเนื้อเพลง
local lyrics_db = {
    {title = "Song A", lyrics = "This is the first line of song A"},
    {title = "Song B", lyrics = "Another song with different words"},
    {title = "Song C", lyrics = "A beautiful song with melody"}
}

--คำนวณความคล้ายคลึงกันของข้อความ Levenshtein Distance
function levenshtein(s1, s2)
    local len1, len2 = #s1, #s2
    local matrix = {}
    
    for i = 0, len1 do
        matrix[i] = {}
        matrix[i][0] = i
    end
    
    for j = 0, len2 do
        matrix[0][j] = j
    end
    
    for i = 1, len1 do
        for j = 1, len2 do
            local cost = (s1:sub(i, i) == s2:sub(j, j)) and 0 or 1
            matrix[i][j] = math.min(
                matrix[i-1][j] + 1, --ลบ
                matrix[i][j-1] + 1,--เพิ่ม
                matrix[i-1][j-1] + cost --แทนที่
            )
        end
    end
    
    return matrix[len1][len2]
end

--ทำนายเพลงจากเนื้อเพลงที่ป้อน,k
function find_best_match(input_lyrics)
    local best_match = nil
    local best_score = math.huge --กำหนดค่าเริ่มต้นให้เป็นค่ามากที่สุด
    
    for _, song in ipairs(lyrics_db) do
        local score = levenshtein(input_lyrics, song.lyrics)
        if score < best_score then
            best_score = score
            best_match = song.title
        end
    end
    
    return best_match, best_score
end

local user_input = "This is the first line of song A"
local song_name, similarity_score = find_best_match(user_input)
print("Match: "..song_name .." (score "..similarity_score ..")")
