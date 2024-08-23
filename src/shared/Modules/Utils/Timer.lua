--[[
	self.timer = Timer:startTimer({
		endTime = when timer will stop,
		updateFunction = function(timeLeft)
			function that runs every tick of the timer
		end,
	})
]]

local Promise = require(game.ReplicatedStorage.Packages.Promise)

local Timer = {}
Timer.__index = Timer
Timer.TAG_NAME = "Timer"

-- endTime and updateFunction
function Timer:startTimer(timerData)
	if self.timer then
		self.timer:cancel()
	end

	task.wait()

	return Promise.new(function(resolve, _, onCancel)
		local timerCancelled = false

		onCancel(function()
			timerCancelled = true
		end)

		while true do
			if timerCancelled then
				resolve({
					timerCompleted = false,
				})
			end

			if timerData.updateFunction then
				local timeLeft = timerData.endTime - os.time()
				timerData.updateFunction(timeLeft)
			end

			if os.time() > timerData.endTime then
				resolve({
					timerCompleted = true,
				})
			end

			task.wait()
		end
	end)
end

return Timer
