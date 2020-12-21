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

proc solve(recipes: seq[Recipe]) =
  var
    candidates = newTable[string, seq[string]]()
    safe_ingredients: HashSet[string]
    dangerous = newTable[string, string]()

  # Rule out impossible
  for (ingredients, allergens) in recipes:
    for allergen in allergens:
      if allergen notin candidates:
        candidates[allergen] = ingredients
      else:
        candidates[allergen] = toSeq((candidates[allergen].toHashSet * ingredients.toHashSet))
    for ingredient in ingredients:
      safe_ingredients.incl(ingredient)

  while true:
    var
      prune_allergens = newSeq[string]()
      prune_ingredients = newSeq[string]()

    # Solve for allergens with only one candidate ingredient left.
    for (allergen, ingredients) in candidates.pairs:
      if ingredients.len == 1:
        let culprit = ingredients[0]
        safe_ingredients.excl(culprit)
        dangerous[allergen] = culprit
        prune_allergens.add(allergen)
        prune_ingredients.add(culprit)

    # Reduce
    for allergen in prune_allergens:
      candidates.del(allergen)
    for ingredients in candidates.mvalues:
      ingredients.keepItIf(it notin prune_ingredients)

    if prune_allergens.len == 0:
      break

  # Part 1
  var freq = newCountTable[string]()
  for (recipe_ingredients, _) in recipes:
    for ingredients in recipe_ingredients.filterIt(it in safe_ingredients):
      freq.inc(ingredients)
  echo toSeq(freq.values).sum

  # Part 2
  echo toSeq(dangerous.pairs)
    .sorted((a, b) => (if a[0] < b[0]: -1 else: 1))
    .mapIt(it[1])
    .join(",")

let recipes = parse(get_lines())
solve(recipes)
