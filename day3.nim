import sequtils
import utils

proc countTrees(map: seq[seq[char]], step: V2): int =
  let
    width = map[0].len
    height = map.len
  var cur: V2

  while cur.y < height:
    if map[cur.y][cur.x] == '#':
      result += 1
    cur += step
    cur.x = cur.x mod width

proc run(map: seq[seq[char]], steps: seq[V2]): int =
  steps
    .mapIt(countTrees(map, it))
    .product

let map = getLines().to2dArr
echo run(map, @[(3, 1)])
echo run(map, @[(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)])
