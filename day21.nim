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
      result.add((matches[0].split, matches[1].split(", ")))

proc prune(candidates: TableRef[string, HashSet[string]], toPrune: seq[(string, string)]) =
  let
    (allergens, tmp) = toPrune.unzip
    ingredients = tmp.toHashSet

  candidates.del(allergens)
  for ings in candidates.mvalues:
    ings.excl(ingredients)

proc solve(recipes: seq[Recipe]): Table[string, string] =
  var candidates = newTable[string, HashSet[string]]()

  # Find common set of ingredients for each allergen.
  for (ingredients, allergens) in recipes:
    for allergen in allergens:
      let ingSet = ingredients.toHashSet
      candidates[allergen] = candidates.getOrDefault(allergen, ingSet) * ingSet

  while true:
    var toPrune: seq[(string, string)]

    # Solve for allergens with only one candidate ingredient left.
    for (allergen, ingredients) in candidates.pairs:
      if ingredients.len == 1:
        let culprit = toSeq(ingredients.items)[0]
        result[allergen] = culprit
        toPrune.add((allergen, culprit))

    # Remove what we have solved.
    prune(candidates, toPrune)
    if toPrune.len == 0:
      break

proc part1(recipes: seq[Recipe], solution: Table[string, string]): int =
  let
    allIngredients = recipes.flatMap((r) => r[0])
    safeIngredients = allIngredients.toHashSet - toSeq(solution.values).toHashSet

  var freq: CountTable[string]
  for ingredient in allIngredients:
    if ingredient in safeIngredients:
      freq.inc(ingredient)
  return toSeq(freq.values).sum

proc part2(solution: Table[string, string]): string =
  return toSeq(solution.pairs)
    .sorted(cmpByIdx(0))
    .mapIt(it[1])
    .join(",")

let
  recipes = parse(getLines())
  solution = solve(recipes)
echo part1(recipes, solution)
echo part2(solution)
