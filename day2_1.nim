import sequtils
import strscans
import utils

proc is_valid1(line: string): bool =
  var min_count, max_count: int
  var character, password: string

  if scanf(line, "$i-$i $w: $+$.", min_count, max_count, character, password):
    let count = toSeq(password.items).filterIt(it == character[0]).len
    return min_count <= count and count <= max_count
  return false

proc is_valid2(line: string): bool =
  var i, j: int
  var character, password: string

  if scanf(line, "$i-$i $w: $+$.", i, j, character, password):
    return password[i - 1] == character[0] xor password[j - 1] == character[0]
  return false

let lines = get_lines()
echo lines.map(is_valid1).count(true)
echo lines.map(is_valid2).count(true)
