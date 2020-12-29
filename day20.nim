import math
import options
import sequtils
import strutils
import sugar
import tables
import terminal
import utils

type
  Sides = array[4, uint16]
  Tile = ref object
    rotation: int
    flipped: bool
    img: seq[string]
    sides: Sides
  Soln = tuple
    product: int
    img: seq[string]
let
  NoSoln: Soln = (0, @[])

proc newTile(img: seq[string], sides: Sides): Tile =
  new(result)
  result.rotation = 0
  result.flipped = false
  result.img = img
  result.sides = sides

template withRestoreTile(tile: var Tile, body: untyped) =
  let backup = tile.sides
  body
  tile.rotation = 0
  tile.flipped = false
  tile.sides = backup

proc parseSide(s: string): uint16 =
  for i in 0..<10:
    result = result shr 1
    if s[i] == '#':
      result = result or 0x0200

proc parseTile(lines: seq[string]): (int, Tile) =
  let
    idx = parseInt(lines[0].split(" ")[1][0..^2])
    img = lines[1..^1]

    # Store borders separately for easier matching.
    sides = [
      parseSide(img[0]),
      parseSide(img.mapIt(it[^1]).join("")),
      parseSide(img[^1]),
      parseSide(img.mapIt(it[0]).join("")),
    ]
  return (idx, newTile(img, sides))

proc reverse(v: uint16): uint16 =
  var v = v
  for _ in 0..<10:
    result = result shl 1
    if (v and 0x01) > 0:
      result = result or 0x01
    v = v shr 1

proc rotateSides(sides: Sides): Sides =
  return [
    sides[3].reverse,
    sides[0],
    sides[1].reverse,
    sides[2],
  ]

proc rotateImage(img: seq[string]): seq[string] =
  let size = img.len
  result = img
  for r in 0..<size:
    for c in 0..<size:
      result[c][size-r-1] = img[r][c]

proc flipSides(sides: Sides): Sides =
  return [
    sides[0].reverse,
    sides[3],
    sides[2].reverse,
    sides[1],
  ]

proc flipImage(img: seq[string]): seq[string] =
  let size = img.len
  result = img
  for r in 0..<size:
    for c in 0..<size:
      result[r][size-c-1] = img[r][c]

proc rotateTile(tile: Tile) =
  tile.rotation = (tile.rotation + 1) mod 4
  tile.flipped = tile.flipped
  tile.sides = rotateSides(tile.sides)

proc flipTile(tile: Tile) =
  tile.rotation = 0
  tile.flipped = not tile.flipped
  tile.sides = flipSides(tile.sides)

proc realizeImg(tile: Tile) =
  if tile.flipped:
    for _ in 0..<3:
      tile.img = rotateImage(tile.img)
    tile.img = flipImage(tile.img)
  for _ in 0..<tile.rotation:
    tile.img = rotateImage(tile.img)

  tile.rotation = 0
  tile.flipped = false

# Mutates
iterator orientations(tile: Tile): Tile =
  for _ in 0..<3:
    yield tile
    rotateTile(tile)
  yield tile
  flipTile(tile)
  for _ in 0..<3:
    yield tile
    rotateTile(tile)
  yield tile

iterator orientations(image: seq[string]): seq[string] =
  var image = image
  for _ in 0..<3:
    yield image
    image = rotateImage(image)
  yield image
  image = flipImage(image)
  for _ in 0..<3:
    yield image
    image = rotateImage(image)
  yield image

proc isVertAdj(upper: Tile, lower: Tile): bool =
  upper.sides[2] == lower.sides[0]

proc isHorzAdj(left: Tile, right: Tile): bool =
  left.sides[1] == right.sides[3]

################################################################################
# Part 1

proc makeImage(tiles: TableRef[int, Tile], path: seq[seq[int]]): seq[string] =
  let size = tiles[path[0][0]].img.len

  for row in path:
    for idx in row:
      realizeImg(tiles[idx])

  # Strip borders.
  for row in path:
    for y in 1..<size-1:
      var line = ""
      for idx in row:
        line &= tiles[idx].img[y][1..^2]
      result.add(line)

proc visited(idx: int, path: seq[seq[int]]): bool =
  for p in path:
    if idx in p:
      return true

