import strutils
import tables
import utils

proc run(numbers: seq[int], rounds: int): int =
  var
    lastSeen: Table[int, int]
    lastNum = numbers[^1]
    turn = numbers.len + 1

  for (idx, num) in numbers[0..^2].pairs:
    lastSeen[num] = idx + 1

  while turn <= rounds:
    let num = if lastNum in lastSeen:
      turn - 1 - lastSeen[lastNum]
    else:
      0

    lastSeen[lastNum] = turn - 1
    lastNum = num
    turn += 1

  return lastNum

let numbers = getLines()[0].split(",").toInts
echo run(numbers, 2020)
echo run(numbers, 30000000)
