import sequtils
import sets
import tables
import utils

proc makePocket(lines: seq[string]): HashSet[V4] =
  for (y, row) in lines.pairs:
    for (x, c) in toSeq(row.items).pairs:
      if c == '#':
        result.incl((x, y, 0, 0))

iterator getAdjacent3(pos: V4): V4 =
  for x in pos.x-1..pos.x+1:
    for y in pos.y-1..pos.y+1:
      for z in pos.z-1..pos.z+1:
        if (x, y, z, 0) != pos:
          yield (x, y, z, 0)

iterator getAdjacent4(pos: V4): V4 =
  for x in pos.x-1..pos.x+1:
    for y in pos.y-1..pos.y+1:
      for z in pos.z-1..pos.z+1:
        for w in pos.w-1..pos.w+1:
          if (x, y, z, w) != pos:
            yield (x, y, z, w)

proc getAdjacent(pos: V4, dim: int): seq[V4] =
  if dim == 3:
    return toSeq(getAdjacent3(pos))
  elif dim == 4:
    return toSeq(getAdjacent4(pos))

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
