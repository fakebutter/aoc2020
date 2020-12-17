import re
import sequtils
import strutils
import sugar
import tables
import utils

type
  Mask = tuple
    allow, ones, zeroes, floating: int64

proc write_mem1(mem: var TableRef[int64, int64], mask: Mask, address: int, value: int) =
  mem[address] = ((value and mask.allow) or mask.ones) and mask.zeroes

proc write_mem2(mem: TableRef[int64, int64], mask: Mask, address: int, value: int) =
  proc for_all_poss(address: int64, idx: int, fun: (a: int64) -> void) =
    if idx < 0:
      fun(address)
      return

    if (mask.floating and (1 shl idx)) > 0:
      for_all_poss(address or (1 shl idx), idx - 1, fun)
      for_all_poss(address and (not (1 shl idx)), idx - 1, fun)
    else:
      for_all_poss(address, idx - 1, fun)

  var address = (address or mask.ones)
  let set_mem = proc (address: int64) =
    mem[address] = value

  for_all_poss(address, 35, set_mem)

proc parse_mask1(mask: string): Mask =
  result.zeroes = 0xffffffffffffffff
  for (i, bit) in mask.pairs:
    let idx = 35 - i
    case bit:
      of 'X':
        result.allow = result.allow or (1 shl idx)
      of '1':
        result.ones = result.ones or (1 shl idx)
      of '0':
        result.zeroes = result.zeroes and (not (1 shl idx))
      else:
        assert(false)

proc parse_mask2(mask: string): Mask =
  result.zeroes = 0xffffffffffffffff
  for (i, bit) in mask.pairs:
    let idx = 35 - i
    case bit:
      of 'X':
        result.floating = result.floating or (1 shl idx)
      of '1':
        result.ones = result.ones or (1 shl idx)
      of '0':
        discard
      else:
        assert(false)

proc part1(lines: seq[string]) =
  var mask: Mask = (0i64, 0i64, 0i64, 0i64)
  var mem = newTable[int64, int64]()

  for line in lines:
    if line =~ re"mask = (.*)":
      mask = parse_mask1(matches[0])
    elif line =~ re"mem\[(\d+)\] = (\d+)":
      write_mem1(mem, mask, parseInt(matches[0]), parseInt(matches[1]))

  echo toSeq(mem.values).sum

proc part2(lines: seq[string]) =
  var mask: Mask = (0i64, 0i64, 0i64, 0i64)
  var mem = newTable[int64, int64]()

  for line in lines:
    if line =~ re"mask = (.*)":
      mask = parse_mask2(matches[0])
    elif line =~ re"mem\[(\d+)\] = (\d+)":
      write_mem2(mem, mask, parseInt(matches[0]), parseInt(matches[1]))

  echo toSeq(mem.values).sum

let lines = get_lines()
part1(lines)
part2(lines)
