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
    range1, range2: Pair[int]

  Ticket = seq[int]

proc parseRule(rule: string): Rule =
  if rule =~ re"([^:]+): (\d+)-(\d+) or (\d+)-(\d+)":
    return (
      field: matches[0],
      range1: (parseInt(matches[1]), parseInt(matches[2])),
      range2: (parseInt(matches[3]), parseInt(matches[4]))
    )

proc parseTicket(ticket: string): Ticket =
  ticket.split(",").toInts

proc match(rule: Rule, value: int): bool =
  (rule.range1.first <= value and value <= rule.range1.second) or
    (rule.range2.first <= value and value <= rule.range2.second)

################################################################################
# Part 1

proc getBadFields(ticket: Ticket, rules: seq[Rule]): Ticket =
  let isBadField = (field: int) => rules.mapIt(it.match(field)).none
  ticket.filter(isBadField)

proc part1(rules: seq[Rule], ticket: Ticket, nearbyTickets: seq[Ticket]): int =
  nearbyTickets
    .flatMap((ticket) => getBadFields(ticket, rules))
    .sum

################################################################################
# Part 2

proc findSolvedField(possibleFields: Table[int, HashSet[string]]): (int, string) =
  # Find field with only one matching rule remaining.
  for (idx, fields) in possibleFields.pairs:
    if fields.len == 1:
      return (idx, fields.one)
  assert false

proc solve(possibleFields: Table[int, HashSet[string]]): Table[int, string] =
  var possibleFields = possibleFields

  while possibleFields.len > 0:
    let (idx, field) = findSolvedField(possibleFields)
    result[idx] = field

    # Prune
    possibleFields.del(idx)
    for idx in possibleFields.keys:
      possibleFields[idx].excl(field)

# Field index -> possible field names
proc buildPossibleFields(rules: seq[Rule], tickets: seq[Ticket]): Table[int, HashSet[string]] =
  for idx in 0..<tickets[0].len:
    let
      # Find rules that match all values in the current position.
      values = tickets.mapIt(it[idx])
      matchesValues = (rule: Rule) => values.allIt(rule.match(it))
      matchingRules = rules.filter(matchesValues)

    # Extract field names.
    result[idx] = matchingRules.mapIt(it.field).toHashSet

proc part2(rules: seq[Rule], ticket: Ticket, nearbyTickets: seq[Ticket]): int =
  let
    # Solve field names.
    isGoodTicket = (ticket: Ticket) => getBadFields(ticket, rules).len == 0
    goodTickets = nearbyTickets.filter(isGoodTicket)
    fieldNames = solve(buildPossibleFields(rules, goodTickets))

    # Translate my ticket.
    resolveFieldNames = (entry: (int, int)) => (fieldNames[entry[0]], entry[1])
    resolvedTicket = toSeq(ticket.pairs).map(resolveFieldNames)

  return resolvedTicket
    .filterIt(it[0].contains("departure"))
    .mapIt(it[1])
    .product

################################################################################

let
  input = getLines().split
  rules = input[0].map(parseRule)
  ticket = parseTicket(input[1][1])
  nearbyTickets = input[2][1..^1].map(parseTicket)

echo part1(rules, ticket, nearbyTickets)
echo part2(rules, ticket, nearbyTickets)
