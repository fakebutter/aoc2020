import deques
import math
import sequtils
import utils

proc parseDecks(lines: seq[string]): seq[Deque[int]] =
  lines.split.mapIt(it[1..^1].toInts.toDeque)

proc scoreDeck(deck: Deque[int]): int =
  for (i, c) in deck.pairs:
    result += (deck.len - i) * c

# Unproven, but seems to work.
let hashDeck = scoreDeck

proc cloneDecks(decks: seq[Deque[int]], size1: int, size2: int): seq[Deque[int]] =
  @[
    toSeq(decks[0].items)[0..<size1].toDeque,
    toSeq(decks[1].items)[0..<size2].toDeque,
  ]

proc part1(decks: seq[Deque[int]]): int =
  var decks = decks

  while decks[0].len > 0 and decks[1].len > 0:
    let
      c1 = decks[0].popFirst
      c2 = decks[1].popFirst

    if c1 > c2:
      decks[0].addLast(c1); decks[0].addLast(c2)
    else:
      decks[1].addLast(c2); decks[1].addLast(c1)

  let winner = if decks[0].len > 0: 0 else: 1
  return scoreDeck(decks[winner])

proc play2(decks: var seq[Deque[int]]): int =
  var history = newSeq[(int, int)]()

  while decks[0].len > 0 and decks[1].len > 0:
    let h = (hashDeck(decks[0]), hashDeck(decks[1]))
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
      # Recurse into sub-game.
      var subDecks = cloneDecks(decks, c1, c2)
      let subWinner = play2(subDecks)

      if subWinner == 1:
        decks[0].addLast(c1); decks[0].addLast(c2)
      else:
        decks[1].addLast(c2); decks[1].addLast(c1)

  return if decks[0].len > 0: 1 else: 2

proc part2(decks: seq[Deque[int]]): int =
  var decks = decks
  let winner = play2(decks)
  return scoreDeck(decks[winner - 1])

let decks = parseDecks(getLines())
echo part1(decks)
echo part2(decks)
