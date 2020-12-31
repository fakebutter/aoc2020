import re
import sequtils
import strscans
import strutils
import sugar
import tables
import utils

proc parsePassports(lines: seq[string]): seq[string] =
  lines.split.mapIt(it.join(" "))

proc isValidField(key: string, value: string): bool =
  case key:
    of "byr":
      return value >= "1920" and value <= "2002"
    of "iyr":
      return value >= "2010" and value <= "2020"
    of "eyr":
      return value >= "2020" and value <= "2030"
    of "hgt":
      var i: int
      if scanf(value, "$icm", i):
        return i >= 150 and i <= 193
      elif scanf(value, "$iin", i):
        return i >= 59 and i <= 76
      return false
    of "hcl":
      return value =~ re"^#[a-f0-9]{6}$"
    of "ecl":
      return value in ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
    of "pid":
      return value =~ re"^[0-9]{9}$"

proc validatePassport(validateField: bool, passport: string): bool =
  var seen = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"].mapIt((it, false)).toTable

  for entry in passport.split:
    let
      kv = entry.split(":")
      key = kv[0]
      value = kv[1]
    if key in seen and (not validateField or isValidField(key, value)):
      seen[key] = true

  return toSeq(seen.values).count(true) == 7

proc run(passports: seq[string], validator: (string) -> bool): int =
  passports.count(validator)

let passports = getLines().parsePassports
echo run(passports, validatePassport.curry(false))
echo run(passports, validatePassport.curry(true))
