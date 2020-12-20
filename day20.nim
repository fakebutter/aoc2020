import algorithm
import math
import re
import sequtils
import strformat
import strutils
import sugar
import tables
import utils

type
  Tile = tuple
    full: seq[string]
    sides: seq[string]

# Screw it I'm really tired.
var poss_maps = newSeq[seq[string]]()

proc parse_tile(lines: seq[string]): (int, Tile) =
  var tile_idx = 0
  if lines[0] =~ re"Tile (\d+):":
    tile_idx = parseInt(matches[0])
  else:
    assert(false)

  # Store borders separately for easier matching.
  var sides = @["","","",""]
  sides[0] = lines[1]
  sides[2] = lines[^1]
  for line in lines[1..^1]:
    sides[3] &= line[0]
    sides[1] &= line[^1]

  return (tile_idx, (full: lines[1..^1], sides: sides))

proc rev(s: string): string =
  result = s
  result.reverse()

proc rotateTile(tile: Tile): Tile =
  proc rotateSides(sides: seq[string]): seq[string] =
    result = @["","","",""]
    result[0] = sides[3].rev
    result[1] = sides[0]
    result[2] = sides[1].rev
    result[3] = sides[2]

  proc rotateImage(tile: seq[string]): seq[string] =
    let size = tile.len
    result = tile
    for r in 0..<size:
      for c in 0..<size:
        result[c][size-r-1] = tile[r][c]

  result = tile
  result.full = rotateImage(tile.full)
  result.sides = rotateSides(tile.sides)

proc flipTile(tile: Tile): Tile =
  proc flipSides(sides: seq[string]): seq[string] =
    result = @["","","",""]
    (result[1], result[3]) = (sides[3], sides[1])
    result[0] = sides[0].rev
    result[2] = sides[2].rev

  proc flipImage(tile: seq[string]): seq[string] =
    let size = tile.len
    result = tile
    for r in 0..<size:
      for c in 0..<size:
        result[r][size-c-1] = tile[r][c]

  result = tile
  result.full = flipImage(tile.full)
  result.sides = flipSides(tile.sides)

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

proc is_solved(tiles: Table[int, Tile], path: seq[seq[int]], size: int): bool =
  for col in 0..<size:
    for row in 0..<size-1:
      if not is_vert_adj(tiles[path[row][col]], tiles[path[row+1][col]]):
        return false
  return true

proc store_image(tiles: Table[int, Tile], path: seq[seq[int]]) =
  let size = tiles[path[0][0]].full.len
  var map = newSeq[string]()

  for row in path:
    for y in 1..<size-1:
      var line = ""
      for idx in row:
        #stdout.write(tiles[idx].full[y][1..^2])
        line &= tiles[idx].full[y][1..^2]
      #stdout.write("\n")
      map.add(line)

  poss_maps.add(map)

proc find_right(tiles: var Table[int, Tile], size: int, idx: int, path: var seq[seq[int]]) =
  let visited = proc(path: seq[seq[int]], i: int): bool =
    for row in path:
      if i in row:
        return true
    return false

  let follows = proc(tiles: Table[int, Tile], i: int, j: int): bool =
    let
      upper = tiles[i]
      lower = tiles[j]
    for tile in orientations(lower):
      if is_vert_adj(upper, tile):
        return true
    return false

  path[^1].add(idx)

  if path[^1].len == size:
    if path.len < size:
      # Next row
      path.add(newSeq[int]())

      for i in tiles.keys:
        if visited(path, i):
          continue
        elif not follows(tiles, path[^2][0], i):
          continue

        let
          org_tile = tiles[i]

        for tile in orientations(org_tile):
          tiles[i] = tile
          find_right(tiles, size, i, path)

        tiles[i] = org_tile

      discard path.pop()
    else:
      # Found
      if is_solved(tiles, path, size):
        echo path[0][0] * path[0][^1] * path[^1][0] * path[^1][^1]
        #echo path.mapIt(it.mapIt($it).join(" ")).join("\n")
        #echo()
        store_image(tiles, path)

    discard path[^1].pop()
    return

  let cur = tiles[idx]

  for i in tiles.keys:
    if visited(path, i):
      continue

    let org_tile = tiles[i]

    for tile in orientations(org_tile):
      if cur.sides[1] == tile.sides[3]:
        tiles[i] = tile
        find_right(tiles, size, i, path)

    tiles[i] = org_tile

  discard path[^1].pop()

proc part1(tiles: var Table[int, Tile], size: int) =
  for idx in tiles.keys:
    let org_tile = tiles[idx]

    for tile in orientations(org_tile):
      var path = newSeq[seq[int]]()
      path.add(newSeq[int]())

      tiles[idx] = tile
      find_right(tiles, size, idx, path)

    tiles[idx] = org_tile

proc img_hash(raw: seq[string]): uint64 =
  for row in raw:
    for pix in row.items:
      if pix == '#':
        result = (result shl 1) or 1
      else:
        result = (result shl 1) or 0

proc part2(map: seq[string]): int =
  let
    monster = """
                  # 
#    ##    ##    ###
 #  #  #  #  #  #   """.split("\n")
    monster_hash = img_hash(monster)

  var
    count = 0
    coords = newSeq[(int, int)]()
  
  for r in 0..<map.len - 3:
    for c in 0..<map[0].len - 20:
      let window = @[
        map[r][c..<c+20],
        map[r+1][c..<c+20],
        map[r+2][c..<c+20],
      ]
      if (img_hash(window) and monster_hash) == monster_hash:
        count += 1
        coords.add((r, c))

  if count > 0:
    var map = map
    for (dr, dc) in coords:
      for r in 0..<3:
        for c in 0..<20:
          if monster[r][c] == '#':
            map[dr+r][dc+c] = 'o'
    echo map.join("\n")

    return map.join("").count('#') - count * monster.join("").count('#')
  else:
    return -1

let chunks = toSeq(get_lines().split((l) => l == ""))
var tiles = chunks.map(parse_tile).toTable
let size = int(sqrt(float(tiles.len)))
#echo fmt"{size} x {size} = {tiles.len}"

part1(tiles, size)

for map in poss_maps:
  let roughness = part2(map)
  if roughness != -1:
    echo roughness
