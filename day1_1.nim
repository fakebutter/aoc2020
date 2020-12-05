import sequtils
import strutils
import utils

iterator comb2(max: int): (int, int) =
  for i in 0..<max-1:
    for j in i+1..<max:
      yield (i, j)

iterator comb3(max: int): (int, int, int) =
  for i in 0..<max-2:
    for j in i+1..<max-1:
      for k in j+1..<max:
        yield (i, j, k)

proc part1(nums: seq[int]): int =
  for (i, j) in comb2(nums.len):
    if nums[i] + nums[j] == 2020:
      return nums[i] * nums[j]

proc part2(nums: seq[int]): int =
  for (i, j, k) in comb3(nums.len):
    if nums[i] + nums[j] + nums[k] == 2020:
      return nums[i] * nums[j] * nums[k]

let nums = get_lines().map(parseInt)
echo part1(nums)
echo part2(nums)
