import utils
import tables
import strutils
import sequtils

proc part1(numbers: seq[int]) =
  let last_seen = newTable[int, int]()

  for (idx, num) in numbers[0..^2].pairs:
    last_seen[num] = idx + 1

  var turn = numbers.len + 1
  var last_num = numbers[^1]

  while turn <= 30000000:
    var num: int
    if last_num in last_seen:
      num = turn - 1 - last_seen[last_num]
    else:
      num = 0
    #echo turn, ",", num

    last_seen[last_num] = turn - 1
    last_num = num
    turn += 1

  echo last_num

let numbers = get_lines()[0].split(",").map(parseInt)
part1(numbers)
