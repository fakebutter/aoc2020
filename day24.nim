import re
import sequtils
import tables
import utils

proc parseDirs(line: string): seq[string] =
  var line = line
  while line.len > 0:
    if line =~ re"^(e|se|sw|w|nw|ne)":
      result.add(matches[0])
      line = line[matches[0].len..^1]

proc adj(x, y: int): seq[(int, int)] =
  @[
    (x + 10, y),
    (x + 5, y - 10),
    (x - 5, y - 10),
    (x - 10, y),
    (x - 5, y + 10),
    (x + 5, y + 10),
  ]

proc adj(coord: (int, int)): seq[(int, int)] =
  adj(coord[0], coord[1])

proc countAdj(tiles: var Table[(int, int), bool], x, y: int): (int, int) =
  var whiteCount, blackCount: int
  for (ax, ay) in adj(x, y):
    let white = tiles.getOrDefault((ax, ay), true)
    if white:
      whiteCount += 1
    else:
      blackCount += 1
  
  return (whiteCount, blackCount)

proc countAdj(tiles: var Table[(int, int), bool], coord: (int, int)): (int, int) =
  countAdj(tiles, coord[0], coord[1])

proc run(dirs: seq[seq[string]]) =
  var x, y = 0
  var tiles: Table[(int,int),bool]

  for dir in dirs:
    x = 0; y = 0
    for d in dir:
      case d:
        of "e":
          x += 10
        of "se":
          y -= 10
          x += 5
        of "sw":
          y -= 10
          x -= 5
        of "w":
          x -= 10
        of "nw":
          y += 10
          x -= 5
        of "ne":
          y += 10
          x += 5
        else:
          assert false
    tiles[(x, y)] = not tiles.getOrDefault((x, y), true)

  echo "Part 1: ", toSeq(tiles.values).count(false)

  for i in 1..100:
    var
      toFlip = newSeq[(int, int)]()
      toWhite = newSeq[(int, int)]()

    for (coord, isWhite) in tiles.pairs:
      if not isWhite:
        let (_, adjBlack) = countAdj(tiles, coord)
        if adjBlack == 0 or adjBlack > 2:
          toFlip.add(coord)

        # Materialize adjacent white tiles as they may need to be flipped.
        for n in adj(coord):
          if tiles.getOrDefault(n, true):
            toWhite.add(n)

    for coord in toWhite:
      tiles[coord] = true

    for (coord, isWhite) in tiles.pairs:
      if isWhite:
        let (_, adjBlack) = countAdj(tiles, coord)
        if adjBlack == 2:
          toFlip.add(coord)

    for coord in toFlip:
      tiles[coord] = not tiles.getOrDefault(coord, true)

  echo "Part 2: ", toSeq(tiles.values).count(false)

let dirs = get_lines().map(parseDirs)
run(dirs)
