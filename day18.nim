import re
import sequtils
import strutils
import utils

proc tokenize(line: string): seq[string] =
  for token in line.split(" "):
    var token = token
    while token.len > 0:
      if token =~ re"^(\d+|[()+*])":
        result.add(matches[0])
        token = token[matches[0].len..^1]

proc eval_rd(tokens: seq[string], stack: var seq[string], idx: int): int =
  let eval_top = proc (stack: var seq[string], op: string) =
    let
      rhs = parseInt(stack.pop())
      lhs = parseInt(stack.pop())
    var res: int
    case op:
      of "+": res = lhs + rhs
      of "*": res = lhs * rhs
      else: assert(false)
    stack.add($res)

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
    elif token in ["+", "*"]:
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

  # Shunting yard
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
      let res = parseInt(stack.pop()) * parseInt(stack.pop())
      stack.add($res)
    elif token == "+":
      let res = parseInt(stack.pop()) + parseInt(stack.pop())
      stack.add($res)
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

let lines = get_lines()
echo lines.map(eval_eqn1).sum
echo lines.map(eval_eqn2).sum
