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

proc append(cups: var LinkedList, value: int) =
  var newNode = newNode(value)

  cups.lookup[value] = newNode
  cups.max = max(cups.max, value)

  if cups.head == nil:
    cups.head = newNode
    cups.tail = newNode
  else:
    cups.tail.next = newNode
    cups.tail = newNode
  newNode.next = cups.head

proc insertAfter(cups: var LinkedList, node: Node, values: seq[int]) =
  var
    cur = node
    rest = cur.next

  for value in values:
    cur.next = cups.lookup[value]
    cur = cur.next

  cur.next = rest

proc extractAfter(cups: var LinkedList, node: Node, size: int): seq[int] =
  var cur = node.next

  for _ in 1..size:
    result.add(cur.value)
    cur = cur.next

  node.next = cur

proc calcDest(cur: int, taken: seq[int], max: int): int =
  result = if cur == 1: max else: cur - 1
  while result in taken:
    result = if result == 1: max else: result - 1

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

    cur = cur.next

  let node = cups[1]
  return node.next.value * node.next.next.value

let input = toSeq("326519478".items).mapIt(parseInt($it))

echo part1(input)

var cups = newLinkedList(1_000_001)
for c in input:
  cups.append(c)
for c in input.max+1..1_000_000:
  cups.append(c)
echo part2(cups)
