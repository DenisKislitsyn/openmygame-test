local Line = {}
Line.__index = Line

local press_point = vmath.vector3()
local line_points = {}
local v_length = vmath.length
local line_in_drawing = nil
local t_insert = table.insert

local window_h, window_w = 1280, 720
local screen_h, screen_w = 1280, 720

local function calc_fit_h()
	return (screen_h/screen_w)*window_w
end

local function calc_fit_w()
	return (screen_w/screen_h)*window_h
end
local fit_h, fit_w = calc_fit_h(), calc_fit_w()

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

	self.root = gui.get_node('line')
	self.dot_node = dot_node
	self.segments = {}
	self.context = context

	self:on_resize()

	return self
end

function Line:on_resize()
	screen_w, screen_h = window.get_size()
	fit_h, fit_w = calc_fit_h(), calc_fit_w()
end

function Line:clear()
	for _, segment in ipairs(self.segments) do
		for _, dot in ipairs(segment.dots) do
			gui.delete_node(dot)
		end
	end
	self.segments = {}
end

function Line:add(start_point_node)
	local segment = {}
	segment.start_point_node = start_point_node
	segment.start_point = gui.screen_to_local(self.root, gui.get_screen_position(segment.start_point_node))
	segment.start_point.x = segment.start_point.x * math.max(1, fit_w/window_w)
	segment.start_point.y = segment.start_point.y * math.max(1, fit_h/window_h)
	segment.length = 0
	segment.dots = {}
	segment.handle_start =  vmath.vector3()
	segment.handle_press = vmath.vector3()

	-- дорисовываем старый путь если есть
	if #self.segments > 0 then
		set_dots(self, self.segments[#self.segments], segment.start_point)
	end

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
	press_point.x = action.x * math.max(1, fit_w/window_w)
	press_point.y = action.y * math.max(1, fit_h/window_h)

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