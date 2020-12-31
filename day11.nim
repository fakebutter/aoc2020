import utils
import sequtils
import algorithm
import sugar

type
  Map = ref object
    raw: seq[seq[char]]
    width, height: int

const Adj = [
    (-1, -1), (0, -1), (1, -1),
    (-1,  0),          (1,  0),
    (-1,  1), (0,  1), (1,  1)
  ]

proc `[]`(map: Map, pos: V2): char =
  map.raw[pos.y][pos.x]

proc `[]=`(map: Map, pos: V2, seat: char) =
  map.raw[pos.y][pos.x] = seat

proc count(map: Map, c: char): int =
  map.raw
    .flatMap((r) => r.mapIt(it == c))
    .count(true)

proc valid(map: Map, pos: V2): bool =
  (pos.y >= 0 and pos.y < map.height) and (pos.x >= 0 and pos.x < map.width)

iterator iter(map: Map): (V2, char) =
  for (r, row) in map.raw.pairs:
    for (c, seat) in row.pairs:
      yield ((c, r), seat)

proc sig(map: Map): seq[V2] =
  for (pos, seat) in map.iter:
    if seat == '#':
      result.add(pos)
  result.sort()

proc newMap(lines: seq[string]): Map =
  new(result)
  result.raw = lines.to2dArr
  result.height = result.raw.len
  result.width = result.raw[0].len

################################################################################
# Part 1

proc countAdjOccupied(map: Map, pos: V2): int =
  for delta in Adj:
    let cur = pos + delta
    if map.valid(cur) and map[cur] == '#':
      result += 1

proc canOccupy1(map: Map, pos: V2): bool =
  countAdjOccupied(map, pos) == 0

proc canVacate1(map: Map, pos: V2): bool =
  countAdjOccupied(map, pos) >= 4

################################################################################
# Part 2

proc hasVisibleOccupied(map: Map, pos: V2, dir: V2): bool =
  var cur = pos + dir

  while map.valid(cur):
    if map[cur] == '#':
      return true
    elif map[cur] == 'L':
      return false
    cur = cur + dir

proc countVisibleOccupied(map: Map, pos: V2): int =
  Adj.mapIt(hasVisibleOccupied(map, pos, it)).count(true)

proc canOccupy2(map: Map, pos: V2): bool =
  countVisibleOccupied(map, pos) == 0

proc canVacate2(map: Map, pos: V2): bool =
  countVisibleOccupied(map, pos) >= 5

################################################################################

type
  SeatPred = (m: Map, s: V2) -> bool

proc step(map: Map, canOccupy: SeatPred, canVacate: SeatPred): bool =
  var toOccupy, toVacate: seq[V2]
  let sigBefore = map.sig

  for (pos, seat) in map.iter:
    if seat in ['#', 'L']:
      if canOccupy(map, pos):
        toOccupy.add(pos)
      elif canVacate(map, pos):
        toVacate.add(pos)

  for pos in toOccupy:
    map[pos] = '#'
  for pos in toVacate:
    map[pos] = 'L'

  return sigBefore != map.sig

proc run(lines: seq[string], canOccupy: SeatPred, canVacate: SeatPred): int =
  var map = newMap(lines)
  while step(map, canOccupy, canVacate):
    discard
  return map.count('#')

let lines = getLines()
echo run(lines, canOccupy1, canVacate1)
echo run(lines, canOccupy2, canVacate2)
