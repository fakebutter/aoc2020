import algorithm
import sequtils
import utils

proc part1(jolts: seq[int]): int =
  var
    jolts = @[0] & jolts.sorted & @[jolts.max + 3]
    diff1, diff3 = 0

  for (idx, jolt) in jolts.pairs:
    if idx == 0:
      continue

    let prev = jolts[idx - 1]
    if jolt - prev == 1:
      diff1 += 1
    else:
      diff3 += 1

  return diff1 * diff3

proc part2(jolts: seq[int]): int =
  var
    jolts = @[0] & jolts.sorted & @[jolts.max + 3]
    total = repeat(0, jolts.len - 1) & @[1]

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

let jolts = getLines().toInts
echo part1(jolts)
echo part2(jolts)
