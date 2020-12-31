import sequtils
import strscans
import utils

proc part1IsValid(line: string): bool =
  var
    minCount, maxCount: int
    character, password: string

  if scanf(line, "$i-$i $w: $+$.", minCount, maxCount, character, password):
    let count = toSeq(password.items).count(character[0])
    return minCount <= count and count <= maxCount

proc part2IsValid(line: string): bool =
  var
    i, j: int
    character, password: string

  if scanf(line, "$i-$i $w: $+$.", i, j, character, password):
    return (password[i - 1] == character[0]) xor (password[j - 1] == character[0])

let lines = getLines()
echo lines.count(part1IsValid)
echo lines.count(part2IsValid)
