import utils
import strutils
import sequtils
import tables

type
  Dir = enum
    N, S, E, W
  Instr = tuple
    op: char
    val: int
  Coord = tuple
    x, y: int
  Ship = ref object
    x, y: int
    facing: Dir
    wp: Coord

# (0 -1)
# (1  0)
proc rotateCw90(c: Coord): Coord =
  (-1 * c.y, 1 * c.x)

# (0  1)
# (-1 0)
proc rotateCcw90(c: Coord): Coord =
  (1 * c.y, -1 * c.x)

proc newShip(): Ship =
  new(result)
  result.x = 0
  result.y = 0
  result.facing = E
  result.wp = (10, -1)

proc facingDir(ship: Ship): int =
  {N: 0, S: 180, E: 90, W: 270}.toTable[ship.facing]

proc forward(ship: var Ship, dist: int) =
  case ship.facing:
    of N:
      ship.y -= dist
    of S:
      ship.y += dist
    of E:
      ship.x += dist
    of W:
      ship.x -= dist

proc translate(ship: var Ship, dir: Dir, dist: int) =
  case dir
    of N:
      ship.y -= dist
    of S:
      ship.y += dist
    of E:
      ship.x += dist
    of W:
      ship.x -= dist

proc translateWp(ship: var Ship, dir: Dir, dist: int) =
  case dir
    of N:
      ship.wp.y -= dist
    of S:
      ship.wp.y += dist
    of E:
      ship.wp.x += dist
    of W:
      ship.wp.x -= dist

proc moveToWp(ship: var Ship, dist: int) =
  ship.x += ship.wp.x * dist
  ship.y += ship.wp.y * dist

proc rotateWp(ship: var Ship, deg: int) =
  # I'm clearly very lazy.
  case deg:
    of 90:
      ship.wp = ship.wp.rotateCw90
    of 180:
      ship.wp = ship.wp.rotateCw90
      ship.wp = ship.wp.rotateCw90
    of 270:
      ship.wp = ship.wp.rotateCw90
      ship.wp = ship.wp.rotateCw90
      ship.wp = ship.wp.rotateCw90
    of -90:
      ship.wp = ship.wp.rotateCcw90
    of -180:
      ship.wp = ship.wp.rotateCcw90
      ship.wp = ship.wp.rotateCcw90
    of -270:
      ship.wp = ship.wp.rotateCcw90
      ship.wp = ship.wp.rotateCcw90
      ship.wp = ship.wp.rotateCcw90
    else:
      assert(false, "Bad waypoint turn deg: " & $(deg))

proc turn(ship: var Ship, deg: int) =
  let cur = ship.facingDir + deg
  ship.facing = {0: N, 90: E, 180: S, 270: W, -90: W, -180: S, -270: E}.toTable[cur mod 360]

####################################################################################################

let dirEnum = {'N': N, 'S': S, 'E': E, 'W': W}.toTable

proc parse_instr(line: string): Instr =
  result.op = line[0]
  result.val = parseInt(line[1..^1])

proc part1(ship: var Ship, instrs: seq[Instr]) =
  for instr in instrs:
    case instr.op:
      of 'N', 'S', 'E', 'W':
        ship.translate(dirEnum[instr.op], instr.val)
      of 'L':
        ship.turn(-instr.val)
      of 'R':
        ship.turn(instr.val)
      of 'F':
        ship.forward(instr.val)
      else:
        assert(false, "Unknown op: " & $(instr.op))

proc part2(ship: var Ship, instrs: seq[Instr]) =
  for instr in instrs:
    case instr.op:
      of 'N', 'S', 'E', 'W':
        ship.translateWp(dirEnum[instr.op], instr.val)
      of 'L':
        ship.rotateWp(-instr.val)
      of 'R':
        ship.rotateWp(instr.val)
      of 'F':
        ship.moveToWp(instr.val)
      else:
        assert(false, "Unknown op: " & $(instr.op))

let instrs = get_lines().map(parse_instr)
var ship = newShip()
part1(ship, instrs)
echo abs(ship.x) + abs(ship.y)

ship = newShip()
part2(ship, instrs)
echo abs(ship.x) + abs(ship.y)
