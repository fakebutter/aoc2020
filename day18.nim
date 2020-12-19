import algorithm
import re
import sequtils
import strutils
import sugar
import utils

proc tokenize(line: string): seq[string] =
  for token in line.split(" "):
    var token = token
    while token.len > 0:
      if token =~ re"^(\d+|[()+*])":
        result.add(matches[0])
        token = token[matches[0].len..^1]

proc eval_rd(tokens: var seq[string], stack: var seq[int]): int =
  let eval_top = proc (stack: var seq[int], op: string) =
    let
      rhs = stack.pop()
      lhs = stack.pop()
    var res: int
    case op:
      of "+": res = lhs + rhs
      of "*": res = lhs * rhs
      else: assert(false)
    stack.add(res)

  var cur_op = ""

  # Some kind of weird shit recursive descent.
  while tokens.len > 0:
    let token = tokens.pop()
    var added = false

    if token == "(":
      stack.add(eval_rd(tokens, stack))
      added = true
    elif token == ")":
      return stack.pop()
    elif token in ["+", "*"]:
      cur_op = token
    else:
      stack.add(parseInt(token))
      added = true

    if added and cur_op != "":
      eval_top(stack, cur_op)
      cur_op = ""

  assert stack.len == 1
  return stack.pop()

proc build_prn(tokens: var seq[string]): seq[string] =
  var stack = newSeq[string]()

  # Shunting yard
  while tokens.len > 0:
    let token = tokens.pop()
    case token
      of "*":
        while stack.len > 0 and stack[^1] == "+":
          result.add(stack.pop())
        stack.add(token)
      of "+":
        stack.add(token)
      of "(":
        stack.add(token)
      of ")":
        while stack[^1] != "(":
          result.add(stack.pop())
        discard stack.pop()
      else:
        result.add(token)

  while stack.len > 0:
    result.add(stack.pop())

proc eval_prn(tokens: seq[string]): int =
  var stack = newSeq[string]()
  let popInt = () => parseInt(stack.pop())

  for token in tokens:
    case token
      of "*": stack.add($(popInt() * popInt()))
      of "+": stack.add($(popInt() + popInt()))
      else: stack.add(token)

  assert stack.len == 1
  return parseInt(stack.pop())

proc eval_eqn1(eqn: string): int =
  var
    stack = newSeq[int]()
    tokens = reversed(tokenize(eqn))
  return eval_rd(tokens, stack)

proc eval_eqn2(eqn: string): int =
  var tokens = reversed(tokenize(eqn))
  return eval_prn(build_prn(tokens))

let lines = get_lines()
echo lines.map(eval_eqn1).sum
echo lines.map(eval_eqn2).sum
