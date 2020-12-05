import utils
import algorithm
import sequtils
import math

proc get_seat(line: string): int =
  var
    row_low = 0
    row_high = 127
    col_low = 0
    col_high = 7

  for c in line[0..<7].items:
    let mid = float(row_low + row_high) / 2.0
    if c == 'F':
      row_high = floor(mid).int
    else:
      row_low = ceil(mid).int

  for c in line[7..<10].items:
    let mid = float(col_low + col_high) / 2.0
    if c == 'L':
      col_high = floor(mid).int
    else:
      col_low = ceil(mid).int

  assert(row_low == row_high)
  assert(col_low == col_high)
  return row_low * 8 + col_low

proc find_gaps(seats: seq[int]): seq[int] =
  var prev = -1
  for seat in seats:
    if prev != -1:
      if seat > prev + 1:
        for i in prev+1..<seat:
          result.add(i)
    prev = seat

let seats = get_lines().map(get_seat)
echo max(seats)

echo(min(seats), " ", max(seats))
echo find_gaps(sorted(seats, system.cmp[int]))
