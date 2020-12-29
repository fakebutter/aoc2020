import sequtils
import sets
import tables
import utils

proc makePocket(lines: seq[string]): HashSet[V4] =
  for (y, row) in lines.pairs:
    for (x, c) in toSeq(row.items).pairs:
      if c == '#':
        result.incl((x, y, 0, 0))

iterator getAdjacent3(x, y, z: int): V4 =
  for nx in x-1..x+1:
    for ny in y-1..y+1:
      for nz in z-1..z+1:
        if (nx, ny, nz) != (x, y, z):
          yield (nx, ny, nz, 0)

iterator getAdjacent4(x, y, z, w: int): V4 =
  for nx in x-1..x+1:
    for ny in y-1..y+1:
      for nz in z-1..z+1:
        for nw in w-1..w+1:
          if (nx, ny, nz, nw) != (x, y, z, w):
            yield (nx, ny, nz, nw)

proc getAdjacent(pos: V4, dim: int): seq[V4] =
  if dim == 3:
    return toSeq(getAdjacent3(pos.x, pos.y, pos.z))
  elif dim == 4:
    return toSeq(getAdjacent4(pos.x, pos.y, pos.z, pos.w))

proc countActiveNeighbors(pocket: var HashSet[V4], pos: V4, dim: int): int =
  getAdjacent(pos, dim).countIt(it in pocket)

proc step(pocket: var HashSet[V4], dim: int) =
  var
    activated = newSeq[V4]()
    deactivated = newSeq[V4]()
    shaded = initCountTable[V4]()

  for pos in pocket.items:
    # Turn on
    let active = countActiveNeighbors(pocket, pos, dim)
    if active != 2 and active != 3:
      deactivated.add(pos)

    for adj in getAdjacent(pos, dim):
      shaded.inc(adj)
  
  # Turn off
  for (pos, count) in shaded.pairs:
    if (pos notin pocket) and count == 3:
      activated.add(pos)

  pocket.incl(toHashSet(activated))
  pocket.excl(toHashSet(deactivated))

proc run(pocket: HashSet[V4], dim: int): int =
  var pocket = pocket
  for i in 0..<6:
    step(pocket, dim)
  return pocket.len

let
  pocket = makePocket(getLines())
echo run(pocket, 3)
echo run(pocket, 4)
