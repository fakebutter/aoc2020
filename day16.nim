import re
import sequtils
import sets
import strutils
import sugar
import tables
import utils

type
  Rule = tuple
    field: string
    range1, range2: (int, int)

proc parse_rule(rule: string): Rule =
  if rule =~ re"([^:]+): (\d+)-(\d+) or (\d+)-(\d+)":
    return (
      matches[0],
      (parseInt(matches[1]), parseInt(matches[2])),
      (parseInt(matches[3]), parseInt(matches[4]))
    )
  else:
    assert(false)

proc is_in(value: int, the_range: (int, int)): bool =
  the_range[0] <= value and value <= the_range[1]

proc validate(ticket: seq[int], rules: seq[Rule]): seq[int] =
  for field in ticket:
    var good = false
    for rule in rules:
      if is_in(field, rule.range1) or is_in(field, rule.range2):
        good = true
        break
    if not good:
      result.add(field)

proc part1(rules: seq[Rule], ticket: seq[int], nearby: seq[seq[int]]) =
  var bad = newSeq[int]()
  for tix in nearby:
    for b in validate(tix, rules):
      bad.add(b)

  echo bad.sum

proc solve(poss: TableRef[int, HashSet[string]]): Table[int, string] =
  var poss = poss

  while poss.len > 0:
    var
      idx: int
      match: string

    for (i, fields) in poss.pairs:
      if fields.len == 1:
        idx = i
        match = toSeq(fields.items)[0]
        break

    poss.del(idx)
    for (i, fields) in poss.pairs:
      poss[i].excl(match)
    result[idx] = match

proc part2(rules: seq[Rule], ticket: seq[int], nearby: seq[seq[int]]) =
  var good_tickets = newSeq[seq[int]]()
  for tix in nearby:
    if validate(tix, rules).len == 0:
      good_tickets.add(tix)

  var poss = newTable[int, HashSet[string]]()
  for idx in 0..<good_tickets[0].len:
    let values = good_tickets.mapIt(it[idx])
    for rule in rules:
      if values.mapIt(is_in(it, rule.range1) or is_in(it, rule.range2)).all(identity):
        if idx notin poss:
          poss[idx] = initHashSet[string]()
        poss[idx].incl(rule.field)

  var prod = 1
  for (idx, field) in solve(poss).pairs:
    if field.find("departure") != -1:
      prod *= ticket[idx]
  echo prod

let
  input = toSeq(get_lines().split((l) => l == ""))
  rules = input[0].map(parse_rule)
  ticket = input[1][1].split(",").map(parseInt)
  nearby = input[2][1..^1].mapIt(it.split(",").map(parseInt))

part1(rules, ticket, nearby)
part2(rules, ticket, nearby)
