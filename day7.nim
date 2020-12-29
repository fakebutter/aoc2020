import re
import sequtils
import sets
import strutils
import tables
import utils

type
  InnerBag = tuple
    count: int
    color: string

  OuterBag = tuple
    color: string
    inner: seq[InnerBag]

  Node = ref object
    color: string
    children: seq[(int, Node)]

  Graph = ref object
    nodes: TableRef[string, Node]

proc parseInner(str: string): InnerBag =
  if str =~ re"\s*(\d+) (.+) bags?\.?$":
    return (count: parseInt(matches[0]), color: matches[1])

proc parse(lines: seq[string]): seq[OuterBag] =
  for line in lines:
    if line =~ re"(.*) bags contain (.*)":
      result.add((
        color: matches[0],
        inner: matches[1].split(",").map(parseInner)
      ))

proc newGraph(): Graph =
  new(result)
  result.nodes = newTable[string, Node]()

proc newNode(color: string): Node =
  new(result)
  result.color = color
  result.children = newSeq[(int, Node)]()

proc getNode(graph: Graph, color: string): Node =
  if color notin graph.nodes:
    graph.nodes[color] = newNode(color)
  return graph.nodes[color]

proc connect(graph: Graph, fromColor: string, toColor: string, count: int) =
  let
    nodeFrom = graph.getNode(fromColor)
    nodeTo = graph.getNode(toColor)
  nodeFrom.children.add((count, nodeTo))

################################################################################
# Part 1

proc buildGraphPart1(conns: seq[OuterBag]): Graph =
  result = newGraph()
  for (outerColor, inner) in conns:
    for (count, innerColor) in inner:
      result.connect(innerColor, outerColor, 0)

proc dfsPart1(graph: Graph, node: Node, visited: var HashSet[string]) =
  for (_, child) in node.children:
    visited.incl(child.color)
    dfsPart1(graph, child, visited)

proc crawlPart1(graph: Graph): int =
  let root = graph.getNode("shiny gold")
  var visited: HashSet[string]
  dfsPart1(graph, root, visited)
  return visited.len

################################################################################
# Part 2

proc buildGraphPart2(conns: seq[OuterBag]): Graph =
  result = newGraph()
  for (outerColor, inner) in conns:
    for (count, innerColor) in inner:
      result.connect(outerColor, innerColor, count)

proc dfsPart2(graph: Graph, node: Node, total: int): int =
  result = total
  for (count, child) in node.children:
    result += total * dfsPart2(graph, child, count)

proc crawlPart2(graph: Graph): int =
  let root = graph.getNode("shiny gold")
  # Exclude shiny gold itself.
  return dfsPart2(graph, root, 1) - 1

################################################################################

let lines = getLines()
var graph = buildGraphPart1(parse(lines))
echo crawlPart1(graph)
graph = buildGraphPart2(parse(lines))
echo crawlPart2(graph)
