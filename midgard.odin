package main

// imports
//
import "core:fmt"
import "core:math/rand"
import "core:time"
import "core:os"
import "core:strconv"

// structs
//
Indexes :: struct { x, y: int }
Grid :: struct { cols, lines: u8 }

// main procedure
//
main :: proc() {
  
  help_message :: `Usage: game_of_life [OPTION]... 
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
             'game_of_life -c 144 -c 3'                 number of iterations will be '3'`

  error_message :: "game_of_life: invalid option %s\nTry 'game_of_life --help' for more information.\n"
  
  grid: Grid
  iterations: u8
  arg_as_numb := map[string]^u8{
    "-c" = &grid.cols,
    "--columns" = &grid.cols,
    "-l" = &grid.lines,
    "--lines" = &grid.lines,
    "-i" = &iterations,
    "--iterations" = &iterations,
  }
  arg_input := os.args
  check: bool

  index := 0
  for ; index < len(arg_input); index += 1 {
    if index != 0 {
      element := arg_input[index]
      if _, ok := &arg_as_numb[element]; ok {
        if (index+1) >= len(arg_input) {
          argument_help()
        } else if arg_as_numb[element]^ != 0 {
          argument_help()
        } else {
          arg_as_numb[element]^ = argument_parser(arg_input[index+1])
          index += 1
        }
      } else if element == "-h" || element == "--help" {
        argument_help()
      } else {
        argument_error(element)
      }
    }
  }
 
  if grid.cols == 2 || grid.lines == 2 {
    argument_help()
  }
  if grid.cols == 0 {
    grid.cols = 80
  }
  if grid.lines == 0 {
    grid.lines = 80
  }

  gol(grid, iterations)

  argument_parser :: proc(value: string) -> u8 {
    temp, check := strconv.parse_int(value)
    if check == false {
      argument_help()
    }
    return u8(temp) 
  }

  argument_error :: proc(arg: string) -> ! {
    fmt.eprintln(fmt.tprintf(error_message, arg))
    os.exit(1)
  }

  argument_help :: proc() -> ! {
    fmt.eprintln(help_message)
    os.exit(1)
  }
}

gol :: proc(g: Grid, iterations: u8) {
  // allocate memory
  //
  backing := make([]byte, g.lines * g.cols)
  assert(backing != nil, "out of memory: backing")

  generation := make([][]byte, g.lines)

  // generate the 2D slices for generation and neighborhood
  //
  for line in &generation {
    line = make([]byte, g.cols)
    assert(line != nil, "out of memory: generation")
  }

  defer delete(generation)
  defer delete(backing)

  r: rand.Rand // declare a random type
  rand.init_as_system(&r) // initiate the random variable to use host's provided random

  // assign a bit (0 or 1) with a parity choice instead of the ints in the grid
  //
  for line in &generation {
    
    // generating random numbers in the line
    //
    rand.read(line, &r)
    
    for value, y in &line {
      if value%2 != 0 {
        value = 1
      }
      if value%2 == 0 {
        value = 0
      }
    }
  }

  // first gen printout
  //
  prntout(generation)
  
  // main loop
  //
  for i in 0..<iterations {
    next_generation(g, generation)
    fmt.println("\ngen:", i+1)
    prntout(generation)
  }
}

prntout :: proc(gen: [][]byte) {
   for line in gen {
    for value in line {
      fmt.print(value)
    }
    fmt.print("\n")
  }
}

calculate_neighbors :: proc(idx: Indexes, grid: Grid, gen: [][]byte) -> (u8) {
  
  // declarations
  //
  lines := grid.lines-1
  cols := grid.cols-1
  xindex := u8(idx.x)
  yindex := u8(idx.y)
  count: u8 = 0

  // checking throught the number of neighbors for each cells, the number of possible neighbors is 8
  //
 
  // first line
  if xindex == 0 {
    
    // top left corner
    if yindex == 0 {
      count = gen[lines][cols] + gen[lines][0] + gen[lines][1] + gen[0][cols] + gen[0][1] + gen[1][1] + gen[1][0] + gen[1][cols] + gen[0][cols]
    
    // top right corner
    } else if yindex == cols {
      count = gen[lines][cols-1] + gen[lines][cols] + gen[lines][0] + gen[0][0] + gen[1][0] + gen[1][cols] + gen[1][cols-1] + gen[0][cols-1]
    
    // other values in the first line
    } else {
      count = gen[lines][yindex-1] + gen[lines][yindex] + gen[lines][yindex+1] + gen[0][yindex+1] + gen[1][yindex+1] + gen[1][yindex] + gen[1][yindex-1] + gen[0][yindex-1]
    }

  // last line
  } else if xindex == lines {
    
    // bottom left corner
    if yindex == 0 {
      count = gen[lines-1][cols] + gen[lines-1][0] + gen[lines-1][1] + gen[lines][1] + gen[0][1] + gen[0][0] + gen[0][cols] + gen[lines][cols-1]
    
    // bottom right corner
    } else if yindex == cols {
      count = gen[lines-1][cols-1] + gen[lines-1][cols] + gen[lines-1][0] + gen[lines][0] + gen[0][0] + gen[0][cols] + gen[0][cols-1] + gen[lines][cols-1]
    
    // other values in the first line
    } else {
      count = gen[lines-1][yindex-1] + gen[lines-1][yindex] + gen[lines-1][yindex+1] + gen[lines][yindex+1] + gen[0][yindex+1] + gen[0][yindex] + gen[0][yindex-1] + gen[lines][yindex-1]
    }
  
  // left side
  } else if (xindex != 0 || xindex != lines) && yindex == 0 {
    count = gen[xindex-1][cols] + gen[xindex-1][0] + gen[xindex-1][1] + gen[xindex][1] + gen[xindex+1][yindex+1] + gen[xindex+1][yindex] + gen[xindex+1][cols] + gen[xindex][cols]
  
  // rignt side
  } else if (xindex != 0 || xindex != lines) && yindex == cols {
    count = gen[xindex-1][cols-1] + gen[xindex-1][cols] + gen[xindex-1][0] + gen[xindex][0] + gen[xindex+1][0] + gen[xindex+1][cols] + gen[xindex+1][cols-1] + gen[xindex][cols-1]
  
  // inner values
  } else {
    count = gen[xindex-1][yindex-1] + gen[xindex-1][yindex] + gen[xindex-1][yindex+1] + gen[xindex][yindex+1] + gen[xindex+1][yindex+1] + gen[xindex+1][yindex] + gen[xindex+1][yindex-1] + gen[xindex][yindex-1]
  }
  
  return count

}

next_generation :: proc(grid: Grid, gen: [][]byte) {
  
  for lines, xindex in gen {
    for cells, yindex in lines {
      
      idx := Indexes{ xindex, yindex }
      neighbors := calculate_neighbors(idx, grid, gen)
      
      if cells == 0 && neighbors == 3 {
        gen[xindex][yindex] = 1
      } else if cells == 1 && (neighbors < 2 || neighbors > 3) {
        gen[xindex][yindex] = 0
      } else {
        continue
      }

    }
  }
}
