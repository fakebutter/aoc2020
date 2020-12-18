import algorithm
import sequtils
import strutils
import utils

proc part1(jolts: seq[int]): int =
  var
    diff1, diff3 = 0
    jolts = sorted(jolts)
  jolts.add(max(jolts) + 3)

  for (idx, jolt) in jolts.pairs:
    let prev = if idx == 0: 0 else: jolts[idx - 1]

    if jolt - prev == 1:
      diff1 += 1
    else:
      diff3 += 1

  return diff1 * diff3

proc part2(jolts: seq[int]): int =
  var jolts = sorted(jolts)
  jolts.insert(0, 0)
  jolts.add(max(jolts) + 3)

  var total = repeat(0, jolts.len - 1)
  total.add(1)

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

  return total[0]

let jolts = get_lines().map(parseInt)
echo part1(jolts)
echo part2(jolts)
