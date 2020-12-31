import algorithm
import macros
import sequtils
import sets
import strutils
import sugar
import tables

################################################################################
# Types

type
  Pair*[T] = tuple
    first, second: T
  V2* = tuple
    x, y: int
  V3* = tuple
    x, y, z: int
  V4* = tuple
    x, y, z, w: int

proc `+`*(lhs: V2, rhs: V2): V2 =
  (lhs.x + rhs.x, lhs.y + rhs.y)

proc `+=`*(lhs: var V2, rhs: V2) =
  lhs.x += rhs.x
  lhs.y += rhs.y

proc `*`*(lhs: V2, rhs: int): V2 =
  (lhs.x * rhs, lhs.y * rhs)

################################################################################
# IO

proc getLines*: seq[string] =
  var line: string
  while readLine(stdin, line):
    result.add(line)

proc to2dArr*(lines: seq[string]): seq[seq[char]] =
  lines.mapIt(toSeq it.items)

################################################################################
# Collections

proc gcd*(a: int, b: int): int =
  if b == 0:
    return a
  return gcd(b, a mod b)

proc one*[T](hs: HashSet[T]): T =
  for item in hs.items:
    return item

proc first*[T](s: openArray[T]): T =
  s[0]

proc toInts*(strs: openArray[string]): seq[int] =
  strs.map(parseInt)

proc toInts*(strs: openArray[char]): seq[int] =
  strs.mapIt(ord(it) - ord('0'))

proc count*[T](items: openArray[T], pred: (v: T) -> bool): int =
  items.countIt(pred(it))

iterator split*[T](items: seq[T], isDelim: (T) -> bool): seq[T] =
  var cur = newSeq[T]()
  for item in items:
    if isDelim(item):
      if cur.len > 0:
        yield cur
        cur = @[]
    else:
      cur.add(item)

  if cur.len > 0:
    yield cur

proc split*(lines: seq[string]): seq[seq[string]] =
  toSeq lines.split((l) => l == "")

proc sum*[T](items: seq[T]): T =
  items.foldl(a + b)

proc product*[T](items: seq[T]): T =
  items.foldl(a * b)

proc none*[T](items: seq[T]): bool =
  for i in items:
    if i:
      return false
  return true

proc any*[T](items: seq[T]): bool =
  for i in items:
    if i:
      return true
  return false

proc all*[T](items: seq[T]): bool =
  for i in items:
    if not i:
      return false
  return true

proc rev*(s: string): string =
  result = s
  result.reverse()

proc del*[A,B](table: TableRef[A,B], keys: openArray[A]) =
  for k in keys:
    table.del(k)

proc del*[A,B](table: var Table[A,B], keys: openArray[A]) =
  for k in keys:
    table.del(k)

template delItems*[T](s: var seq[T], ds: untyped) =
  s.keepItIf(it notin ds)

proc flatMap*[T, S](items: seq[T], fun: (T) -> seq[S]): seq[S] =
  items.map(fun).concat

################################################################################
# Miscellaneous

proc identity*[T](v: T): T = v

macro cmpByIdx*(idx: static[int]): untyped =
  result = quote do:
    (a, b) => (if a[`idx`] < b[`idx`]: -1 else: 1)

# https://github.com/Araq/metapar/blob/master/livedemo/curry.nim
macro curry*(f: typed; args: varargs[untyped]): untyped =
  let ty = getType(f)
  assert($ty[0] == "proc", "first param is not a function")
  let n_remaining = ty.len - 2 - args.len
  assert n_remaining > 0, "cannot curry all the parameters"
  #echo treerepr ty

  var callExpr = newCall(f)
  args.copyChildrenTo callExpr

  var params: seq[NimNode] = @[]
  # return type
  params.add ty[1]

  for i in 0..<n_remaining:
    let param = ident("arg" & $i)
    params.add newIdentDefs(param, ty[i+2+args.len])
    callExpr.add param
  result = newProc(procType = nnkLambda, params = params, body = callExpr)
