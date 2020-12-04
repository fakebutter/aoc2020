import strutils

var nums = newSeq[int]()
var line: string
while readLine(stdin, line):
  nums.add(parseInt(line))

proc part1(nums: seq[int]) =
  for i in 0..<nums.len-1:
    for j in i+1..<nums.len:
      if nums[i] + nums[j] == 2020:
        echo nums[i] * nums[j]
        break

proc part2(nums: seq[int]) =
  for i in 0..<nums.len-2:
    for j in i+1..<nums.len-1:
      for k in j+1..<nums.len:
        if nums[i] + nums[j] + nums[k] == 2020:
          echo nums[i] * nums[j] * nums[k]
          break

part1(nums)
part2(nums)
