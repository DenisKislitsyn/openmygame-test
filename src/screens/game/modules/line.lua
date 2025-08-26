local Line = {}
Line.__index = Line

local press_point = vmath.vector3()
local line_points = {}
local v_length = vmath.length
local line_in_drawing = nil
local t_insert = table.insert

local function cubic_bezier_points(a, handle_a, b, handle_b, step)
	line_points = {}
	t_insert(line_points, a)

	local t = 0
	local prev = a
	local dt = 0.005  -- шаг по t для итерации

	while t < 1 do
		t = t + dt
		if t > 1 then t = 1 end

		local p = ((1-t)^3) * a
		+ 3 * ((1-t)^2) * t * (a + handle_a)
		+ 3 * (1-t) * (t^2) * (b + handle_b)
		+ (t^3) * b

		local delta = p - prev
		local dist = v_length(delta)

		if dist >= step then
			t_insert(line_points, p)
			prev = p
		end
	end

	return line_points
end

local function set_dots(self, segment, finish_pos)
	local curve_points = cubic_bezier_points(segment.start_point, segment.handle_start, finish_pos, segment.handle_press, 1)
	
	for i=1, #curve_points do
		if segment.dots[i] == nil then
			segment.dots[i] = gui.clone(self.dot_node)
			gui.set_parent(segment.dots[i], self.root)
		end
		gui.set_position(segment.dots[i], curve_points[i])
	end

	if #segment.dots > #curve_points then
		for i = #segment.dots, #curve_points, -1 do
			if segment.dots[i] then
				gui.delete_node(segment.dots[i])
			end
			segment.dots[i] = nil
		end
	end
end

function Line.new(context, dot_node)
	local self = setmetatable({}, Line)

	self.root = gui.get_node('input_letters_root')
	self.action_delta = gui.get_screen_position(self.root)
	self.dot_node = dot_node
	self.segments = {}
	self.context = context

	return self
end

function Line:on_resize()
	self.action_delta = gui.get_screen_position(self.root)
end

function Line:clear()
	for _, segment in ipairs(self.segments) do
		for _, dot in ipairs(segment.dots) do
			gui.delete_node(dot)
		end
	end
	self.segments = {}
end

function Line:add(start_point)
	-- дорисовываем старый путь если есть
	if #self.segments > 0 then
		set_dots(self, self.segments[#self.segments], start_point)
	end
	
	local segment = {}
	segment.start_point = start_point
	segment.length = 0
	segment.dots = {}
	segment.handle_start =  vmath.vector3()
	segment.handle_press = vmath.vector3()

	t_insert(self.segments, segment)
end

function Line:remove_last()
	for _, dot in ipairs(self.segments[#self.segments].dots) do
		gui.delete_node(dot)
	end
	self.segments[#self.segments] = nil
end

function Line:draw(action)
	-- only last line
	line_in_drawing = self.segments[#self.segments]
	press_point.x = action.screen_x
	press_point.y = action.screen_y
	press_point = press_point - self.action_delta

	if #self.segments > 1 then
		self.segments[#self.segments-1].handle_press = -(press_point - self.segments[#self.segments-1].start_point) / 5
		line_in_drawing.handle_start = (press_point - self.segments[#self.segments-1].start_point) / 5
		set_dots(self, self.segments[#self.segments-1], line_in_drawing.start_point)
	end

	set_dots(self, line_in_drawing, press_point)
end

function Line:on_input(action)
	if action then
		self:draw(action)
		if action.released then
			self:clear()
		end
	end
end


return Line