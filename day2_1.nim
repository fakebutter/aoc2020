import sequtils
import strscans

var the_lines = newSeq[string]()
var line: string
while readLine(stdin, line):
  the_lines.add(line)

proc part1(the_lines: seq[string]) =
  var valid_count = 0
  for line in the_lines:
    var min_count, max_count: int
    var character, password: string

    if scanf(line, "$i-$i $w: $+$.", min_count, max_count, character, password):
      let count = filter(toSeq(password.items), proc(c: char): bool = c == character[0]).len
      if min_count <= count and count <= max_count:
        valid_count += 1

  echo valid_count

proc part2(the_lines: seq[string]) =
  var valid_count = 0
  for line in the_lines:
    var i, j: int
    var character, password: string

    if scanf(line, "$i-$i $w: $+$.", i, j, character, password):
      if password[i - 1] == character[0] xor password[j - 1] == character[0]:
        valid_count += 1

  echo valid_count

part1(the_lines)
part2(the_lines)
