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

proc parse_inner(str: string): InnerBag =
  var parts: array[2, string]
  if str.match(re"\s*(\d+) (.+) bags?\.?$", parts):
    return (count: parseInt(parts[0]), color: parts[1])

proc parse(lines: seq[string]): seq[OuterBag] =
  for line in lines:
    var parts: array[2, string]
    if line.match(re"(.*) bags contain (.*)", parts):
      result.add((color: parts[0], inner: parts[1].split(",").map(parse_inner)))

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

proc connect(graph: Graph, from_color: string, to_color: string, count: int) =
  let node_from = graph.getNode(from_color)
  let node_to = graph.getNode(to_color)
  node_from.children.add((count, node_to))

proc build_graph_part1(conns: seq[OuterBag]): Graph =
  var graph = newGraph()

  for (outer_color, inner) in conns:
    for (count, inner_color) in inner:
      graph.connect(inner_color, outer_color, 0)

  return graph

proc build_graph_part2(conns: seq[OuterBag]): Graph =
  var graph = newGraph()

  for (outer_color, inner) in conns:
    for (count, inner_color) in inner:
      graph.connect(outer_color, inner_color, count)

  return graph

proc dfs_part1(graph: Graph, node: Node, visited: var HashSet[string]) =
  for (_, child) in node.children:
    visited.incl(child.color)
    dfs_part1(graph, child, visited)

proc crawl_part1(graph: Graph) =
  let root = graph.getNode("shiny gold")
  var visited: HashSet[string]
  dfs_part1(graph, root, visited)
  echo visited.len

proc dfs_part2(graph: Graph, node: Node, total: int): int =
  var sum = total
  for (count, child) in node.children:
    sum += total * dfs_part2(graph, child, count)
  return sum

proc crawl_part2(graph: Graph) =
  let root = graph.getNode("shiny gold")
  # Exclude shiny gold itself.
  echo dfs_part2(graph, root, 1) - 1

let lines = get_lines()

let graph1 = build_graph_part1(parse(lines))
crawl_part1(graph1)

let graph2 = build_graph_part2(parse(lines))
crawl_part2(graph2)
