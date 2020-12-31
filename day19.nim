import itertools
import re
import sequtils
import sets
import strutils
import tables
import utils

type
  Rule = ref object
    term: string
    nonterms: seq[seq[int]]

proc parseRules(raw: seq[string]): Table[int, Rule] =
  for line in raw:
    var rule: Rule
    new(rule)

    if line =~ re"(\d+): (.+)":
      let (idx, rhs) = (matches[0], matches[1])
      if rhs =~ re("\"(.+)\""):
        rule.term = rhs[1..^2]
      else:
        rule.nonterms = newSeq[seq[int]]()
        for nonTerm in rhs.split("|"):
          let nontermParsed = nonTerm.strip.split.mapIt(it.strip).toInts
          rule.nonterms.add(nontermParsed)

      result[parseInt(idx)] = rule

proc genAllPoss(rules: Table[int, Rule], idx: int): seq[string] =
  let rule = rules[idx]
  if rule.term != "":
    return @[rule.term]

  for nonTerm in rule.nonterms:
    case nonTerm.len:
      of 1:
        for poss in genAllPoss(rules, nonTerm[0]):
          result.add(poss)
      of 2:
        let
          poss1 = genAllPoss(rules, nonTerm[0])
          poss2 = genAllPoss(rules, nonTerm[1])
        for (x, y) in product(poss1, poss2):
          result.add(x & y)
      of 3:
        let
          poss1 = genAllPoss(rules, nonTerm[0])
          poss2 = genAllPoss(rules, nonTerm[1])
          poss3 = genAllPoss(rules, nonTerm[3])
        for (x, y, z) in product(poss1, poss2, poss3):
          result.add(x & y & z)
      else:
        assert nonTerm.len > 3

proc part1(rules: Table[int, Rule], sentences: seq[string]): int =
  let poss = genAllPoss(rules, 0).toHashSet

  for sentence in sentences:
    if sentence in poss:
      result += 1

proc part2(rules: Table[int, Rule], sentences: seq[string]): int =
  let
    possHead = genAllPoss(rules, 42)
    possTail = genAllPoss(rules, 31)

  # Assumes no ambiguity, no backtracking.
  let validHead = proc (s: string): (bool, int) =
    for head in possHead:
      if s.startsWith(head):
        return (true, head.len)
    return (false, 0)

  let validTail = proc (s: string): (bool, int) =
    for tail in possTail:
      if s.endsWith(tail):
        return (true, tail.len)
    return (false, 0)

  for sentence in sentences:
    # Looking for: m x 42, n x 42, m x 31
    var
      sentence = sentence
      hasHead = false
      hasTail = false

    # 42 42 ... 31 31
    while true:
      let
        (vh, hl) = validHead(sentence)
        (vt, tl) = validTail(sentence)
      if vh and vt:
        sentence = sentence[hl..^tl+1]
        hasTail = true
      else:
        break

    # 42 42 ...
    while true:
      let (vh, hl) = validHead(sentence)
      if vh:
        sentence = sentence[hl..^1]
        hasHead = true
      else:
        break

    if sentence == "" and hasHead and hasTail:
      result += 1

let
  input = getLines().split
  rules = parseRules(input[0])
echo part1(rules, input[1])
echo part2(rules, input[1])
