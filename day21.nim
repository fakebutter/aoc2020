import algorithm
import re
import sequtils
import sets
import strutils
import sugar
import tables
import utils

type
    Recipe = (seq[string], seq[string])

proc parse(lines: seq[string]): seq[Recipe] =
  for line in lines:
    if line =~ re"^(.*) \(contains (.*)\)$":
      result.add((matches[0].split(" "), matches[1].split(", ")))

proc prune(candidates: TableRef[string, HashSet[string]], to_prune: seq[(string, string)]) =
  let
    algs = to_prune.mapIt(it[0])
    ings = to_prune.mapIt(it[1]).toHashSet

  candidates.deleteKeys(algs)
  for ingredients in candidates.mvalues:
    ingredients.excl(ings)

proc solve(recipes: seq[Recipe]): Table[string, string] =
  var candidates = newTable[string, HashSet[string]]()

  # Find common set of ingredients for each allergen.
  for (ingredients, allergens) in recipes:
    for allergen in allergens:
      let ing_set = ingredients.toHashSet
      candidates[allergen] = candidates.getOrDefault(allergen, ing_set) * ing_set

  while true:
    var to_prune = newSeq[(string, string)]()

    # Solve for allergens with only one candidate ingredient left.
    for (allergen, ingredients) in candidates.pairs:
      if ingredients.len == 1:
        let culprit = toSeq(ingredients.items)[0]
        result[allergen] = culprit
        to_prune.add((allergen, culprit))

    # Remove what we have solved.
    prune(candidates, to_prune)
    if to_prune.len == 0:
      break

proc part1(recipes: seq[Recipe], solution: Table[string, string]): int =
  let
    all_ingredients = recipes.mapIt(it[0]).concat
    safe_ingredients = all_ingredients.toHashSet - toSeq(solution.values).toHashSet

  var freq = newCountTable[string]()
  for ingredient in all_ingredients:
    if ingredient in safe_ingredients:
      freq.inc(ingredient)
  return toSeq(freq.values).sum

proc part2(solution: Table[string, string]): string =
  return toSeq(solution.pairs)
    .sorted(cmp_by_idx(0))
    .mapIt(it[1])
    .join(",")

let
  recipes = parse(get_lines())
  solution = solve(recipes)
echo part1(recipes, solution)
echo part2(solution)
