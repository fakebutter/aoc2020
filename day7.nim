import re
import sets
import strutils
import tables
import utils

type
  Node = ref object
    color: string
    parents: seq[Node]
    children: seq[(int, Node)]

  Graph = ref object
    nodes: TableRef[string, Node]

proc parse(lines: seq[string]): seq[(string, int, string)] =
  for line in lines:
    if line =~ re"(.*) bags contain (.*)":
      let outerColor = matches[0]
      for sub in matches[1].split(","):
        if sub =~ re"\s*(\d+) (.+) bags?\.?$":
          result.add((outerColor, parseInt(matches[0]), matches[1]))

proc newGraph(): Graph =
  new(result)
  result.nodes = newTable[string, Node]()

proc newNode(color: string): Node =
  new(result)
  result.color = color
  result.children = newSeq[(int, Node)]()

proc get(graph: Graph, color: string): Node =
  if color notin graph.nodes:
    graph.nodes[color] = newNode(color)
  return graph.nodes[color]

proc connect(graph: Graph, fromColor: string, toColor: string, count: int) =
  let
    nodeFrom = graph.get(fromColor)
    nodeTo = graph.get(toColor)
  nodeFrom.children.add((count, nodeTo))
  assert nodeFrom notin nodeTo.parents
  nodeTo.parents.add(nodeFrom)

proc buildGraph(conns: seq[(string, int, string)]): Graph =
  result = newGraph()
  for (outerColor, count, innerColor) in conns:
      result.connect(outerColor, innerColor, count)

################################################################################
# Part 1

proc dfsPart1(graph: Graph, node: Node, visited: var HashSet[string]) =
  for parent in node.parents:
    visited.incl(parent.color)
    dfsPart1(graph, parent, visited)

proc part1(graph: Graph): int =
  let root = graph.get("shiny gold")
  var visited: HashSet[string]
  dfsPart1(graph, root, visited)
  return visited.len

################################################################################
# Part 2

proc dfsPart2(graph: Graph, node: Node, total: int): int =
  result = total
  for (count, child) in node.children:
    result += total * dfsPart2(graph, child, count)

proc part2(graph: Graph): int =
  let root = graph.get("shiny gold")
  # Exclude shiny gold itself.
  return dfsPart2(graph, root, 1) - 1

################################################################################

let graph = buildGraph(getLines().parse)
echo part1(graph)
echo part2(graph)
