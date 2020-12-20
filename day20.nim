import math
import sequtils
import strutils
import sugar
import tables
import terminal
import utils

type
  Tile = tuple
    img: seq[string]
    sides: seq[string]
  Soln = tuple
    product: int
    img: seq[string]

proc parse_tile(lines: seq[string]): (int, Tile) =
  let
    idx = parseInt(lines[0].split(" ")[1][0..^2])
    img = lines[1..^1]

    # Store borders separately for easier matching.
    sides = @[
      img[0],
      img.mapIt(it[^1]).join(""),
      img[^1],
      img.mapIt(it[0]).join(""),
    ]
  return (idx, (img: img, sides: sides))

proc rotateSides(sides: seq[string]): seq[string] =
  return @[
    sides[3].rev,
    sides[0],
    sides[1].rev,
    sides[2],
  ]

proc rotateImage(img: seq[string]): seq[string] =
  let size = img.len
  result = img
  for r in 0..<size:
    for c in 0..<size:
      result[c][size-r-1] = img[r][c]

proc flipSides(sides: seq[string]): seq[string] =
  return @[
    sides[0].rev,
    sides[3],
    sides[2].rev,
    sides[1],
  ]

proc flipImage(img: seq[string]): seq[string] =
  let size = img.len
  result = img
  for r in 0..<size:
    for c in 0..<size:
      result[r][size-c-1] = img[r][c]

proc rotateTile(tile: Tile): Tile =
  return (img: rotateImage(tile.img), sides: rotateSides(tile.sides))

proc flipTile(tile: Tile): Tile =
  return (img: flipImage(tile.img), sides: flipSides(tile.sides))

iterator orientations(tile: Tile): Tile =
  var tile = tile
  for _ in 0..<4:
    yield tile
    tile = rotateTile(tile)
  tile = flipTile(tile)
  for _ in 0..<4:
    yield tile
    tile = rotateTile(tile)

proc is_vert_adj(upper: Tile, lower: Tile): bool =
  upper.sides[2] == lower.sides[0]

################################################################################
# Part 1

proc is_solved(tiles: Table[int, Tile], path: seq[seq[int]], size: int): bool =
  for col in 0..<size:
    for row in 0..<size-1:
      if not is_vert_adj(tiles[path[row][col]], tiles[path[row+1][col]]):
        return false
  return true

proc make_image(tiles: Table[int, Tile], path: seq[seq[int]]): seq[string] =
  let size = tiles[path[0][0]].img.len

  # Strip borders.
  for row in path:
    for y in 1..<size-1:
      var line = ""
      for idx in row:
        line &= tiles[idx].img[y][1..^2]
      result.add(line)

proc visited(path: seq[seq[int]], i: int): bool =
  for row in path:
    if i in row:
      return true
  return false

proc scan_right(tiles: var Table[int, Tile], size: int, idx: int, path: var seq[seq[int]]): Soln

proc scan_next_row(tiles: var Table[int, Tile], size: int, path: var seq[seq[int]]): Soln =
  path.add(newSeq[int]())

  # Find possible start of next row.
  for i in tiles.keys:
    let upper = tiles[path[^2][0]]
    if not visited(path, i):
      let org_tile = tiles[i]

      for tile in orientations(org_tile):
        if is_vert_adj(upper, tile):
          tiles[i] = tile
          let soln = scan_right(tiles, size, i, path)
          if soln.product != 0:
            tiles[i] = org_tile
            discard path.pop()
            return soln

      tiles[i] = org_tile

  discard path.pop()
  return (0, @[])

proc scan_right(tiles: var Table[int, Tile], size: int, idx: int, path: var seq[seq[int]]): Soln =
  path[^1].add(idx)

  # Row is full.
  if path[^1].len == size:
    if path.len < size:
      let soln = scan_next_row(tiles, size, path)
      if soln.product != 0:
        discard path[^1].pop()
        return soln
    else:
      # Possible solution.
      if is_solved(tiles, path, size):
        let
          prod = path[0][0] * path[0][^1] * path[^1][0] * path[^1][^1]
          img = make_image(tiles, path)
        discard path[^1].pop()
        return (prod, img)

    discard path[^1].pop()
    return (0, @[])

  # Find next possible tile on the right.
  let cur = tiles[idx]
  for i in tiles.keys:
    if not visited(path, i):
      let org_tile = tiles[i]

      for tile in orientations(org_tile):
        if cur.sides[1] == tile.sides[3]:
          tiles[i] = tile
          let soln = scan_right(tiles, size, i, path)
          if soln.product != 0:
            tiles[i] = org_tile
            discard path[^1].pop()
            return soln

      tiles[i] = org_tile

  discard path[^1].pop()
  return (0, @[])

proc part1(tiles: var Table[int, Tile], size: int): Soln =
  for idx in tiles.keys:
    let org_tile = tiles[idx]

    for tile in orientations(org_tile):
      var path = newSeq[seq[int]]()
      path.add(newSeq[int]())

      tiles[idx] = tile
      let soln = scan_right(tiles, size, idx, path)
      if soln.product != 0:
        tiles[idx] = org_tile
        return soln

    tiles[idx] = org_tile

  return (0, @[])

################################################################################
# Part 2

proc img_hash(raw: seq[string]): uint64 =
  for row in raw:
    for pix in row.items:
      if pix == '#':
        result = (result shl 1) or 1
      else:
        result = (result shl 1) or 0

proc draw_monsters(map: seq[string], coords: seq[(int, int)], monster: seq[string]) =
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
        resetAttributes(stdout)
      else:
        stdout.write(c)
    stdout.write("\n")

proc find_monsters(map: seq[string], monster: seq[string]): int =
  let monster_hash = img_hash(monster)
  var coords = newSeq[(int, int)]()
  
  # Sliding window.
  for r in 0..<map.len - 3:
    for c in 0..<map[0].len - 20:
      let window = @[
        map[r][c..<c+20],
        map[r+1][c..<c+20],
        map[r+2][c..<c+20],
      ]
      if (img_hash(window) and monster_hash) == monster_hash:
        coords.add((r, c))

  if coords.len > 0:
    draw_monsters(map, coords, monster)
    return map.join("").count('#') - coords.len * monster.join("").count('#')

iterator toss_image(image: seq[string]): seq[string] =
  var image = image
  for _ in 0..<4:
    yield image
    image = rotateImage(image)
  image = flipImage(image)
  for _ in 0..<4:
    yield image
    image = rotateImage(image)

proc part2(image: seq[string], monster: seq[string]): int =
  for img in toss_image(image):
    let roughness = find_monsters(img, monster)
    if roughness != 0:
      return roughness

################################################################################

var tiles = toSeq(get_lines().split((l) => l == "")).map(parse_tile).toTable
let
  size = int(sqrt(float(tiles.len)))
  monster = """
                  # 
#    ##    ##    ###
 #  #  #  #  #  #   """.split("\n")

let soln = part1(tiles, size)
echo "Product: ", soln.product
echo "Roughness: ", part2(soln.img, monster)
