import math
import sequtils
import strutils

type
  Node = ref object
    value: int
    next: Node
  LinkedList = ref object
    head: Node
    tail: Node
    lookup: seq[Node]
    max: int

proc newNode(value: int): Node =
  new(result)
  result.value = value

proc newLinkedList(size: int): LinkedList =
  new(result)
  result.lookup = newSeq[Node](size)

proc `[]`(cups: LinkedList, value: int): Node =
  cups.lookup[value]

proc next(cups: LinkedList, node: Node): Node =
  if node.next == nil:
    return cups.head
  else:
    return node.next

proc append(cups: var LinkedList, value: int): Node =
  var newNode = newNode(value)

  cups.lookup[value] = newNode
  cups.max = max(cups.max, value)

  if cups.head == nil:
    cups.head = newNode
    cups.tail = newNode
  else:
    cups.tail.next = newNode
    cups.tail = newNode
  return newNode

proc insertAfter(cups: var LinkedList, node: Node, values: seq[int]) =
  var
    rest = node.next
    node = node

  for value in values:
    node.next = cups.lookup[value]
    node = node.next

  node.next = rest
  if node.next == nil:
    cups.tail = node

proc extractAfter(cups: var LinkedList, after: Node, size: int): seq[int] =
  var
    node = cups.next(after)
    wrapped = node == cups.head

  for _ in 1..size:
    result.add(node.value)
    node = cups.next(node)
    wrapped = node == cups.head

  if wrapped:
    cups.tail = after
    after.next = nil
  else:
    after.next = node

proc calcDest(cur: int, taken: seq[int], max: int): int =
  result = floorMod(cur - 1 - 1, max) + 1
  while result in taken:
    result = floorMod(result - 1 - 1, max) + 1

proc part1(cups: seq[int]): int =
  let cupsMax = cups.max
  var
    cups = cups
    curIdx = 0

  for _ in 1..100:
    let cur = cups[curIdx]
    var take = cups.cycle(2)[curIdx+1..curIdx+3]
    cups.keepItIf(it notin take)

    var insAft = calcDest(cur, take, cupsMax)
    var insIdx = cups.find(insAft) + 1
    for i in 0..2:
      cups.insert(take[i], insIdx+i)

    curIdx = (cups.find(cur) + 1) mod cups.len

  var i = (cups.find(1) + 1) mod cups.len
  return parseInt(cups.cycle(2)[i..<i+cups.len-1].mapIt($it).join())

proc part2(cups: var LinkedList): int =
  let cupsMax = cups.max
  var cur = cups.head

  for round in 1..10_000_000:
    var take = cups.extractAfter(cur, 3)
    var insAft = calcDest(cur.value, take, cupsMax)
    var node = cups[insAft]
    cups.insertAfter(node, take)

    cur = cups.next(cur)

  var node = cups[1]
  return cups.next(node).value * cups.next(cups.next(node)).value

let input = toSeq("326519478".items).mapIt(parseInt($it))

echo part1(input)

var cups = newLinkedList(1_000_001)
for c in input:
  discard cups.append(c)
for c in input.max+1..1_000_000:
  discard cups.append(c)
echo part2(cups)
