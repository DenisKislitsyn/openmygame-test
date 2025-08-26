local utils = require 'screens.game.modules.game_utils'

local Cell = {}
Cell.states = {
	EMPTY = 1,
	CORRECT = 2,
	INCORRECT = 3,
	BASE = 4
}
Cell.dimensions = {
	size_x = 72,
	size_y = 72,
	scale_x = 1.1,
	scale_y = 1.1
}

local bg_colors = {
	[Cell.states.EMPTY] = vmath.vector3(1),
	[Cell.states.CORRECT] = vmath.vector3(101/255,189/255,101/255),
	[Cell.states.INCORRECT] = vmath.vector3(229/255,67/255,67/255),
	[Cell.states.BASE] = vmath.vector3(1),
}
local text_colors = {
	[Cell.states.EMPTY] = vmath.vector3(0),
	[Cell.states.CORRECT] = vmath.vector3(1),
	[Cell.states.INCORRECT] = vmath.vector3(1),
	[Cell.states.BASE] = vmath.vector3(88/255,89/255,91/255)
}

function Cell.new(prefab, char)
	local node_data = gui.clone_tree(prefab)
	local cell = {}
	cell.nodes = {
		root = node_data[hash('cell')],
		bg = node_data[hash('cell_bg')],
		text = node_data[hash('cell_text')]
	}
	cell.char = char
	Cell.set_state(cell, Cell.states.EMPTY)

	return cell
end

function Cell.set_state(cell, state)
	gui.set_color(cell.nodes.bg, bg_colors[state])
	gui.set_color(cell.nodes.text, text_colors[state])
	gui.set_text(cell.nodes.text, state == Cell.states.EMPTY and "" or utils.to_upper(cell.char))
end


return Cell