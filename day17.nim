import sequtils
import sets
import tables
import utils

type
  V4 = tuple
    x, y, z, w: int

proc make_pocket(lines: seq[string]): HashSet[V4] =
  for (y, row) in lines.pairs:
    for (x, c) in toSeq(row.items).pairs:
      if c == '#':
        result.incl((x, lines.len - y - 1, 0, 0))

iterator get_adjacent3(x, y, z: int): V4 =
  for nx in x-1..x+1:
    for ny in y-1..y+1:
      for nz in z-1..z+1:
        if (nx, ny, nz) != (x, y, z):
          yield (nx, ny, nz, 0)

iterator get_adjacent4(x, y, z, w: int): V4 =
  for nx in x-1..x+1:
    for ny in y-1..y+1:
      for nz in z-1..z+1:
        for nw in w-1..w+1:
          if (nx, ny, nz, nw) != (x, y, z, w):
            yield (nx, ny, nz, nw)

proc get_adjacent(pos: V4, dim: int): seq[V4] =
  if dim == 3:
    return toSeq(get_adjacent3(pos.x, pos.y, pos.z))
  elif dim == 4:
    return toSeq(get_adjacent4(pos.x, pos.y, pos.z, pos.w))

proc count_active_neighbors(pocket: HashSet[V4], pos: V4, dim: int): int =
  get_adjacent(pos, dim)
    .mapIt(it in pocket)
    .count(true)

proc step(pocket: var HashSet[V4], dim: int) =
  var
    activated = newSeq[V4]()
    deactivated = newSeq[V4]()
    shaded = initCountTable[V4]()

  for pos in pocket.items:
    let active = count_active_neighbors(pocket, pos, dim)
    if active != 2 and active != 3:
      deactivated.add(pos)

    for n in get_adjacent(pos, dim):
      shaded.inc(n)
  
  for (pos, count) in shaded.pairs:
    if (pos notin pocket) and count == 3:
      activated.add(pos)

  for pos in activated:
    pocket.incl(pos)
  for pos in deactivated:
    pocket.excl(pos)

proc run(pocket: HashSet[V4], dim: int) =
  var pocket = pocket
  for i in 0..<6:
    step(pocket, dim)
  echo pocket.len

let lines = get_lines()
let pocket = make_pocket(lines)
run(pocket, 3)
run(pocket, 4)
