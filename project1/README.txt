Steven Comer
sfc15@pitt.edu

Project 1 WordSoup:

The first step was to create the dictionary. I made a list of ten words in the data section.
I used a look-up table which was word-aligned to store pointers to these ten words. In a separate list,
I stored the lengths for each word, in the same order.

Next, I hardwired the program to select "computer" as the first word every time the program
starts. A random number of asterisks is chosen in the range [0,N/2]. These asterisks are randomly
assigned to positions in the word. Display the word to the user masked with these asterisks and the
rest as underscores. The round score starts as the length of the word. The user guesses a letter. If
the letter is in the word and the character is not concealed by an asterisk, then the correct letter
replaces the underscore in the hidden word. If the character is not in the word, then round score
decreases by 1. The user entry loop ends if the user completes the word correctly, or if round score
reaches zero.

There are a few special options for the user. If '.' is entered, the round ends and round score
is zero. If '!' is entered, the user is prompted to enter the whole word. If whole word is correct, round
score doubles. If whole word is incorrect, then round score is negated then doubled. If '?' is entered,
the next underscore in the masked word changes to the correct character and round score is decreased by one.
The user can use '?' three times per round.

The round score is added to a running tally at the end of each round. This "game tally" is displayed
at the end of each round and at the end of the game.

After each round, the user has the option to play again. The "game tally" is saved across rounds.	
	
**PROBLEMS**
I did not implement the '?' functionality. Everything else works as required.