import algorithm
import math
import re
import sequtils
import sets
import strformat
import strutils
import sugar
import tables
import utils

proc tokenize(eqn: string): seq[string] =
  for token in eqn.split(" "):
    var i = 0
    while token[i] == '(':
      result.add("(")
      i += 1
    let stop = token[i..^1].find(")")
    if stop != -1:
      result.add(token[i..<stop])
      i = stop
      while i < token.len:
        result.add(")")
        i += 1
    else:
      result.add(token[i..^1])

proc eval_rd(tokens: seq[string], stack: var seq[string], idx: int): int =
  let eval_top = proc (stack: var seq[string], op: string) =
    let
      rhs = parseInt(stack.pop())
      lhs = parseInt(stack.pop())
    case op:
      of "+":
        stack.add($(lhs + rhs))
      of "-":
        stack.add($(lhs - rhs))
      of "/":
        stack.add($(lhs / rhs))
      of "*":
        stack.add($(lhs * rhs))
      else:
        assert(false)

  var
    idx = idx
    cur_op = ""

  # Some kind of weird shit recursive descent.
  while idx < tokens.len:
    let token = tokens[idx]
    if token == "(":
      idx = eval_rd(tokens, stack, idx + 1)
      if cur_op != "":
        eval_top(stack, cur_op)
        cur_op = ""
      continue
    elif token == ")":
      return idx + 1
    elif token in ["+", "-", "/", "*"]:
      cur_op = token
    else:
      stack.add(token)
      if cur_op != "":
        eval_top(stack, cur_op)
        cur_op = ""

    idx += 1

  return parseInt(stack.pop())

proc build_prn(tokens: seq[string]): seq[string] =
  var
    idx = 0
    stack = newSeq[string]()

  while idx < tokens.len:
    let token = tokens[idx]

    if token == "*":
      while stack.len > 0 and stack[^1] == "+":
        result.add(stack.pop())
      stack.add(token)
    elif token == "+":
      stack.add(token)
    elif token == "(":
      stack.add(token)
    elif token == ")":
      while stack[^1] != "(":
        result.add(stack.pop())
      discard stack.pop()
    else:
      result.add(token)

    idx += 1

  while stack.len > 0:
    result.add(stack.pop())

proc eval_prn(tokens: seq[string]): int =
  var stack = newSeq[string]()
  for token in tokens:
    if token == "*":
      stack.add($(
        parseInt(stack.pop()) * parseInt(stack.pop())
      ))
    elif token == "+":
      stack.add($(
        parseInt(stack.pop()) + parseInt(stack.pop())
      ))
    else:
      stack.add(token)

  return parseInt(stack.pop())

proc eval_eqn1(eqn: string): int =
  var stack = newSeq[string]()
  let tokens = tokenize(eqn)
  return eval_rd(tokens, stack, 0)

proc eval_eqn2(eqn: string): int =
  let tokens = tokenize(eqn)
  return eval_prn(build_prn(tokens))

proc part1(lines: seq[string]): int =
  for line in lines:
    result += eval_eqn1(line)

proc part2(lines: seq[string]): int =
  for line in lines:
    result += eval_eqn2(line)

let lines = get_lines()
echo part1(lines)
echo part2(lines)
