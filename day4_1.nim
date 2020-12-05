import sequtils
import strutils
import tables
import strscans
import re
import utils

proc get_passports(the_lines: seq[string]): seq[string] =
  var
    passports = newSeq[string]()
    current = newSeq[string]()

  for line in the_lines:
    if line != "":
      current.add(line)
    else:
      passports.add(current.join(" "))
      current = newSeq[string]()

  passports.add(current.join(" "))
  return passports

proc is_valid_field(key: string, value: string): bool =
  try:
    case key:
      of "byr":
        let byr = parseInt(value)
        return byr >= 1920 and byr <= 2002
      of "iyr":
        let iyr = parseInt(value)
        return iyr >= 2010 and iyr <= 2020
      of "eyr":
        let eyr = parseInt(value)
        return eyr >= 2020 and eyr <= 2030
      of "hgt":
        var i: int
        if scanf(value, "$icm", i):
          return i >= 150 and i <= 193
        elif scanf(value, "$iin", i):
          return i >= 59 and i <= 76
        return false
      of "hcl":
        return find(value, re"^#[a-f0-9]{6}$") == 0
      of "ecl":
        return anyIt(@["amb", "blu", "brn", "gry", "grn", "hzl", "oth"], it == value)
      of "pid":
        return find(value, re"^[0-9]{9}$") == 0
  except:
    return false

proc check_passport(passport: string, validate_field: bool): bool =
  var seen = initTable[string, bool]()
  for key in ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]:
    seen[key] = false
    
  for entry in passport.split(" "):
    if entry != "":
      let kv = entry.split(":")
      if seen.hasKey(kv[0]) and (not validate_field or is_valid_field(kv[0], kv[1])):
        seen[kv[0]] = true

  return toSeq(seen.values).count(true) == 7

proc main(passports: seq[string], validate_field: bool) =
  echo passports
    .mapIt(if check_passport(it, validate_field): 1 else: 0)
    .foldl(a + b)

let passports = get_passports(get_lines())

main(passports, false)
main(passports, true)
