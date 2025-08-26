local cell = require 'screens.game.modules.cell'

local Word = {}

local POSITION_X = 'position.x'
local vector_0 = vmath.vector3()
local cell_dx = 10

function Word.set_cells(word)
	local cell_size = cell.dimensions.size_x * cell.dimensions.scale_x
	word.x = #word.cells * cell_size + (#word.cells - 1) * cell_dx
	local pos_x = -word.x/2 + cell_size / 2
	for _, c in ipairs(word.cells) do
		gui.set(c.nodes.root, POSITION_X, pos_x)
		pos_x = pos_x + cell_size + cell_dx
	end
end

function Word.add_cell(word, char, cell_prefab, state)
	local cell_obj = cell.new(cell_prefab, char)
	gui.set_parent(cell_obj.nodes.root, word.root)
	table.insert(word.cells, cell_obj)
	Word.set_cells(word)
end

function Word.remove_cell(word)
	gui.delete_node(word.cells[#word.cells].nodes.root)
	word.cells[#word.cells] = nil
	Word.set_cells(word)
end

function Word.clear_cells(word)
	for _, c in ipairs(word.cells) do
		gui.delete_node(c.nodes.root)
	end
	word.cells = {}
end

function Word.set_cells_state(word, state)
	for _, c in ipairs(word.cells) do
		cell.set_state(c, state)
	end
end

function Word.new(chars, root_prefab, cell_prefab)
	local word = {}
	word.root = gui.clone(root_prefab)
	word.cells = {}
	word.x = 0
	word.y = cell.dimensions.size_y * cell.dimensions.scale_y
	word.pos = vector_0

	for k, char in ipairs(chars) do
		Word.add_cell(word, char, cell_prefab)
	end

	Word.set_cells(word)

	return word
end

return Word