import sequtils
import sugar
import tables
import utils

iterator part1(groups: seq[seq[string]]): int =
  for group in groups:
    var seen: set[char] = {}
    for answer in group:
      for c in answer.items:
        seen.incl(c)

    yield seen.len

iterator part2(groups: seq[seq[string]]): int =
  for group in groups:
    var counter = newCountTable[char]()
    for answer in group:
      for c in answer.items:
        counter.inc(c)

    yield toSeq(counter.values).count(group.len)

let groups = get_lines().chunkify((l) => l == "")
echo toSeq(part1(groups)).sum
echo toSeq(part2(groups)).sum
