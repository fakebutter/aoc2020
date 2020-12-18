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

proc match(rule: Rule, value: int): bool =
  (rule.range1[0] <= value and value <= rule.range1[1]) or
    (rule.range2[0] <= value and value <= rule.range2[1])

################################################################################

# Part 1

proc get_bad_fields(ticket: seq[int], rules: seq[Rule]): seq[int] =
  let no_matching_rules = proc (field: int): bool =
    rules
      .mapIt(it.match(field))
      .none
  ticket.filter(no_matching_rules)

proc part1(rules: seq[Rule], ticket: seq[int], nearby: seq[seq[int]]) =
  let bad_fields = nearby
    .mapIt(get_bad_fields(it, rules))
    .concat
  echo bad_fields.sum

################################################################################

# Part 2

proc find_solved_field(poss: Table[int, HashSet[string]]): (int, string) =
  # Find field with only one matching rule remaining.
  for (idx, fields) in poss.pairs:
    if fields.len == 1:
      return (idx, toSeq(fields.items)[0])

proc solve(poss: Table[int, HashSet[string]]): Table[int, string] =
  var poss = poss

  while poss.len > 0:
    let (idx, field) = find_solved_field(poss)
    result[idx] = field

    # Prune
    poss.del(idx)
    for idx in poss.keys:
      poss[idx].excl(field)

proc build_poss(rules: seq[Rule], tickets: seq[seq[int]]): Table[int, HashSet[string]] =
  for idx in 0..<tickets[0].len:
    let values = tickets.mapIt(it[idx])
    let matches_all_values = proc (rule: Rule): bool =
      values
        .mapIt(rule.match(it))
        .all

    # Find rules that match all values in the current position.
    let matching_rules = rules.filter(matches_all_values)
    result[idx] = toHashSet(matching_rules.mapIt(it.field))

proc part2(rules: seq[Rule], ticket: seq[int], nearby: seq[seq[int]]) =
  let is_good_ticket = proc (tix: seq[int]): bool =
    get_bad_fields(tix, rules).len == 0

  let
    good_tickets = nearby.filter(is_good_ticket)
    field_names = solve(build_poss(rules, good_tickets))

  let lookup_field_name = proc (entry: (int, int)): (string, int) =
    let (idx, value) = entry
    return (field_names[idx], value)

  let
    resolved_ticket = toSeq(ticket.pairs)
      .map(lookup_field_name)
      .toTable
    departure_fields = toSeq(resolved_ticket.pairs)
      .filterIt(it[0].contains("departure"))

  echo departure_fields
    .mapIt(it[1])
    .product

################################################################################

let
  input = toSeq(get_lines().split((l) => l == ""))
  rules = input[0].map(parse_rule)
  ticket = input[1][1].split(",").map(parseInt)
  nearby = input[2][1..^1].mapIt(it.split(",").map(parseInt))

part1(rules, ticket, nearby)
part2(rules, ticket, nearby)
