import utils

const
  base = 7
  group = 20201227

proc findExp(value: int): int =
  var cur = 1
  while cur != value:
    cur = (cur * base) mod group
    result += 1
  return result

proc findSharedSecret(public1, public2: int): int =
  let doorExp = findExp(public1)
  result = 1
  for _ in 1..doorExp:
    result = (result * public2) mod group

let inputs = getLines().toInts
echo findSharedSecret(inputs[0], inputs[1])
