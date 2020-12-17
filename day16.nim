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
      field: matches[0],
      range1: (parseInt(matches[1]), parseInt(matches[2])),
      range2: (parseInt(matches[3]), parseInt(matches[4]))
    )
  else:
    assert(false)

proc is_in(value: int, the_range: (int, int)): bool =
  the_range[0] <= value and value <= the_range[1]

proc match(rule: Rule, value: int): bool =
  is_in(value, rule.range1) or is_in(value, rule.range2)

################################################################################

proc get_bad_fields(ticket: seq[int], rules: seq[Rule]): seq[int] =
  let no_matching_rules = proc (field: int): bool =
    not rules.mapIt(it.match(field)).any(identity)

  ticket.filter(no_matching_rules)

proc part1(rules: seq[Rule], ticket: seq[int], nearby: seq[seq[int]]) =
  let bad_fields = nearby.mapIt(get_bad_fields(it, rules)).concat
  echo bad_fields.sum

################################################################################

proc solve(poss: Table[int, HashSet[string]]): Table[int, string] =
  var
    poss = poss
    idx: int
    match: string

  while poss.len > 0:
    # Find field with only one matching rule remaining.
    for (i, fields) in poss.pairs:
      if fields.len == 1:
        idx = i
        match = toSeq(fields.items)[0]
        result[idx] = match
        break

    # Prune
    poss.del(idx)
    for (i, fields) in poss.pairs:
      poss[i].excl(match)

proc build_poss(rules: seq[Rule], good_tickets: seq[seq[int]]): Table[int, HashSet[string]] =
  for idx in 0..<good_tickets[0].len:
    let values = good_tickets.mapIt(it[idx])
    let matches_all_values = proc (rule: Rule): bool =
      values.mapIt(rule.match(it)).all(identity)

    # Find rules that match all values in the current position.
    let matching_rules = rules.filter(matches_all_values)
    result[idx] = toHashSet(matching_rules.mapIt(it.field))

proc part2(rules: seq[Rule], ticket: seq[int], nearby: seq[seq[int]]) =
  let is_good_ticket = proc (tix: seq[int]): bool =
    get_bad_fields(tix, rules).len == 0

  let good_tickets = nearby.filter(is_good_ticket)
  let poss = build_poss(rules, good_tickets)
  let soln = solve(poss)

  var prod = 1
  for (idx, field) in soln.pairs:
    if field.find("departure") != -1:
      prod *= ticket[idx]
  echo prod

################################################################################

let
  input = toSeq(get_lines().split((l) => l == ""))
  rules = input[0].map(parse_rule)
  ticket = input[1][1].split(",").map(parseInt)
  nearby = input[2][1..^1].mapIt(it.split(",").map(parseInt))

part1(rules, ticket, nearby)
part2(rules, ticket, nearby)
