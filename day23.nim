import sequtils
import strutils
import utils

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

proc append(cups: LinkedList, value: int) =
  var newNode = newNode(value)

  if cups.head == nil:
    cups.head = newNode
  else:
    cups.tail.next = newNode
  cups.tail = newNode
  newNode.next = cups.head

  cups.lookup[value] = newNode
  cups.max = max(cups.max, value)

proc insertAfter(cups: LinkedList, node: Node, values: seq[int]) =
  var
    cur = node
    rest = cur.next

  for value in values:
    # Reuse
    cur.next = cups.lookup[value]
    cur = cur.next

  cur.next = rest

proc extractAfter(cups: LinkedList, node: Node, size: int): seq[int] =
  var cur = node.next

  for _ in 1..size:
    result.add(cur.value)
    cur = cur.next

  node.next = cur

proc calcDest(cur: int, taken: seq[int], max: int): int =
  result = if cur == 1: max else: cur - 1
  while result in taken:
    result = if result == 1: max else: result - 1

proc concatInts(values: seq[int]): int =
  values.mapIt($it).join.parseInt

proc part1(cups: seq[int]): int =
  let cupsMax = cups.max
  var
    cups = cups
    curIdx = 0

  for _ in 1..100:
    let cur = cups[curIdx]
    # Hehe
    var extracted = cups.cycle(2)[curIdx+1..curIdx+3]
    cups.keepItIf(it notin extracted)

    var dest = calcDest(cur, extracted, cupsMax)
    var insIdx = cups.find(dest) + 1
    for i in 0..2:
      cups.insert(extracted[i], insIdx+i)

    curIdx = (cups.find(cur) + 1) mod cups.len

  var i = (cups.find(1) + 1) mod cups.len
  return cups.cycle(2)[i..<i+cups.len-1].concatInts

proc part2(cups: seq[int]): int =
  var cupsList = newLinkedList(1_000_001)
  for c in cups:
    cupsList.append(c)
  for c in cups.max+1..1_000_000:
    cupsList.append(c)

  let cupsMax = cupsList.max
  var cur = cupsList.head

  for round in 1..10_000_000:
    var
      extracted = cupsList.extractAfter(cur, 3)
      dest = calcDest(cur.value, extracted, cupsMax)
      insAft = cupsList[dest]
    cupsList.insertAfter(insAft, extracted)

    cur = cur.next

  let node = cupsList[1]
  return node.next.value * node.next.next.value

let input = toSeq(getLines()[0].items).toInts
echo part1(input)
echo part2(input)
