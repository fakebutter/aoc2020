import utils
import tables
import strutils
import sequtils

proc run(numbers: seq[int], rounds: int): int =
  let last_seen = newTable[int, int]()

  for (idx, num) in numbers[0..^2].pairs:
    last_seen[num] = idx + 1

  var turn = numbers.len + 1
  var last_num = numbers[^1]

  while turn <= rounds:
    var num: int
    if last_num in last_seen:
      num = turn - 1 - last_seen[last_num]
    else:
      num = 0

    last_seen[last_num] = turn - 1
    last_num = num
    turn += 1

  return last_num

let numbers = get_lines()[0].split(",").map(parseInt)
echo run(numbers, 2020)
echo run(numbers, 30000000)
