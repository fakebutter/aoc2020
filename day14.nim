import re
import sequtils
import strutils
import sugar
import tables
import utils

type
  Mask1 = tuple
    allow, ones, zeroes: int64

  Mask2 = tuple
    ones, floating: int64

proc writeMem1(mem: TableRef[int64, int64], mask: Mask1, address: int, value: int) =
  mem[address] = ((value and mask.allow) or mask.ones) and mask.zeroes

proc forAllPoss(address: int64, mask: Mask2, idx: int, fun: (int64) -> void) =
  if idx < 0:
    fun(address or mask.ones)
    return

  if (mask.floating and (1 shl idx)) > 0:
    forAllPoss(address or (1 shl idx), mask, idx - 1, fun) # Turn on
    forAllPoss(address and (not (1 shl idx)), mask, idx - 1, fun) # Turn off
  else:
    forAllPoss(address, mask, idx - 1, fun)

proc writeMem2(mem: TableRef[int64, int64], mask: Mask2, address: int, value: int) =
  forAllPoss(address, mask, 35, (a: int64) => (mem[a] = value))

proc parseMask1(mask: string): Mask1 =
  result.zeroes = 0xffffffffffffffff
  for (i, c) in mask.pairs:
    let bit = 35 - i
    case c:
      of 'X':
        result.allow = result.allow or (1 shl bit) # AND mask
      of '1':
        result.ones = result.ones or (1 shl bit) # OR mask
      of '0':
        result.zeroes = result.zeroes and (not (1 shl bit)) # AND mask
      else:
        assert(false, $c)

proc parseMask2(mask: string): Mask2 =
  for (i, c) in mask.pairs:
    let bit = 35 - i
    case c:
      of 'X':
        result.floating = result.floating or (1 shl bit) # Bitfield
      of '1':
        result.ones = result.ones or (1 shl bit) # OR mask
      of '0':
        discard
      else:
        assert(false, $c)

proc part1(lines: seq[string]): int64 =
  var
    mask: Mask1
    mem = newTable[int64, int64]()

  for line in lines:
    if line =~ re"mask = (.*)":
      mask = parseMask1(matches[0])
    elif line =~ re"mem\[(\d+)\] = (\d+)":
      writeMem1(mem, mask, parseInt(matches[0]), parseInt(matches[1]))

  return toSeq(mem.values).sum

proc part2(lines: seq[string]): int64 =
  var
    mask: Mask2
    mem = newTable[int64, int64]()

  for line in lines:
    if line =~ re"mask = (.*)":
      mask = parseMask2(matches[0])
    elif line =~ re"mem\[(\d+)\] = (\d+)":
      writeMem2(mem, mask, parseInt(matches[0]), parseInt(matches[1]))

  return toSeq(mem.values).sum

let lines = getLines()
echo part1(lines)
echo part2(lines)
