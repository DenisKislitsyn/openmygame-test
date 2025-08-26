local savetable = require 'ludobits.m.io.savetable'
local save_file = 'gamedata'
local save_data = savetable.load(save_file)

local M = {}

local def_save = {
	level = 1,
	launch_time = 0,
	level_data = {
		founded_words = {}
	}
}

function M.save(key, value)
	if key then
		save_data[key] = value
	end
	savetable.save(save_data, save_file)
end

function M.load(key)
	return save_data[key]
end

function M.initialize()
	if not save_data or not next(save_data) then
		save_data = def_save
		M.save()
	end
end

return M
