import algorithm
import itertools
import math
import sequtils
import utils

proc bsearch(low: int, high: int, instr: string): int =
  var
    low = low
    high = high
  for c in instr.items:
    let mid = float(low + high) / 2.0
    if c in ['F', 'L']:
      high = floor(mid).int
    else:
      low = ceil(mid).int
  assert(low == high)
  return low

proc getSeat(line: string): int =
  let
    row = bsearch(0, 127, line[0..<7])
    col = bsearch(0, 7, line[7..<10])
  return row * 8 + col

proc findGaps(seats: seq[int]): seq[int] =
  for pair in seats.pairwise:
    if pair[0] + 1 != pair[1]:
      for i in pair[0]+1..<pair[1]:
        result.add(i)

proc part2(seats: seq[int]): int =
  let gaps = findGaps(seats.sorted)
  assert gaps.len == 1
  return gaps.first

let seats = getLines().map(getSeat)
echo max(seats)
echo part2(seats)
