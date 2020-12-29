import sequtils
import strutils
import utils

proc findExp(public: int): int =
  var
    exp = 0
    cur = 1
  while cur != public:
    cur = (cur * 7) mod 20201227
    exp += 1
  return exp

proc part1(cardPublic, doorPublic: int): int =
  let doorExp = findExp(doorPublic)
  result = 1
  for _ in 1..doorExp:
    result = (result * cardPublic) mod 20201227

let
  inputs = getLines().map(parseInt)
  cardPublic = inputs[0]
  doorPublic = inputs[1]

echo part1(cardPublic, doorPublic)
