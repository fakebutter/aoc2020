import sequtils
import utils

proc make_map(lines: seq[string]): seq[seq[char]] =
  lines.mapIt(toSeq(it.items))

proc count_trees(map: seq[seq[char]], steps: (int, int)): int =
  let
    width = map[0].len
    (row_step, col_step) = steps
  var row, col = 0

  while row < map.len:
    if map[row][col] == '#':
      result += 1
    row += row_step
    col = (col + col_step) mod width

proc run(map: seq[seq[char]], steps: seq[(int, int)]): int =
  return steps
    .mapIt(count_trees(map, it))
    .product

let map = make_map(get_lines())
echo run(map, @[(1, 3)])
echo run(map, @[(1, 1), (1, 3), (1, 5), (1, 7), (2, 1)])
