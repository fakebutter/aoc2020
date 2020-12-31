import algorithm
import re
import sequtils
import strutils
import sugar
import utils

proc tokenize(line: string): seq[string] =
  for token in line.split:
    var token = token
    while token.len > 0:
      if token =~ re"^(\d+|[()+*])":
        result.add(matches[0])
        token = token[matches[0].len..^1]

################################################################################
# Part 1

proc evalTop(stack: var seq[int], op: string): int =
  let
    rhs = stack.pop()
    lhs = stack.pop()
  case op:
    of "+": return lhs + rhs
    of "*": return lhs * rhs
    else: assert(false)

proc evalRd(tokens: var seq[string], stack: var seq[int]): int =
  var curOp = ""

  # Some kind of weird shit recursive descent.
  while tokens.len > 0:
    let token = tokens.pop()
    var added = false

    if token == "(":
      stack.add(evalRd(tokens, stack))
      added = true
    elif token == ")":
      return stack.pop()
    elif token in ["+", "*"]:
      curOp = token
    else:
      stack.add(parseInt(token))
      added = true

    if added and curOp != "":
      stack.add(evalTop(stack, curOp))
      curOp = ""

  assert stack.len == 1
  return stack.pop()

proc evalEqn1(eqn: string): int =
  var
    stack: seq[int]
    tokens = reversed(tokenize(eqn))
  return evalRd(tokens, stack)

################################################################################
# Part 2

proc buildPrn(tokens: var seq[string]): seq[string] =
  var stack: seq[string]

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

proc evalPrn(tokens: seq[string]): int =
  var stack: seq[string]
  let popInt = () => parseInt(stack.pop())

  for token in tokens:
    case token
      of "*": stack.add($(popInt() * popInt()))
      of "+": stack.add($(popInt() + popInt()))
      else: stack.add(token)

  assert stack.len == 1
  return parseInt(stack.pop())

proc evalEqn2(eqn: string): int =
  var tokens = tokenize(eqn).reversed
  return evalPrn(buildPrn(tokens))

################################################################################

let lines = getLines()
echo lines.map(evalEqn1).sum
echo lines.map(evalEqn2).sum
