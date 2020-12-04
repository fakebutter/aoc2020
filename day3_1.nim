import sequtils

var the_lines = newSeq[string]()
var line: string
while readLine(stdin, line):
  the_lines.add(line)

proc make_map(the_lines: seq[string]): seq[seq[char]] =
  var map = newSeq[seq[char]]()
  for line in the_lines:
    map.add(toSeq(line.items))
  return map

proc count_trees(map: seq[seq[char]], steps: array[2, int]): int =
  let width = map[0].len

  var row = 0
  var col = 0
  var tree_count = 0

  while row < map.len:
    if map[row][col] == '#':
      tree_count += 1
    row += steps[0]
    col = (col + steps[1]) mod width

  return tree_count

let map = make_map(the_lines)
echo foldl(
  mapIt(@[
    [1, 1], [1, 3], [1, 5], [1, 7], [2, 1]
  ], count_trees(map, it)),
  a * b)
