local M = {}

local levels_path = "/res/levels/%s.json"
local letter_utf = "[%z\1-\127\194-\244][\128-\191]*"
local cyrillic_upper = {
	["а"] = "А", ["б"] = "Б", ["в"] = "В", ["г"] = "Г", ["д"] = "Д", ["е"] = "Е",
	["ё"] = "Ё", ["ж"] = "Ж", ["з"] = "З", ["и"] = "И", ["й"] = "Й", ["к"] = "К",
	["л"] = "Л", ["м"] = "М", ["н"] = "Н", ["о"] = "О", ["п"] = "П", ["р"] = "Р",
	["с"] = "С", ["т"] = "Т", ["у"] = "У", ["ф"] = "Ф", ["х"] = "Х", ["ц"] = "Ц",
	["ч"] = "Ч", ["ш"] = "Ш", ["щ"] = "Щ", ["ы"] = "Ы", ["э"] = "Э", ["ю"] = "Ю",
	["я"] = "Я"
}

local function get_word_chars(word)
	local chars = {}
	for ch in word:gmatch(letter_utf) do
		table.insert(chars, ch)
	end

	return chars
end

function M.get_words_by_level(level)
	local level_file = sys.load_resource(string.format(levels_path, tostring(level)))
	local words_list = json.decode(level_file).words
	local data = {}
	for _, word in ipairs(words_list) do
		table.insert(data, {
			str = word,
			list = get_word_chars(word) 
		})
	end
	
	return data
end

function M.get_unique_chars(words)
	local chars_by_count = {}

	for _, word in ipairs(words) do
		local word_chars = {}
		for ch in word.str:gmatch(letter_utf) do
			word_chars[ch] = word_chars[ch] and word_chars[ch] + 1 or 1
		end

		for ch, count in pairs(word_chars) do
			chars_by_count[ch] = chars_by_count[ch] and math.max(chars_by_count[ch], count) or count
		end
	end

	local chars_by_list = {}
	for ch, count in pairs(chars_by_count) do
		for i = 1, count do
			table.insert(chars_by_list, ch)
		end
	end

	return chars_by_list
end

function M.to_upper(char)
	return cyrillic_upper[char] or string.upper(char)
end

return M