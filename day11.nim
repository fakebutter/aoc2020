import utils
import strutils
import sequtils
import algorithm

type
  Pair = tuple
    r, c: int
  Map = seq[seq[char]]

proc parse_map(lines: seq[string]): Map =
  lines.mapIt(toSeq(it.items))

proc get_size(map: var seq[seq[char]]): Pair =
  return (map.len, map[0].len)

proc has_visible_occupied(map: var Map, pos: Pair, dir: Pair): bool =
  let (height, width) = get_size(map)
  var
    r = pos[0]
    c = pos[1]

  r += dir[0]; c += dir[1]
  while r >= 0 and r < height and c >= 0 and c < width:
    if map[r][c] == '#':
      return true
    elif map[r][c] == 'L':
      return false
    r += dir[0]; c += dir[1]

  return false

proc get_adjacent_occupied(map: var Map, r: int, c: int): int =
  let (height, width) = get_size(map)
  proc valid(r: int, c: int): bool = r >= 0 and r < height and c >= 0 and c < width

  for delta in [
    (-1, -1), (-1, 0), (-1, 1),
    (0, -1), (0, 1),
    (1, -1), (1, 0), (1, 1),
  ]:
    if valid(r + delta[0], c + delta[1]):
      if map[r + delta[0]][c + delta[1]] == '#':
        result += 1

proc get_visible_occupied(map: var seq[seq[char]], r: int, c: int): int =
  for dir in [
    (-1, -1), (-1, 0), (-1, 1),
    (0, -1), (0, 1),
    (1, -1), (1, 0), (1, 1)
  ]:
    if has_visible_occupied(map, (r, c), dir):
      result += 1

proc can_occupy(map: var seq[seq[char]], r: int, c: int): bool =
  return get_adjacent_occupied(map, r, c) == 0

proc can_vacate(map: var seq[seq[char]], r: int, c: int): bool =
  return get_adjacent_occupied(map, r, c) >= 4

proc can_occupy2(map: var seq[seq[char]], r: int, c: int): bool =
  return get_visible_occupied(map, r, c) == 0

proc can_vacate2(map: var seq[seq[char]], r: int, c: int): bool =
  return get_visible_occupied(map, r, c) >= 5

proc sig(map: var seq[seq[char]]): seq[Pair] =
  for (r, row) in map.pairs:
    for (c, seat) in row.pairs:
      if seat == '#':
        result.add((r, c))
  result.sort()

proc step(map: var seq[seq[char]]): bool =
  var
    to_occupy = newSeq[Pair]()
    to_vacate = newSeq[Pair]()
  let sig_before = sig(map)

  for (r, row) in map.pairs:
    for (c, seat) in row.pairs:
      if seat in ['#', 'L']:
        if can_occupy(map, r, c):
          to_occupy.add((r, c))
        elif can_vacate(map, r, c):
          to_vacate.add((r, c))

  for (r, c) in to_occupy:
    map[r][c] = '#'
  for (r, c) in to_vacate:
    map[r][c] = 'L'

  return sig_before != sig(map)

proc step2(map: var seq[seq[char]]): bool =
  var
    to_occupy = newSeq[Pair]()
    to_vacate = newSeq[Pair]()
  let sig_before = sig(map)

  for (r, row) in map.pairs:
    for (c, seat) in row.pairs:
      if seat in ['#', 'L']:
        if can_occupy2(map, r, c):
          to_occupy.add((r, c))
        elif can_vacate2(map, r, c):
          to_vacate.add((r, c))

  for (r, c) in to_occupy:
    map[r][c] = '#'
  for (r, c) in to_vacate:
    map[r][c] = 'L'

  return sig_before != sig(map)

proc count(map: var seq[seq[char]], c: char): int =
  for row in map:
    for seat in row.items:
      if seat == c:
        result += 1

proc print_map(map: var seq[seq[char]]) =
  for row in map:
    echo row.join("")

let lines = get_lines()
var map = parse_map(lines)
var dirty: bool
while (dirty = step(map); dirty):
  #echo count(map, '#')
  #print_map(map)
  discard
echo count(map, '#')

map = parse_map(lines)
while (dirty = step2(map); dirty):
  #echo count(map, '#')
  #print_map(map)
  discard
echo count(map, '#')
