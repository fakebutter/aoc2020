import deques
import sequtils
import strutils
import utils

proc part1(nums: seq[int]): int =
  var history = initDeque[int]()

  for num in nums:
    if history.len < 25:
      history.addLast(num)
      continue
    else:
      var valid = false
      for i in history:
        let j = num - i
        if i != j and j in history:
          valid = true

      if not valid:
        return num

    if history.len == 25:
      history.popFirst()
    history.addLast(num)

proc found(nums: seq[int], start: int, stop: int) =
  var xs = newSeq[int]()
  for i in start..stop:
    xs.add(nums[i])
  echo min(xs) + max(xs)

proc part2(nums: seq[int], target: int) =
  var sums = newSeq[int]()
  for (i, num) in nums.pairs:
    if i == 0:
      sums.add(num)
    else:
      sums.add(sums[i - 1] + num)

    if sums[i] == target:
      found(nums, 0, i)
      return
    for j in 0..<i:
      if sums[i] - sums[j] == target:
        found(nums, j, i)
        return

let nums = get_lines().map(parseInt)
let p1 = part1(nums)
echo p1
part2(nums, p1)
