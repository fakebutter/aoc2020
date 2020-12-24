import sequtils
import strutils

type
  Range = ref object
    value: int
    prev, next: Range
  Rope = ref object
    head: Range
    tail: Range
    lookup: seq[Range]
    max: int

proc newRange(value: int): Range =
  new(result)
  result.value = value

proc newRope(size: int): Rope =
  new(result)
  result.lookup = newSeq[Range](size)

proc `[]`(rope: Rope, value: int): Range =
  rope.lookup[value]

proc append(rope: var Rope, value: int): Range =
  var
    newNode = newRange(value)

  rope.lookup[value] = newNode
  rope.max = max(rope.max, value)

  if rope.head == nil:
    rope.head = newNode
    rope.tail = newNode
    return newNode

  rope.tail.next = newNode
  newNode.prev = rope.tail
  rope.tail = newNode
  return newNode

proc insertAfter(rope: var Rope, node: Range, value: int): Range =
  var
    rest = node.next
    newNode = newRange(value)

  rope.lookup[value] = newNode
  rope.max = max(rope.max, value)

  node.next = newNode
  newNode.prev = node
  if rest != nil:
    newNode.next = rest
    rest.prev = newNode
  else:
    rope.tail = newNode

  return newNode

proc extract(rope: var Rope, after: int, size: int): seq[int] =
  let afterNode = rope.lookup[after]
  var node = afterNode

  for _ in 1..size:
    node = node.next
    if node == nil:
      node = rope.head
    result.add(node.value)

  var rest = node.next
  afterNode.next = rest
  if rest != nil:
    rest.prev = afterNode

proc part1(cards: seq[int]): int =
  var
    cards = cards
    curIdx = 0
  let
    cardsMax = cards.max

  for _ in 1..100:
    let cur = cards[curIdx]
    var take = cards.cycle(2)[curIdx+1..curIdx+3]
    cards.keepItIf(it notin take)
    
    var insAft = cur - 1
    if insAft == 0:
      insAft = cardsMax
    while insAft in take:
      insAft = insAft - 1
      if insAft == 0:
        insAft = cardsMax
    
    var insIdx = cards.find(insAft) + 1
    for i in 0..2:
      cards.insert(take[i], insIdx+i)
      
    curIdx = (cards.find(cur) + 1) mod cards.len
    
  var i = (cards.find(1) + 1) mod cards.len
  return parseInt(cards.cycle(2)[i..<i+cards.len-1].mapIt($it).join())

proc part2(cards: var Rope): int =
  let
    cardsMax = cards.max
  var cur = cards.head.value

  for round in 1..10_000_000:
    if round mod 1_000_000 == 0:
      stdout.write(".")
      flushFile(stdout)

    var take = cards.extract(cur, 3)
    
    var insAft = cur - 1
    if insAft == 0:
      insAft = cardsMax
    while insAft in take:
      insAft = insAft - 1
      if insAft == 0:
        insAft = cardsMax
    
    var node = cards[insAft]
    for i in 0..2:
      discard cards.insertAfter(node, take[i])
      node = node.next

    if cards[cur].next == nil:
      cur = cards.head.value
    else:
      cur = cards[cur].next.value

  echo()
    
  result = 1
  var node = cards[1]
  for i in 1..2:
    node = node.next
    if node == nil:
      node = cards.head
    result *= node.value

let cards = toSeq("326519478".items).mapIt(parseInt($it))

echo part1(cards)

var rope = newRope(1_000_001)
for c in cards:
  discard rope.append(c)
for c in cards.max+1..1_000_000:
  discard rope.append(c)
echo part2(rope)
