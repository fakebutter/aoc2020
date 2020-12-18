import math
import sequtils
import strutils
import utils

proc gcd(a: int, b: int): int =
  if b == 0:
    return a
  return gcd(b, a mod b)
  
proc egcd(a: int, b: int): (int, int, int) =
  var
    a = a
    b = b
    x = [1, 0]
    y = [0, 1]
    prev_r = 0
    
  while b != 0:
    let
      rem = a mod b
      quot = int((a - rem) / b)
      new_x = x[0] - quot * x[1]
      new_y = y[0] - quot * y[1]
    
    a = b; b = rem
    if rem != 0:
      prev_r = rem
    x[0] = x[1]; x[1] = new_x
    y[0] = y[1]; y[1] = new_y

  return (prev_r, x[0], y[0])
  
proc multinv(a: int, m: int): int =
  let (_, _, inv) = egcd(m, a)
  return inv
  
proc crt(eqns: seq[(int, int)]): int =
  let
    big_m = eqns.mapIt(it[1]).product

  for (idx, tmp) in eqns.pairs:
    let
      (v, m) = tmp
      z = toSeq(eqns.pairs())
        .filterIt(it[0] != idx)
        .mapIt(it[1][1])
        .product
    result += v * z * multinv(z, m)

  return floorMod(result, big_m)

proc part1(arrival: int, buses_raw: string): int =
  var
    buses = buses_raw.split(",").filterIt(it != "x").map(parseInt)
    best_wait = -1
    best_bus = 0

  for bus in buses:
    let
      quot = int(arrival / bus)
      rem = arrival mod bus
      wait = if rem == 0: 0 else: quot * bus + bus - arrival

    if best_wait == -1 or wait < best_wait:
      (best_wait, best_bus) = (wait, bus)

  return best_wait * best_bus

proc part2(buses_raw: string): int =
  var
    buses = buses_raw.split(",").mapIt(if it == "x": "0" else: it).map(parseInt)
    eqns = newSeq[(int, int)]()

  for (idx, bus) in buses.pairs:
    if bus != 0:
      eqns.add((-idx, bus))

  return crt(eqns)

let
  lines = get_lines()
  arrival = parseInt(lines[0])
echo part1(arrival, lines[1])
echo part2(lines[1])
