import algorithm
import macros
import sequtils
import sets
import sugar
import tables

proc get_lines*(): seq[string] =
  result = newSeq[string]()
  var line: string
  while readLine(stdin, line):
    result.add(line)
  return result

iterator split*[T](items: seq[T], is_delim: (T) -> bool): seq[T] =
  var cur = newSeq[T]()
  for item in items:
    if is_delim(item):
      if cur.len > 0:
        yield cur
        cur = @[]
    else:
      cur.add(item)

  if cur.len > 0:
    yield cur

proc sum*[T](items: seq[T]): T =
  items.foldl(a + b)

proc product*[T](items: seq[T]): T =
  items.foldl(a * b)

proc identity*[T](v: T): T = v

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

proc deleteKeys*[A,B](table: TableRef[A,B], keys: seq[A]) =
  for k in keys:
    table.del(k)

proc deleteItems*[T](s: var seq[T], ds: HashSet[T]) =
  s.keepItIf(it notin ds)

macro cmp_by_idx*(idx: static[int]): untyped =
  result = quote do:
    (a, b) => (if a[`idx`] < b[`idx`]: -1 else: 1)
