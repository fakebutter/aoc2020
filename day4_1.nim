import re
import sequtils
import strscans
import strutils
import sugar
import tables
import utils

proc get_passports(lines: seq[string]): seq[string] =
  return lines.chunkify((l) => l == "").mapIt(it.join(" "))

proc is_valid_field(key: string, value: string): bool =
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

proc check_passport(passport: string, validate_field: bool): bool =
  var seen = {"byr": false, "iyr": false, "eyr": false, "hgt": false, "hcl": false, "ecl": false, "pid": false}.toTable
    
  for entry in passport.split(" ").filter((e) => e != ""):
    let kv = entry.split(":")
    if seen.hasKey(kv[0]) and (not validate_field or is_valid_field(kv[0], kv[1])):
      seen[kv[0]] = true

  return toSeq(seen.values).count(true) == 7

proc run(passports: seq[string], validate_field: bool) =
  echo passports
    .countIt(check_passport(it, validate_field))

let passports = get_passports(get_lines())
run(passports, false)
run(passports, true)
