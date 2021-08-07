# Pong Clone

Good [ol' Pong](https://en.wikipedia.org/wiki/Pong). Thanks Atari!
 
The original code in this project is from [Project 0](https://cs50.harvard.edu/games/2018/projects/0/) from HarvardX's [CS50 Introduction to Game Development](https://learning.edx.org/course/course-v1:HarvardX+CS50G+Games/home). The course includes an assignment to implement an "AI player".

# Goal

Writing a version where different computer players (I think calling them "AI" is setting the AI bar way too low) can play against each other. This time we want to make it difficult for a computer player to cheat.

# Changes to CS50

The Pong implementation from the CS50 course allowed a ball to "pass through" a paddle once the ball exceeded a certain speed. The collision detector never had a chance to kick in, because the ball went from "just in front of" to "just behind" the paddle in a single step. I "fixed" that by "clipping" the ball to the x coordinate of a paddle if it passed through too quickly.

As a consequence stalemates occured when my computer player played itself. Very boring.

The problem was that the ball's velocity was dominated by the dx movement. The horizontal movement was increased 3% after each hit, however the vertical movement was a random value between -50 and 50. As the ball accelerated at each "hit" of the paddle it eventually moved very fast back and forth with relatively little vertical movement. In the end the paddles hardly needed to move at all. 

Prior to my changes the collision detector there would be no stalemate because one side would "win" simply because the ball was moving too fast for *any* player to intercept. This seemed a bit unfair and random so I wanted to end stalemates in a way that players felt they could control (either manually or by coding a better computer player).

The original game of Pong allowed the player some control over the angle of deflection when the ball bounced off the paddle. If the ball hit the paddle's edge, it would bounce off at an acute angle. If it hit the middle of the paddle, it bounced off at a right angle. This behaviour could be useful.

# Current Status

* Fixed the `Ball` class so that vertical movement is retained, even at high speeds
* Ball deflection angle is no longer random, but is determined by where it hits the paddle. More acute angles are achieved by hitting the ball towards an edge of the paddle

Next:

* Pass different `Player` classes to the game and have it print out the winner
* Check this Pong implementation against the [original Pong mechanics](https://gamemechanics.fandom.com/wiki/Pong)

Later:

* Use Lua's method of making member variables "private" (see [Programming in Lua, s16.4](https://www.lua.org/pil/16.4.html)) to protect `Paddle` instances from direct manipulation by `Player`s 

# Rules (Mechanics)

Implemented:

* Like the original, the paddle is divided into 8 segments, and the angle that the ball is deflected off the paddle is determined by which segment it hits
* Vertical movement of the ball is now scaled with horizontal movement. It's now possible for a ball to move so fast a paddle can't intercept it (paddles are limited by a max `PADDLE_SPEED`), which means stalemates no longer happen

TODO:

* The original also had a limitation that made the very top and very bottom of the screen inaccessible to paddles. This could be exploited by skilled players to score points - otherwise the game could go on too long
* Hitting the ball with a paddle that is moving could impart some momentum to the ball, consistent with the direction the paddle was moving at time of collision
* Hitting the ball with a paddle that is still could slightly decrease the velocity of the ball

# Sources and Credits

* [Game Mechanics: Pong](https://gamemechanics.fandom.com/wiki/Pong)
* [Wikipedia: Pong](https://en.wikipedia.org/wiki/Pong)
* [Inevitable StackOverflow Question](https://gamedev.stackexchange.com/questions/4253/in-pong-how-do-you-calculate-the-balls-direction-when-it-bounces-off-the-paddl)
