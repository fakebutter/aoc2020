import sets
import strutils
import utils

type
  Instr = tuple
    opcode: string
    val: int

proc parse(lines: seq[string]): seq[Instr] =
  for line in lines:
    let instr = line.split(' ')
    let
      opcode = instr[0]
      val = parseInt(instr[1])
    result.add((opcode, val))

proc run(instrs: seq[Instr]) =
  var
    ip = 0
    accum = 0
  var visited: HashSet[int]

  while true:
    if ip in visited:
      echo "inf:", accum
      return
    elif ip == instrs.len:
      echo "end:", accum
      return
    visited.incl(ip)

    #echo "ip:", ip
    let instr = instrs[ip]

    case instr.opcode
    of "nop":
      discard
    of "acc":
      accum += instr.val
    of "jmp":
      ip += instr.val
      continue

    ip += 1

proc swap(instrs: var seq[Instr], idx: int) =
  if instrs[idx].opcode == "nop":
    instrs[idx].opcode = "jmp"
  elif instrs[idx].opcode == "jmp":
    instrs[idx].opcode = "nop"

let lines = get_lines()
var instrs = parse(lines)

run(instrs)

for i in 0..<instrs.len:
  swap(instrs, i)
  echo i, ":"
  run(instrs)
  swap(instrs, i)
