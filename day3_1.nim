import sequtils
import utils

proc make_map(lines: seq[string]): seq[seq[char]] =
  var map = newSeq[seq[char]]()
  for line in lines:
    map.add(toSeq(line.items))
  return map

proc count_trees(map: seq[seq[char]], steps: (int, int)): int =
  let width = map[0].len
  let (row_step, col_step) = steps

  var
    row = 0
    col = 0
    tree_count = 0

  while row < map.len:
    if map[row][col] == '#':
      tree_count += 1
    row += row_step
    col = (col + col_step) mod width

  return tree_count

proc run(map: seq[seq[char]], steps: seq[(int, int)]) =
  echo steps
    .mapIt(count_trees(map, it))
    .foldl(a * b)

let map = make_map(get_lines())
run(map, @[(1, 3)])
run(map, @[(1, 1), (1, 3), (1, 5), (1, 7), (2, 1)])
