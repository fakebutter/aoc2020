import sets
import strutils
import utils

type
  Instr = tuple
    opcode: string
    val: int

  Result = enum
    Infinite, Halt

proc parse(lines: seq[string]): seq[Instr] =
  for line in lines:
    let instr = line.split(' ')
    result.add((opcode: instr[0], val: parseInt(instr[1])))

proc run(instrs: seq[Instr]): (Result, int) =
  var
    ip = 0
    accum = 0
  var visited: HashSet[int]

  while true:
    if ip in visited:
      return (Infinite, accum)
    elif ip == instrs.len:
      return (Halt, accum)

    visited.incl(ip)

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

proc flip(instrs: var seq[Instr], idx: int) =
  if instrs[idx].opcode == "nop":
    instrs[idx].opcode = "jmp"
  elif instrs[idx].opcode == "jmp":
    instrs[idx].opcode = "nop"

var instrs = parse(get_lines())

echo run(instrs)

for i in 0..<instrs.len:
  flip(instrs, i)
  let (result, accum) = run(instrs)
  if result == Halt:
    echo accum
  flip(instrs, i)
