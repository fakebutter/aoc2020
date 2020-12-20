import algorithm
import itertools
import re
import sequtils
import sets
import strformat
import strutils
import sugar
import tables
import utils

type
  Rule = ref object
    term: string
    nonterms: seq[seq[int]]

proc parse_rules(raw: seq[string]): Table[int, Rule] =
  for line in raw:
    var rule: Rule
    new(rule)

    if line =~ re"(\d+): (.+)":
      let (idx, rhs) = (matches[0], matches[1])
      if rhs =~ re("\"(.+)\""):
        rule.term = rhs[1..^2]
      else:
        rule.nonterms = newSeq[seq[int]]()
        for nonterm in rhs.split("|"):
          let nonterm_parsed = nonterm.strip().split(" ").mapIt(it.strip()).map(parseInt)
          rule.nonterms.add(nonterm_parsed)

      result[parseInt(idx)] = rule

proc gen_all_poss(rules: Table[int, Rule], idx: int): seq[string] =
  let rule = rules[idx]
  if rule.term != "":
    return @[rule.term]

  for nonterm in rule.nonterms:
    case nonterm.len:
      of 1:
        for poss in gen_all_poss(rules, nonterm[0]):
          result.add(poss)
      of 2:
        let
          poss1 = gen_all_poss(rules, nonterm[0])
          poss2 = gen_all_poss(rules, nonterm[1])
        for (x, y) in product(poss1, poss2):
          result.add(x & y)
      of 3:
        let
          poss1 = gen_all_poss(rules, nonterm[0])
          poss2 = gen_all_poss(rules, nonterm[1])
          poss3 = gen_all_poss(rules, nonterm[3])
        for (x, y, z) in product(poss1, poss2, poss3):
          result.add(x & y & z)
      else:
        assert nonterm.len > 3

# Unused LR parser.
proc parse_sentence(rules: TableRef[int, Rule], sentence: string): bool =
  var tokens = reversed(toSeq(sentence.items)).mapIt($it)
  var stack = newSeq[string]()

  while tokens.len > 0:
    stack.add(tokens.pop())

    for (idx, rule) in rules.pairs:
      if rule.term != "":
        if stack.len >= 1:
          if stack[^1] == rule.term:
            discard stack.pop()
            stack.add($idx)
            break

    while true:
      var derived = false

      for (idx, rule) in rules.pairs:
        for factor in rule.nonterms:
          if stack.len >= factor.len:
            if zip(stack[^factor.len..^1], factor).mapIt(parseInt(it[0]) == it[1]).all:
              for _ in 0..<factor.len:
                discard stack.pop()
              stack.add($idx)
              derived = true

      if not derived:
        break

    echo stack

  return stack == ["0"]

proc part1(rules: Table[int, Rule], sentences: seq[string]): int =
  let poss = gen_all_poss(rules, 0).toHashSet

  for sentence in sentences:
    if sentence in poss:
      result += 1

proc part2(rules: Table[int, Rule], sentences: seq[string]): int =
  let
    poss = gen_all_poss(rules, 0).toHashSet
    possHead = gen_all_poss(rules, 42)
    possTail = gen_all_poss(rules, 31)

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
    if sentence in poss:
      result += 1
    else:
      var
        sentence = sentence
        has_head = false
        has_tail = false

      # 42 42 ... 31 31
      while true:
        let (vh, hl) = validHead(sentence)
        let (vt, tl) = validTail(sentence)
        if vh and vt:
          sentence = sentence[hl..^tl+1]
          has_tail = true
        else:
          break

      # 42 42 ...
      while true:
        let (vh, hl) = validHead(sentence)
        if vh:
          sentence = sentence[hl..^1]
          has_head = true
        else:
          break

      if sentence == "" and has_head and has_tail:
        result += 1

let
  input = toSeq(get_lines().split((l) => l == ""))
  rules = parse_rules(input[0])
echo part1(rules, input[1])
echo part2(rules, input[1])
