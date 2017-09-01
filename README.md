# Zum Puzzler Pocket
A Gameboy game I wrote for my sister's birthday. Built with [gbasm](https://github.com/thatoddmailbox/gbasm).

## Story background
This game continues from a series of several other games, and so has a somewhat convoluted story. The main characters of the story are two [Zums](http://www.webkinzinsider.com/wiki/Zums), [Zap](http://www.webkinzinsider.com/wiki/File:Zap.png) and [Zala](http://www.webkinzinsider.com/wiki/File:Zala.png). After having defeated their first enemy, [Zane](http://www.webkinzinsider.com/wiki/File:Zane.png) (who wanted to control of all of the Zums), they are now fighting an evil duck, Ducky. (who also wants to control all of the Zums) Ducky is known for his poor command of written English, his very elaborate (yet short-sighted) evil schemes, and his belief that he is the smartest living thing in existence.

In this game, Zala finds herself trapped inside a maze of puzzles inside Duck Enterprises, with Ducky busy chasing after Zap. She makes her way through these puzzles in an attempt to escape.

## Known bugs
* When going back to the main menu in the middle of a level, the Y scroll register is not reset, meaning that the background level might be offset.
* On level `surface_level5`, if you activate the DuckPuzz terminal with Zala touching the floor, some of the mirrors in the level will not be reset on completion of the DuckPuzz, and you will have to restart the level to complete it.