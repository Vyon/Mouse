-- Services
local run_service = game:GetService('RunService')
local user_input_service = game:GetService('UserInputService')

-- Locals
local camera = workspace.CurrentCamera

-- Modules
local signal = require(script.Parent.Signal)

-- Main Module
local mouse = {}

return {
	New = function()
		local position = user_input_service:GetMouseLocation()
		local unit_ray = camera:ScreenPointToRay(position.X, position.Y)

		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {}
		params.FilterType = Enum.RaycastFilterType.Blacklist

		-- 3D Variables
		local ray = Ray.new(unit_ray.Origin, unit_ray.Direction * 100)
		local raycast = workspace:Raycast(ray.Origin, ray.Direction, params)
		local target = raycast and raycast.Instance
		local normal = raycast and raycast.Normal

		-- Self
		local self = {}

		-- Properties
		self.Hit = target and target.CFrame
		self.Origin = CFrame.new(unit_ray.Origin)
		self.Target = target
		self.UnitRay = unit_ray
		self.X = position.X
		self.Y = position.Y
		self.Vector = position
		self.TargetFilter = nil
		self.TargetSurface = normal

		-- RBXScriptSignals
		self.Button1Down = signal.New()
		self.Button2Down = signal.New()
		self.Button1Up = signal.New()
		self.Button2Up = signal.New()
		self.WheelMoved = signal.New()
		self.Move = signal.New()
		self.Idle = signal.New()

		-- Create Signal Connections
		do
			-- Variables
			local isIdle = true

			-- UserInput Listeners
			user_input_service.InputBegan:Connect(function(input, game_processed_event)
				if (game_processed_event) then return end

				if (input.UserInputType == Enum.UserInputType.MouseButton1) then
					isIdle = false

					self.Button1Down:Fire()
				elseif (input.UserInputType == Enum.UserInputType.MouseButton2) then
					isIdle = false
					self.Button2Down:Fire()
				end
			end)

			user_input_service.InputChanged:Connect(function(input)
				if (input.UserInputType == Enum.UserInputType.MouseMovement) then

					-- Forgot to add this lol
					if (typeof(self.TargetFilter) == 'Instance') then
						params.FilterDescendantsInstances = self.TargetFilter:GetChildren()
					end

					-- Reuse Variables
					position = input.Position
					unit_ray = camera:ScreenPointToRay(position.X, position.Y)
					ray = Ray.new(unit_ray.Origin, unit_ray.Direction * 100)
					raycast = workspace:Raycast(ray.Origin, ray.Direction, params)
					target = raycast and raycast.Instance
					normal = raycast and raycast.Normal

					-- Set Mouse Properties
					self.Hit = target and target.CFrame
					self.Origin = CFrame.new(unit_ray.Origin)
					self.Target = target
					self.UnitRay = unit_ray
					self.X = position.X
					self.Y = position.Y
					self.Vector = position
					self.TargetSurface = normal

					self.Move:Fire()
				elseif (input.UserInputType == Enum.UserInputType.MouseWheel) then
					self.WheelMoved:Fire()
				end
			end)

			user_input_service.InputEnded:Connect(function(input)
				if (input.UserInputType == Enum.UserInputType.MouseButton1) then
					isIdle = true
					self.Button1Up:Fire()
				elseif (input.UserInputType == Enum.UserInputType.MouseButton2) then
					isIdle = true
					self.Button2Up:Fire()
				end
			end)

			run_service.Heartbeat:Connect(function()
				if (isIdle) then
					self.Idle:Fire() -- In the mouse class it doesn't account for mouse movement for some reason
				end
			end)
		end

		return setmetatable(self, mouse) --> The only reason it's like this because I want to use OOP :)
	end
}
