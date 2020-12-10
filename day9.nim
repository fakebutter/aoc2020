import deques
import sequtils
import strutils
import utils

proc part1(nums: seq[int]): int =
  var history = initDeque[int]()
  for i in nums[0..<25]:
    history.addLast(i)

  for num in nums[25..^1]:
    var valid = false
    for i in history:
      let j = num - i
      if i != j and j in history:
        valid = true

    if not valid:
      return num

    history.popFirst()
    history.addLast(num)

proc found(nums: seq[int], start: int, stop: int) =
  let sub = nums[start..stop]
  echo min(sub) + max(sub)

proc part2(nums: seq[int], target: int): (int, int) =
  var sums = newSeq[int]()
  for (i, num) in nums.pairs:
    if i == 0:
      sums.add(num)
    else:
      sums.add(sums[i - 1] + num)

    if sums[i] == target:
      return (0, i)
    for j in 0..<i:
      if sums[i] - sums[j] == target:
        return (j, i)

let nums = get_lines().map(parseInt)
let p1 = part1(nums)
echo p1
let (start, stop) = part2(nums, p1)
found(nums, start, stop)
