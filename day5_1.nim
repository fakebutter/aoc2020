import algorithm
import math
import sequtils
import utils
import itertools

proc bsearch(low: int, high: int, instr: string): int =
  var
    high = high
    low = low
  for c in instr.items:
    let mid = float(low + high) / 2.0
    if c in ['F', 'L']:
      high = floor(mid).int
    else:
      low = ceil(mid).int
  assert(low == high)
  return low

proc get_seat(line: string): int =
  let
    row = bsearch(0, 127, line[0..<7])
    col = bsearch(0, 7, line[7..<10])
  return row * 8 + col

proc find_gaps(seats: seq[int]): seq[int] =
  for pair in seats.windowed(2):
    if pair[0] + 1 != pair[1]:
      for i in pair[0]+1..<pair[1]:
        result.add(i)

let seats = get_lines().map(get_seat)
echo max(seats)
echo(min(seats), "->", max(seats))
echo find_gaps(sorted(seats, system.cmp[int]))
