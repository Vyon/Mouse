--[[
	[Signal.lua]

	@Contructor:
		Creates self's metatable + signal info I.E. BindableEvent and Connections
	@Connect:
		Parameters: <callback: function>
		Creates connection to the original bindable for cleanup at a later time
	@Fire:
		Parameters: <...: any>
		Self Explanitory
	@Disconnect:
		Disconnections and removes any found connections in self.Connections
	@Destroy:
		Parameters: <self: table>
		Disconnects any connections, destroys the bindable, sets the bindable to nil and cleans up the signal object for gc
--]]

local signal = {}
signal.__index = signal

function signal:Connect(callback)
	if (typeof(callback) ~= 'function') then return end

	table.insert(self.Connections, self.Bindable.Event:Connect(callback))
end

function signal:Fire(...)
	self.Bindable:Fire(...)
end

function signal:Destroy()
	for i, v in ipairs(self.Connections) do
		v:Disconnect()
		table.remove(self.Connections, i)
	end

	self.Bindable:Destroy()

	self.Bindable = nil

	setmetatable(self, nil)
end

return {
	New = function()
		local self = {}
		self.Bindable = Instance.new('BindableEvent')
		self.Connections = {}

		return setmetatable(self, signal)
	end
}