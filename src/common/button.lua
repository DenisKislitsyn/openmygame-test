local PRESSED_BUTTON_SCALE = vmath.vector3(0.95)
local NORMAL_BUTTON_SCALE = vmath.vector3(1)
local SHAKE_EASING = vmath.vector({ -1, 0, 1, 0, -0.6, 0, 0.6, 0 })
local ANIMATION_TIME = 0.2
local PROP_Z = 'position.z'
local PROP_ROTATION_Z = 'euler.z'

local Button = {}
Button.__index = Button

function Button.new(context, node_name, handler)
	local self = setmetatable({}, Button)
	assert(handler)
	assert(node_name)
	self.node = type(node_name) == 'string' and gui.get_node(node_name) or node_name
	self.handler = handler
	self.button_pressed = false
	self.disabled = false
	self.locked = false
	self.context = context
	return self
end

function Button:set_handler(handler)
	assert(handler)
	self.handler = handler
end

function Button:press()
	gui.animate(self.node, gui.PROP_SCALE, PRESSED_BUTTON_SCALE, gui.EASING_OUTBACK, ANIMATION_TIME)
	self.button_pressed = true
end

function Button:release()
	gui.animate(self.node, gui.PROP_SCALE, NORMAL_BUTTON_SCALE, gui.EASING_OUTBACK, ANIMATION_TIME)
	self.button_pressed = false
end

function Button:disable()
	gui.set_enabled(self.node, false)
	self.disabled = true
	if self.button_pressed then
		self:release()
	end
end

function Button:enable()
	gui.set_enabled(self.node, true)
	self.disabled = false
end

function Button:set_enabled(value)
	if value then
		self:enable()
	else
		self:disable()
	end
end

function Button:set_locked(value, anim_duration)
	self.locked = value and true or false
	gui.animate(self.node, PROP_Z, self.locked and 1 or 0, gui.EASING_LINEAR, anim_duration or 0)
end

local function animate_shake(_, node)
	gui.animate(node, PROP_ROTATION_Z, 12, SHAKE_EASING, 0.2, 0.01)
end

function Button:shake()
	gui.animate(self.node, PROP_ROTATION_Z, 0, gui.EASING_LINEAR, 0, 0, animate_shake)
end

function Button:on_input(action)
	if not self.disabled and not self.locked then
		if action.pressed then
			if gui.pick_node(self.node, action.x, action.y) then
				self:press()
				return true
			end
		elseif action.released and self.button_pressed then
			self:release()
			if gui.pick_node(self.node, action.x, action.y) then
				self.handler(self.context)
				return true
			end
		end
	end
	return false
end

return Button
