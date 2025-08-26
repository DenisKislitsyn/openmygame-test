local utils = require 'screens.game.modules.game_utils'

local InputLetter = {}
InputLetter.__index = InputLetter

local bg_icons = {
	[true] = 'letter_picked',
	[false] = 'letter_unpicked'
}
local text_colors = {
	[true] = vmath.vector3(1),
	[false] = vmath.vector3(88/255,89/255,91/255)
}

function InputLetter.new(context, prefab, char)
	local self = setmetatable({}, InputLetter)
	assert(char)

	local node_data = gui.clone_tree(prefab)
	self.nodes = {
		root = node_data[hash('input_letter')],
		bg = node_data[hash('input_letter_bg')],
		text = node_data[hash('input_letter_text')]
	}
	self.char = char
	self.picked = false
	self.context = context

	gui.set_text(self.nodes.text, utils.to_upper(self.char))
	self:set_state()
	
	return self
end

function InputLetter:set_state()
	gui.play_flipbook(self.nodes.bg, bg_icons[self.picked])
	gui.set_color(self.nodes.text, text_colors[self.picked])
end

function InputLetter:on_input(action)
	if action then
		if gui.pick_node(self.nodes.bg, action.x, action.y) then
			if not self.picked then
				return true
			elseif self.picked and self.second_last then
				return true
			end
		end

		if action.released then
			self.picked = false
			self:set_state()
		end
	end
	return false
end

return InputLetter