proc get_lines*(): seq[string] =
  var lines = newSeq[string]()
  var line: string
  while readLine(stdin, line):
    lines.add(line)
  return lines
