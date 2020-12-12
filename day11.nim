import utils
import sequtils
import algorithm
import sugar

type
  Pair = tuple
    r, c: int
  Map = ref object
    map: seq[seq[char]]
    width, height: int

proc `+`(lhs: Pair, rhs: Pair): Pair =
  result = lhs
  result.r += rhs.r
  result.c += rhs.c

proc `[]`(map: Map, pos: Pair): char =
  map.map[pos.r][pos.c]

proc `[]=`(map: var Map, pos: Pair, seat: char) =
  map.map[pos.r][pos.c] = seat

proc count(map: Map, c: char): int =
  map.map.mapIt(it.mapIt(it == c)).concat.count(true)

proc valid(map: Map, pos: Pair): bool =
  pos.r >= 0 and pos.r < map.height and
    pos.c >= 0 and pos.c < map.width

iterator iter(map: Map): (Pair, char) =
  for (r, row) in map.map.pairs:
    for (c, seat) in row.pairs:
      yield ((r, c), seat)

proc sig(map: var Map): seq[Pair] =
  for (pos, seat) in map.iter:
    if seat == '#':
      result.add(pos)
  result.sort()

proc newMap(lines: seq[string]): Map =
  new(result)
  result.map = lines.mapIt(toSeq(it.items))
  result.height = result.map.len
  result.width = result.map[0].len

################################################################################

# Part 1

proc get_adjacent_occupied(map: Map, pos: Pair): int =
  for delta in [
    (-1, -1), (-1, 0), (-1, 1),
    (0, -1), (0, 1),
    (1, -1), (1, 0), (1, 1),
  ]:
    let cur = pos + delta
    if map.valid(cur) and map[cur] == '#':
      result += 1

proc can_occupy1(map: Map, pos: Pair): bool =
  return get_adjacent_occupied(map, pos) == 0

proc can_vacate1(map: Map, pos: Pair): bool =
  return get_adjacent_occupied(map, pos) >= 4

################################################################################

# Part 2

proc has_visible_occupied(map: Map, pos: Pair, dir: Pair): bool =
  var pos = pos + dir

  while map.valid(pos):
    if map[pos] == '#':
      return true
    elif map[pos] == 'L':
      return false
    pos = pos + dir

  return false

proc get_visible_occupied(map: Map, pos: Pair): int =
  @[
    (-1, -1), (-1, 0), (-1, 1),
    (0, -1), (0, 1),
    (1, -1), (1, 0), (1, 1)
  ].mapIt(has_visible_occupied(map, pos, it)).count(true)

proc can_occupy2(map: Map, pos: Pair): bool =
  return get_visible_occupied(map, pos) == 0

proc can_vacate2(map: Map, pos: Pair): bool =
  return get_visible_occupied(map, pos) >= 5

################################################################################

type
  SeatPred = (m: Map, s: Pair) -> bool

proc step(map: var Map, can_occupy: SeatPred, can_vacate: SeatPred): bool =
  var
    to_occupy, to_vacate = newSeq[Pair]()
  let sig_before = map.sig

  for (pos, seat) in map.iter:
    if seat in ['#', 'L']:
      if can_occupy(map, pos):
        to_occupy.add(pos)
      elif can_vacate(map, pos):
        to_vacate.add(pos)

  for pos in to_occupy:
    map[pos] = '#'
  for pos in to_vacate:
    map[pos] = 'L'

  return sig_before != map.sig

let lines = get_lines()

var map = newMap(lines)
while step(map, can_occupy1, can_vacate1):
  discard
echo map.count('#')

map = newMap(lines)
while step(map, can_occupy2, can_vacate2):
  discard
echo map.count('#')
