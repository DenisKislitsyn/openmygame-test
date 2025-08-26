local Text = {}

local RU_LANG = 1
local langs = { ru = RU_LANG }
local lang_key = 1
local localized = nil

local translate = {
	[RU_LANG] = {
		level = 'Уровень %s',
		level_passed = 'Уровень %s пройден',
		congrats_1 = 'Изумительно!',
		congrats_2 = 'Превосходно!',
		congrats_3 = 'Волшебно!',
		congrats_4 = 'Фантастика!',
		congrats_5 = 'Супер!',
		reload_title = 'Две вкладки с игрой?',
		reload_description = 'Похоже, игра открыта в нескольких вкладках браузера. Чтобы продолжить играть в этой вкладке, обновите страницу.',
		reload = 'Обновить',
	}
}

function Text.initialize()
	local lang = 'ru' -- можно подгружать язык девайса/региона и пр.
	lang_key = lang and langs[lang] or RU_LANG
	localized = translate[lang_key]
end

function Text.get_text()
	return localized
end

return Text