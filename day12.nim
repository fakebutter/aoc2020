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
    pos: Coord
    facing: Dir
    wp: Coord

let degToDir = {0: N, 90: E, 180: S, 270: W, -90: W, -180: S, -270: E}.toTable
let dirToDeg = {N: 0, S: 180, E: 90, W: 270}.toTable
let translation = {N: (0, -1), S: (0, 1), E: (1, 0), W: (-1, 0)}.toTable
let dirEnum = {'N': N, 'S': S, 'E': E, 'W': W}.toTable

proc `+=`(lhs: var Coord, rhs: Coord) =
  lhs.x += rhs.x
  lhs.y += rhs.y

proc `*`(lhs: Coord, rhs: int): Coord =
  (lhs.x * rhs, lhs.y * rhs)

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
  result.pos = (0, 0)
  result.facing = E
  result.wp = (10, -1)

proc facingDeg(ship: Ship): int =
  dirToDeg[ship.facing]

proc forward(ship: var Ship, dist: int) =
  ship.pos += translation[ship.facing] * dist

proc translate(ship: var Ship, dir: Dir, dist: int) =
  ship.pos += translation[dir] * dist

proc translateWp(ship: var Ship, dir: Dir, dist: int) =
  ship.wp += translation[dir] * dist

proc moveToWp(ship: var Ship, dist: int) =
  ship.pos += ship.wp * dist

proc rotateWp(ship: var Ship, deg: int) =
  # I'm clearly very lazy.
  if deg > 0:
    for i in 0..<int(deg/90):
      ship.wp = ship.wp.rotateCw90
  else:
    for i in 0..<int(abs(deg)/90):
      ship.wp = ship.wp.rotateCcw90

proc turn(ship: var Ship, deg: int) =
  ship.facing = degToDir[(ship.facingDeg + deg) mod 360]

####################################################################################################

proc parse_instr(line: string): Instr =
  result.op = line[0]
  result.val = parseInt(line[1..^1])

proc part1(ship: var Ship, instrs: seq[Instr]) =
  for instr in instrs:
    case instr.op:
      of 'N', 'S', 'E', 'W':
        ship.translate(dirEnum[instr.op], instr.val)
      of 'R', 'L':
        ship.turn(if instr.op == 'L': -instr.val else: instr.val)
      of 'F':
        ship.forward(instr.val)
      else:
        assert(false, "Unknown op: " & $(instr.op))

proc part2(ship: var Ship, instrs: seq[Instr]) =
  for instr in instrs:
    case instr.op:
      of 'N', 'S', 'E', 'W':
        ship.translateWp(dirEnum[instr.op], instr.val)
      of 'L', 'R':
        ship.rotateWp(if instr.op == 'L': -instr.val else: instr.val)
      of 'F':
        ship.moveToWp(instr.val)
      else:
        assert(false, "Unknown op: " & $(instr.op))

let instrs = get_lines().map(parse_instr)
var ship = newShip()
part1(ship, instrs)
echo abs(ship.pos.x) + abs(ship.pos.y)

ship = newShip()
part2(ship, instrs)
echo abs(ship.pos.x) + abs(ship.pos.y)