proc getUpper(tiles: TableRef[int, Tile], path: seq[seq[int]]): Option[Tile] =
  if path.len == 1:
    return none(Tile)
  elif path[^1].len > 0:
    return some(tiles[path[^2][path[^1].len-1]])
  else:
    return some(tiles[path[^2][0]])

proc scanRight(tiles: TableRef[int, Tile], size: int, idx: int, path: var seq[seq[int]]): Soln

proc scanNextRow(tiles: TableRef[int, Tile], size: int, path: var seq[seq[int]]): Soln =
  path.add(newSeq[int]())
  defer: discard path.pop()
  let upper = getUpper(tiles, path)

  # Find possible start of next row.
  for i in tiles.keys:
    if visited(i, path):
      continue

    withRestoreTile(tiles[i]):
      for candidate in orientations(tiles[i]):
        if upper.map((u) => isVertAdj(u, candidate)) != some(false):
          let soln = scanRight(tiles, size, i, path)
          if soln != NoSoln:
            return soln

proc scanRight(tiles: TableRef[int, Tile], size: int, idx: int, path: var seq[seq[int]]): Soln =
  path[^1].add(idx)
  defer: discard path[^1].pop()

  # Row is full.
  if path[^1].len == size:
    if path.len < size:
      let soln = scanNextRow(tiles, size, path)
      if soln != NoSoln:
        return soln
    else:
      # Solution
      let
        prod = path[0][0] * path[0][^1] * path[^1][0] * path[^1][^1]
        img = makeImage(tiles, path)
      return (prod, img)

    return NoSoln

  let
    cur = tiles[idx]
    upper = getUpper(tiles, path)

  # Find next possible tile on the right.
  for i in tiles.keys:
    if visited(i, path):
      continue

    withRestoreTile(tiles[i]):
      for candidate in orientations(tiles[i]):
        if isHorzAdj(cur, candidate) and (upper.map((u) => isVertAdj(u, cur)) != some(false)):
          let soln = scanRight(tiles, size, i, path)
          if soln != NoSoln:
            return soln

proc part1(tiles: TableRef[int, Tile], size: int): Soln =
  var path = newSeq[seq[int]]()
  let soln = scanNextRow(tiles, size, path)
  if soln != NoSoln:
    return soln

################################################################################
# Part 2

proc imgHash(raw: seq[string], h, w: int, r, c: int = 0): uint64 =
  for row in raw[r..<r+h]:
    for pix in row[c..<c+w].items:
      result = result shl 1
      if pix == '#':
        result = result or 1

proc drawMonsters(map: seq[string], coords: seq[(int, int)], monster: seq[string]) =
  var map = map
  for (dr, dc) in coords:
    for r in 0..<3:
      for c in 0..<20:
        if monster[r][c] == '#':
          map[dr+r][dc+c] = 'O'

  for row in map:
    for c in row:
      if c == 'O':
        setForegroundColor(stdout, fgRed)
        stdout.write('O')
      else:
        setForegroundColor(stdout, fgCyan)
        stdout.write(c)
    stdout.write("\n")
  resetAttributes(stdout)

proc findMonsters(map: seq[string], monster: seq[string]): int =
  let monsterMask = imgHash(monster, 3, 20)
  var coords = newSeq[(int, int)]()

  # Sliding window.
  for r in 0..<map.len - 3:
    for c in 0..<map[0].len - 20:
      if (imgHash(map, 3, 20, r, c) and monsterMask) == monsterMask:
        coords.add((r, c))

  if coords.len > 0:
    # For funsies.
    drawMonsters(map, coords, monster)
    return map.join("").count('#') - coords.len * monster.join("").count('#')

proc part2(image: seq[string], monster: seq[string]): int =
  for img in orientations(image):
    let roughness = findMonsters(img, monster)
    if roughness != 0:
      return roughness

################################################################################

let rawTiles = toSeq(getLines().split((l) => l == ""))
var tiles = newTable(rawTiles.map(parseTile))
let size = int(sqrt(float(tiles.len)))
const monster = """
                      # 
    #    ##    ##    ###
     #  #  #  #  #  #   """.dedent.split("\n")

let soln = part1(tiles, size)
echo "Product: ", soln.product
echo "Roughness: ", part2(soln.img, monster)
