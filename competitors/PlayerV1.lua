--[[
    GD50 2018
    Pong Remake

    -- Player Class --

    Represents a player that can control a Paddle. This implementation is
    computer only, with the same method as the "default" Player class.
]]

local Player = Class{}
local MY_NAME = 'PlayerV1'

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

--[[
	Player.notify_result: Called by mail.lua to tell the `Player` instance the
	result of a round.

	result: 'won' or 'missed' for this player
	ball_x, ball_y: Position of the ball at the time of result
	paddle: Instance of the *losing* paddle at time of result - this is always
		the paddle that "missed", not necessarily the paddle this instance
		controls
]]
function Player:notify_result(result, ball, paddle)
	msg = string.format('LOG: {"event": "%s", "name": "%s", "p": %d, ', result, MY_NAME, self.playerNumber)
	msg = msg .. string.format('"ball": {"pos": [%d, %d], "mov": [%d, %d], "speed": %.2f, "m": %.2f}, ', 
								ball.x, ball.y, ball.dx, ball.dy, ball:speed(), ball.dy / ball.dx)
	msg = msg .. string.format('"paddle": {"top": %d, "bot": %d, "dy": %d}},', paddle.y, paddle.y + paddle.height, paddle.dy)
	if result == 'missed' then
	    print(msg)
	end
end

return Player
