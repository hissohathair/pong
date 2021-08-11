--[[
    Player V4 Class

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
	self.last_target_y = 0
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

	-- enough of a delta for accurate prediction?
	if math.abs(dx) > self.ball_size * 2 or math.abs(dy) > self.ball_size * 2 then
		-- update where the ball was for later comparison
		self.last_ball_x = ball_x
		self.last_ball_y = ball_y
	end

    -- method: anticipate where the ball is heading and try and get there
    -- first. If the ball is moving away, head back to the centre(ish)
    if movingTowards then
	    -- y = m * x + b    b = y - mx    x = (y - b) / m
	    m = dy / dx
	    b = ball_y - m * ball_x
	    y = m * self.paddle.x + b

	    -- if y is < 0 or > VIRTUAL_HEIGHT then it's going to hit an edge and
	    -- bounce first...
	    if y < 0 then
	    	-- ball will hit the top, but where?
	    	x = (0 - b) / m
	    	m = -dy / dx
	    	b = 0 - m * x 
	    	y = m * self.paddle.x + b
	    elseif y > VIRTUAL_HEIGHT then
	    	-- ball will hit the bottom, but where?
	    	x = (VIRTUAL_HEIGHT - b) / m
	    	m = -dy / dx
	    	b = VIRTUAL_HEIGHT - m * x
	    	y = m * self.paddle.x + b 
	    end

    	self.last_target_y = y

	    -- ball will pass at y -- get the paddle there
	    if y < self.paddle.y + self.ball_size then
	    	return -paddle_speed
	    elseif y > self.paddle.y + self.paddle.height - self.ball_size then
	    	return paddle_speed
	    else
	    	return 0
	    end
	else
		if self.paddle.y < VIRTUAL_HEIGHT / 4 then
			return paddle_speed
		elseif self.paddle.y + self.paddle.height > VIRTUAL_HEIGHT * 0.75 then
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
	msg = string.format('LOG: {"event": "%s", "name": "PlayerV4", "p": %d, ', result, self.playerNumber)
	msg = msg .. string.format('"ball": {"pos": [%d, %d], "mov": [%d, %d], "m": %.2f}, ', ball.x, ball.y, ball.dx, ball.dy, ball.dy / ball.dx)
	msg = msg .. string.format('"ytarget": %d, ', self.last_target_y)
	msg = msg .. string.format('"paddle": {"pos": [%d, %d], "dy": %d}}', paddle.y, paddle.y + paddle.height, paddle.dy)
	if result == 'missed' then
	    print(msg)
	end
end

return Player
