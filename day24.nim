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

proc getAdj(coord: V2): seq[V2] =
  toSeq(Step.values).mapIt(coord + it)

proc countAdj(tiles: var Table[V2, bool], coord: V2): V2 =
  var whiteCount, blackCount: int
  for adj in getAdj(coord):
    let white = tiles.getOrDefault(adj, true)
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
  for _ in 1..100:
    # Materialize adjacent white tiles as they may need to be flipped.
    for (coord, isWhite) in toSeq(tiles.pairs):
      if not isWhite:
        for adj in getAdj(coord):
          if tiles.getOrDefault(adj, true):
            tiles[adj] = true

    var toFlip = newSeq[V2]()

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
