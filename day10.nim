import algorithm
import sequtils
import strutils
import sugar
import utils

proc part1(jolts: seq[int]) =
  var jolts = sorted(jolts)

  var
    diff1, diff3 = 0
  for (idx, jolt) in jolts.pairs:
    var prev: int
    if idx == 0:
      prev = 0
    else:
      prev = jolts[idx - 1]

    if jolt - prev == 1:
      diff1 += 1
    else:
      diff3 += 1

  let prev = jolts[^1]
  let final = max(jolts) + 3
  if final - prev == 1:
    diff1 += 1
  else:
    diff3 += 1

  echo diff1 * diff3

proc part2(jolts: seq[int]) =
  var jolts = sorted(jolts)
  jolts.add(max(jolts) + 3)
  var total = jolts.map((_) => 0)
  total[^1] = 1

  var i = jolts.len - 2
  while i >= 0:
    let cur = jolts[i]
    var subtotal = 0
    for j in i+1..<jolts.len:
      let next = jolts[j]
      if next - cur <= 3:
        subtotal += total[j]
      else:
        break
    total[i] = subtotal

    i -= 1

  var subtotal = 0
  let cur = 0
  for i in 0..<jolts.len:
    let next = jolts[i]
    if next - cur <= 3:
      subtotal += total[i]
    else:
      break

  echo subtotal

let jolts = get_lines().map(parseInt)
part1(jolts)
part2(jolts)
