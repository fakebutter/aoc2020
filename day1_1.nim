import strutils
import sequtils
import utils

let nums = get_lines().mapIt(parseInt(it))

iterator comb2(max: int): (int, int) =
  for i in 0..<max-1:
    for j in i+1..<max:
      yield (i, j)

iterator comb3(max: int): (int, int, int) =
  for i in 0..<max-2:
    for j in i+1..<max-1:
      for k in j+1..<max:
        yield (i, j, k)

proc part1(nums: seq[int]) =
  for (i, j) in comb2(nums.len):
    if nums[i] + nums[j] == 2020:
      echo nums[i] * nums[j]
      break

proc part2(nums: seq[int]) =
  for (i, j, k) in comb3(nums.len):
    if nums[i] + nums[j] + nums[k] == 2020:
      echo nums[i] * nums[j] * nums[k]
      break

part1(nums)
part2(nums)
