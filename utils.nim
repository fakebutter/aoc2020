import sequtils
import sugar

proc get_lines*(): seq[string] =
  var lines = newSeq[string]()
  var line: string
  while readLine(stdin, line):
    lines.add(line)
  return lines

proc chunkify*[T](items: seq[T], is_delim: (T) -> bool): seq[seq[T]] =
  var chunk = newSeq[T]()
  for item in items:
    if is_delim(item):
      if chunk.len > 0:
        result.add(chunk)
        chunk = @[]
    else:
      chunk.add(item)

  if chunk.len > 0:
    result.add(chunk)

proc sum*[T](items: seq[T]): T =
  items.foldl(a + b)

proc product*[T](items: seq[T]): T =
  items.foldl(a * b)
