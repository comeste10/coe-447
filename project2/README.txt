Steven Comer
sfc15@pitt.edu
27 March 2012

Project 2 Snake:

The first step was to create the create the initial snake in memory. I made a list of words for the
snake x coordinates and a different list for y coordinates. I added 32 entries of -1 to each list for
a total of 40 entries in each list. The -1's are placeholders for future values of the snake's position.
The maximum length of the snake is 40.

The program is initialized by drawing the original snake first. The next step is to generate 32 random frogs.
The snake is represented by yellow LEDs and each frog is a green LED. The snake starts out moving to the right
at the beginning of the program. The user is able to change the direction of the snake using the W, A, S, and D
keys or by clicking the corresponding arrow buttons on the LED display.

The goal of the game is to eat all the
frogs without the snake running into itself. If the snake runs into itself, the game ends. If all frogs are eaten,
the game ends. After the game is finished, the number of frogs eaten and the playing time are displayed.	

My algorithm works by keeping a pointer to memory location which holds the x and y values of the head. The length
of the snake is stored in a separate location. The snake is moved by turning on and off LEDs. Based on the direction
of movement, a yellow LED is turned on to represent the next head. The tail must now be turned off. This is done by
using an offset from the head address based on the current length of the snake. In this way the snake can be moved to
any position on the board. Upon reaching an edge of the LED screen, the snake will wrap around to the other side and
continue moving.
	
**PROBLEMS**
None