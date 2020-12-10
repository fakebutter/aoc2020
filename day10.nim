import algorithm
import sequtils
import strutils
import sugar
import utils

proc part1(jolts: seq[int]) =
  var jolts = sorted(jolts)
  jolts.add(max(jolts) + 3)
  var
    diff1, diff3 = 0

  for (idx, jolt) in jolts.pairs:
    let prev = if idx == 0:
      0
    else:
      jolts[idx - 1]

    if jolt - prev == 1:
      diff1 += 1
    else:
      diff3 += 1

  echo diff1 * diff3

proc part2(jolts: seq[int]) =
  var jolts = sorted(jolts)
  jolts.insert(0, 0)
  jolts.add(max(jolts) + 3)

  var total = jolts.map((_) => 0)
  total[^1] = 1

  var i = jolts.len - 2
  while i >= 0:
    var subtotal = 0

    for j in i+1..<jolts.len:
      if jolts[j] - jolts[i] <= 3:
        subtotal += total[j]
      else:
        break

    total[i] = subtotal
    i -= 1

  echo total[0]

let jolts = get_lines().map(parseInt)
part1(jolts)
part2(jolts)
