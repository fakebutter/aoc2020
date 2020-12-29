import math
import sequtils
import strutils
import utils

proc egcd(a: int, b: int): (int, int, int) =
  var
    a = a
    b = b
    x = [1, 0]
    y = [0, 1]
    prevR = 0
    
  while b != 0:
    let
      rem = a mod b
      quot = int((a - rem) / b)
      newX = x[0] - quot * x[1]
      newY = y[0] - quot * y[1]
    
    a = b; b = rem
    if rem != 0:
      prevR = rem
    x[0] = x[1]; x[1] = newX
    y[0] = y[1]; y[1] = newY

  return (prevR, x[0], y[0])
  
proc multInv(a: int, m: int): int =
  let (_, _, inv) = egcd(m, a)
  return inv
  
proc crt(eqns: seq[(int, int)]): int =
  let bigM = eqns.mapIt(it[1]).product

  for (idx, tmp) in eqns.pairs:
    let
      (v, m) = tmp
      z = toSeq(eqns.pairs())
        .filterIt(it[0] != idx)
        .mapIt(it[1][1])
        .product
    result += v * z * multInv(z, m)

  return floorMod(result, bigM)

proc part1(arrival: int, buses: seq[int]): int =
  var
    buses = buses.filterIt(it != 0)
    bestWait = -1
    bestBus = 0

  for bus in buses:
    let
      quot = int(arrival / bus)
      rem = arrival mod bus
      wait = if rem == 0: 0 else: quot * bus + bus - arrival

    if bestWait == -1 or wait < bestWait:
      (bestWait, bestBus) = (wait, bus)

  return bestWait * bestBus

proc part2(buses: seq[int]): int =
  var eqns = newSeq[(int, int)]()

  for (idx, bus) in buses.pairs:
    if bus != 0:
      eqns.add((-idx, bus))

  return crt(eqns)

let
  lines = getLines()
  arrival = parseInt(lines[0])
  buses = lines[1].split(",").mapIt(if it == "x": "0" else: it).map(parseInt)

echo part1(arrival, buses)
echo part2(buses)
