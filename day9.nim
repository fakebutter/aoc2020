import deques
import utils

proc part1(nums: seq[int]): int =
  var history: Deque[int]
  for i in nums[0..<25]:
    history.addLast(i)

  for num in nums[25..^1]:
    var valid = false
    for i in history:
      let j = num - i
      if i != j and j in history:
        valid = true
        break

    if not valid:
      return num

    history.popFirst()
    history.addLast(num)

proc findRange(nums: seq[int], target: int): Pair[int] =
  var sums: seq[int]
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

proc part2(nums: seq[int], magic: int): int =
  let
    range = findRange(nums, magic)
    sub = nums[range.first..range.second]
  return min(sub) + max(sub)

let nums = getLines().toInts
let magic = part1(nums)
echo magic
echo part2(nums, magic)
