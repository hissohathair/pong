--[[
    GD50 2018
    Pong Remake

    -- Player V2 Class --

    Represents a player that can control a Paddle. Computer control only.

    Strategy is to try and stick in the centre between hits, and hit the ball
    with the edges of the paddle to force as much angle as possible.
]]

local Player = Class{}
local MY_NAME = 'PlayerV2'

--[[
	Player:init

	playerNumber: 1 or 2
	paddle:	Instance of Paddle class that we control
]]
function Player:init(playerNumber, paddle, ball_size)
	self.playerNumber = playerNumber
	self.paddle = paddle
	self.ball_size = ball_size
	self.last_ball_x = 0
	self.last_ball_y = 0
end

--[[
	Player:automove - Called when the computer is controlling the paddle

	paddle_speed: Max speed paddle can move (pixels/s)
	ball_x, ball_y: Current position of ball
]]
function Player:automove(paddle_speed, ball_x, ball_y)
	-- is the ball moving towards us?
	movingTowards = true
	if self.playerNumber == 1 and self.last_ball_x < ball_x then
		movingTowards = false
	elseif self.playerNumber == 2 and self.last_ball_x > ball_x then
		movingTowards = false
	end

	-- update where the ball was for later comparison
	self.last_ball_x = ball_x
	self.last_ball_y = ball_y

    -- simple method: track the ball when it's coming towards us, centre the
    -- paddle when it's moving away
    if movingTowards then
	    if ball_y < self.paddle.y + self.ball_size / 2 then
	        return -paddle_speed
	    elseif ball.y > self.paddle.y + self.paddle.height - self.ball_size / 2 then
	        return paddle_speed
	    end
	else
		if self.paddle.y < VIRTUAL_HEIGHT / 3 then
			return paddle_speed
		elseif self.paddle.y + self.paddle.height > VIRTUAL_HEIGHT * 0.66 then
			return -paddle_speed
		end
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
