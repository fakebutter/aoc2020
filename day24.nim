import re
import sequtils
import tables
import utils

let Step: Table[string, V2] = {
  "e": (10, 0),
  "se": (5, -10),
  "sw": (-5, -10),
  "w": (-10, 0),
  "nw": (-5, 10),
  "ne": (+5, 10)
}.toTable

proc adj(x, y: int): seq[V2] =
  toSeq(Step.values).mapIt((x, y) + it)

proc adj(coord: V2): seq[V2] =
  adj(coord.x, coord.y)

proc countAdj(tiles: var Table[V2, bool], coord: V2): V2 =
  var whiteCount, blackCount: int
  for n in adj(coord):
    let white = tiles.getOrDefault(n, true)
    if white:
      whiteCount += 1
    else:
      blackCount += 1
  return (whiteCount, blackCount)

proc part1(tiles: var Table[V2, bool], dirs: seq[seq[string]]): int =
  for dir in dirs:
    var cur = (0, 0)
    for d in dir:
      cur = cur + Step[d]
    tiles[cur] = not tiles.getOrDefault(cur, true)

  return toSeq(tiles.values).count(false)

proc part2(tiles: var Table[V2, bool]): int =
  for i in 1..100:
    var toFlip = newSeq[V2]()

    for (coord, isWhite) in toSeq(tiles.pairs):
      if not isWhite:
        # Materialize adjacent white tiles as they may need to be flipped.
        for n in adj(coord):
          if tiles.getOrDefault(n, true):
            tiles[n] = true

    for (coord, isWhite) in tiles.pairs:
      let (_, adjBlack) = countAdj(tiles, coord)
      if isWhite:
        if adjBlack == 2:
          toFlip.add(coord)
      else:
        if adjBlack == 0 or adjBlack > 2:
          toFlip.add(coord)

    for coord in toFlip:
      tiles[coord] = not tiles.getOrDefault(coord, true)

  return toSeq(tiles.values).count(false)

var tiles: Table[V2, bool]  # true is white tile
let dirs = get_lines().mapIt(it.findAll(re"(e|se|sw|w|nw|ne)"))
echo part1(tiles, dirs)
echo part2(tiles)
