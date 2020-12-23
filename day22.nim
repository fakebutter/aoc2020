import deques
import math
import sequtils
import strutils
import sugar
import utils

proc parse_decks(lines: seq[string]): seq[Deque[int]] =
  toSeq(lines.split((l) => l == ""))
    .mapIt(it[1..^1].map(parseInt).toDeque)

proc score_deck(deck: Deque[int]): int =
  for (i, c) in deck.pairs:
    result += (deck.len - i) * c

let hash_deck = score_deck

proc clone_decks(decks: seq[Deque[int]], size1: int, size2: int): seq[Deque[int]] =
  @[
    toSeq(decks[0].items)[0..<size1].toDeque,
    toSeq(decks[1].items)[0..<size2].toDeque,
  ]

proc part1(decks: var seq[Deque[int]]): int =
  while decks[0].len > 0 and decks[1].len > 0:
    let
      c1 = decks[0].popFirst
      c2 = decks[1].popFirst

    if c1 > c2:
      decks[0].addLast(c1); decks[0].addLast(c2)
    else:
      decks[1].addLast(c2); decks[1].addLast(c1)

  return if decks[0].len > 0: 1 else: 2

proc part2(decks: var seq[Deque[int]]): int =
  var history = newSeq[(int, int)]()

  while decks[0].len > 0 and decks[1].len > 0:
    let h = (hash_deck(decks[0]), hash_deck(decks[1]))
    if h in history:
      return 1
    else:
      history.add(h)

    let
      c1 = decks[0].popFirst
      c2 = decks[1].popFirst

    if decks[0].len < c1 or decks[1].len < c2:
      if c1 > c2:
        decks[0].addLast(c1); decks[0].addLast(c2)
      else:
        decks[1].addLast(c2); decks[1].addLast(c1)
    else:
      var sub_decks = clone_decks(decks, c1, c2)
      let sub_winner = part2(sub_decks)

      if sub_winner == 1:
        decks[0].addLast(c1); decks[0].addLast(c2)
      else:
        decks[1].addLast(c2); decks[1].addLast(c1)

  return if decks[0].len > 0: 1 else: 2

let lines = get_lines()
var decks = parse_decks(lines)

var winner = part1(decks)
echo score_deck(decks[winner - 1])

decks = parse_decks(lines)
winner = part2(decks)
echo score_deck(decks[winner - 1])
