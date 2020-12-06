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
    var count = newTable[char, int]()
    for answer in group:
      for c in answer.items:
        count[c] = count.getOrDefault(c, 0) + 1

    let size = group.len
    yield toSeq(count.values).filterIt(it == size).len

let groups = get_lines().chunkify((l) => l == "")
echo toSeq(part1(groups)).sum
echo toSeq(part2(groups)).sum
