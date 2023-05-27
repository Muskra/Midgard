# Midgard
Conway's Game of Life implementation in Odinlang

## Installation
* clone this repo
* run `odin build .` inside the project folder

## Usage

```Usage: game_of_life [OPTION]... 
A simple Conway's Game of life that generates a random grid.

Without options, it launches with a default size of 80x80 characters (80 lines of 80 columns) and process one generation.

  -c, --columns           number of columns, minimal value is 3, default value is 80
  -l, --lines             number of lines, minimal value is 3, default value is 80
  -i, --iterations        number of iterations, default value is 0, maximum value is defined from you ambitions
          e.g: you want to fry your CPU
  -h, --help        display this help message and exit

Examples:
  game_of_life -c 42 --lines 69        The program is launched with a 42x69 characters resolution.
  game_of_life                         The program is launched with default characters resolution (80x80).

If a parameter is used twice, the second one will overvrite the first parameter:
        e.g: 'game_of_life -i 46 --iterations 2'        number of iterations will be '2'
             'game_of_life -c 144 -c 4577'                 number of iterations will be '4577'```
