--[[
    Player V3 Class

    Represents a player that can control a Paddle. Computer control only.

    Strategy is to try to anticipate where the ball will cross our "goal"
    line, and head straight there.
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
	self.last_ball_x = 0
	self.last_ball_y = 0
end

--[[
	Player:automove - Called when the computer is controlling the paddle

	paddle_speed: Max speed paddle can move (pixels/s)
	ball_x, ball_y: Current position of ball
]]
function Player:automove(paddle_speed, ball_x, ball_y)

	-- first observation of ball position?
	if self.last_ball_x == 0 or self.last_ball_y == 0 then
		self.last_ball_x = ball_x
		self.last_ball_y = ball_y
		return 0
	end

	-- what is the ball's direction based on last observed position?
	dx = ball_x - self.last_ball_x
	dy = ball_y - self.last_ball_y

	-- is the ball moving towards us?
	movingTowards = false
	if self.playerNumber == 1 and dx < 0 then
		movingTowards = true
	elseif self.playerNumber == 2 and dx > 0 then
		movingTowards = true
	end

	-- update where the ball was for later comparison
	self.last_ball_x = ball_x
	self.last_ball_y = ball_y

    -- method: anticipate where the ball is heading and try and get there
    -- first. If the ball is moving away, head back to the centre(ish)
    if movingTowards then
	    -- y = m * x + b    b = y - mx
	    m = dy / dx
	    b = ball_y - m * ball_x
	    y = m * self.paddle.x + b

	    -- ball will pass at y -- get the paddle there
	    if y < self.paddle.y then
	    	return -paddle_speed
	    elseif y > self.paddle.y + self.paddle.height then
	    	return paddle_speed
	    else
	    	return 0
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

return Player
