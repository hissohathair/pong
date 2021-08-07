--[[
    GD50 2018
    Pong Remake

    -- Player Class --

    Represents a player that can control a Paddle. This implementation is
    computer only, with the same method as the "default" Player class.
]]

local Player = Class{}

--[[
	Player:init

	playerNumber: 1 or 2
	paddle:	Instance of Paddle class that we control
]]
function Player:init(playerNumber, paddle, ball_size)
	self.playerNumber = playerNumber
	self.paddle = paddle
	self.ball_size = ball_size
end


--[[
	Player:automove - Called when the computer is controlling the paddle

	paddle_speed: Max speed paddle can move (pixels/s)
	ball_x, ball_y: Current position of ball
]]
function Player:automove(paddle_speed, ball_x, ball_y)
	-- simple method: track the ball
    if ball_y < self.paddle.y + self.ball_size then
        return -paddle_speed
    elseif ball.y > self.paddle.y + self.paddle.height - self.ball_size then
        return paddle_speed
    end
    return 0
end

return Player
