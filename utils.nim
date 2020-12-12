import sequtils
import sugar

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
