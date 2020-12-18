import itertools
import sequtils
import strutils
import utils

proc run(nums: seq[int], c: int): int =
  for comb in combinations(nums, c):
    if comb.sum == 2020:
      return comb.product

let nums = get_lines().map(parseInt)
echo run(nums, 2)
echo run(nums, 3)
