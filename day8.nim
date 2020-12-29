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
    let instr = line.split
    result.add((opcode: instr[0], val: parseInt(instr[1])))

proc run(instrs: seq[Instr]): (Result, int) =
  var
    ip = 0
    accum = 0
    visited: HashSet[int]

  while true:
    if ip in visited:
      return (Infinite, accum)
    elif ip == instrs.len:
      return (Halt, accum)

    visited.incl(ip)

    let instr = instrs[ip]
    case instr.opcode
      of "nop":
        ip += 1
        discard
      of "acc":
        accum += instr.val
        ip += 1
      of "jmp":
        ip += instr.val
        continue

proc flip(instrs: var seq[Instr], idx: int) =
  case instrs[idx].opcode:
    of "nop":
      instrs[idx].opcode = "jmp"
    of "jmp":
      instrs[idx].opcode = "nop"

proc part2(instrs: var seq[Instr]): (Result, int) =
  for i in 0..<instrs.len:
    flip(instrs, i)
    let res = run(instrs)
    if res[0] == Halt:
      return res
    flip(instrs, i)

var instrs = parse(get_lines())
echo run(instrs)
echo part2(instrs)
