-- Dependencies --
local Roact = require(game.ReplicatedStorage.Packages.roact)
local Flipper = require(game.ReplicatedStorage.Packages.flipper)
local Janitor = require(game.ReplicatedStorage.Packages.Janitor)

-- Variables --
local createElement = Roact.createElement

local TweeningFrame = Roact.Component:extend("TweeningFrame")

function TweeningFrame:updateVisbile()
	if self.props.Visible == self.prevVisible then
		return
	end

	self.prevVisible = self.props.Visible

	self.tweenPosMotorJanitor:Cleanup()
	if self.props.Visible then
		self.tweenPosMotor = Flipper.SingleMotor.new(1.5)
		self.tweenPosMotor:onStep(self.updateFramePos)

		self.updateFinalVisible(true)
		self.tweenPosMotor:setGoal(Flipper.Spring.new(0.5))
	else
		self.tweenPosMotor = Flipper.SingleMotor.new(0.5)
		self.tweenPosMotor:onStep(self.updateFramePos)

		self.tweenPosMotor:setGoal(Flipper.Spring.new(-0.5))
	end

	self.tweenPosMotor:onComplete(function()
		self.updateFinalVisible(self.props.Visible)
	end)
	self.tweenPosMotorJanitor:Add(self.tweenPosMotor, "stop")
end

function TweeningFrame:init()
	-- self.tweenPosMotor = Flipper.SingleMotor.new(1.5)
	self.framePos, self.updateFramePos = Roact.createBinding(1.5)
	-- self.tweenPosMotor:onStep(self.updateFramePos)

	self.tweenPosMotorJanitor = Janitor.new()

	self.finalVisible, self.updateFinalVisible = Roact.createBinding(false)

	self.prevVisible = false
end

function TweeningFrame:render()
	return createElement("Frame", {
		AnchorPoint = self.props.theme.ap.center,
		Position = self.framePos:map(function(xPos)
			return UDim2.fromScale(xPos, 0.5)
		end),
		-- BackgroundTransparency = 1,
		Size = self.props.theme.size,
		BackgroundColor3 = self.props.BackgroundColor3,
		BackgroundTransparency = self.props.BackgroundTransparency,
		Visible = self.finalVisible,
	}, self.props[Roact.Children])
end

function TweeningFrame:didMount()
	self:updateVisbile()
end

function TweeningFrame:didUpdate()
	self:updateVisbile()
end

return TweeningFrame
