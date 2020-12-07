import re
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

proc parse(lines: seq[string]): seq[OuterBag] =
  var conns = newSeq[OuterBag]()

  for line in lines:
    var args: array[2, string]
    if line.match(re"(.*) bags contain (.*)", args):
      var inner = newSeq[(int, string)]()
      for part in args[1].split(","):
        var parts: array[2, string]
        if part.match(re"\s*(\d+) (.+) bags?\.?$", parts):
          inner.add((count: parseInt(parts[0]), color: parts[1]))

      conns.add((color: args[0], inner: inner))

  return conns

proc newGraph(): Graph =
  var graph: Graph
  new(graph)
  graph.nodes = newTable[string, Node]()
  return graph

proc newNode(color: string): Node =
  var node: Node
  new(node)
  node.color = color
  node.children = newSeq[(int, Node)]()
  return node

proc getNode(graph: Graph, color: string): Node =
  if color notin graph.nodes:
    let node = newNode(color)
    graph.nodes[color] = node
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

proc dfs_part1(graph: Graph, node: Node) =
  for (_, child) in node.children:
    echo child.color
    dfs_part1(graph, child)

proc crawl_part1(graph: Graph) =
  let root = graph.getNode("shiny gold")
  dfs_part1(graph, root)

proc dfs_part2(graph: Graph, node: Node, mult: int) =
  for (count, child) in node.children:
    echo mult * count
    dfs_part2(graph, child, mult * count)

proc crawl_part2(graph: Graph) =
  let root = graph.getNode("shiny gold")
  dfs_part2(graph, root, 1)

let lines = get_lines()

# Pipe into: | sort | uniq | wc -l
let graph1 = build_graph_part1(parse(lines))
#crawl_part1(graph1)

# Pipe into: | awk '{sum+=$1}END{printf("%d\n",sum)}'
let graph2 = build_graph_part2(parse(lines))
crawl_part2(graph2)
