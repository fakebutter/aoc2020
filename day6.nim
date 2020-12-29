import sequtils
import tables
import utils

proc part1(groups: seq[seq[string]]): int =
  for group in groups:
    var seen: set[char]
    for answer in group:
      for c in answer.items:
        seen.incl(c)

    result += seen.len

proc part2(groups: seq[seq[string]]): int =
  for group in groups:
    var counter: CountTable[char]
    for answer in group:
      for c in answer.items:
        counter.inc(c)

    result += toSeq(counter.values).count(group.len)

let groups = getLines().split
echo part1(groups)
echo part2(groups)
