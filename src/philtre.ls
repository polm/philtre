parser = require \../lib/parser.js

export philtre = (query, items) -->
  query = query.trim!
  if query == '' # default is to accept everything
    func = -> return true
  else
    func = make-func parser.parse query
  output = items.filter func
  if func.sort
    output = sort-by func.sort.rev, func.sort.field, output
  if func.limit
    output = output.slice 0, func.limit
  return output

sort-by = (rev, field, items) -->
  swap = 1
  if rev then swap = -1
  items-copy = items.slice 0
  items-copy.sort (a, b) ->
    if a[field] < b[field] then return (swap * -1)
    if a[field] > b[field] then return (swap *  1)
    return 0

make-func = (q) ->
  conds = []
  sort = false
  limit = false
  for term in q
    cond = funkify-term term
    if cond.sort then sort = cond.sort
    else if cond.limit then limit = cond.limit
    else conds.push cond

  out-func = (item) ->
    for cond in conds
      if not cond item then return false
    return true
  out-func.sort = sort
  out-func.limit = limit
  return out-func

make-and = (q) ->
  # AND always has exactly two children
  a = funkify-term q[0]
  b = funkify-term q[1]
  return -> (a it) and (b it)

make-or = (q) ->
  # OR always has exactly two children
  a = funkify-term q[0]
  b = funkify-term q[1]
  return -> (a it) or (b it)

funkify-term = (term) ->
  if term.subquery then return make-func term.subquery
  if term.not
    return -> not (funkify-term term.not) it
  if term.literal
    return contains term.literal
  if term.and
    return make-and term.and
  if term.or
    return make-or term.or
  if term.key and term.val
    return check-field term.key, funkify-term term.val
  if term.tag
    return tagged term.tag
  if term.lessthan
    return -> it < term.lessthan
  if term.lessthaneq
    return -> it <= term.lessthaneq
  if term.greaterthan
    return -> it > term.greaterthan
  if term.greaterthaneq
    return -> it >= term.greaterthaneq
  if term.builtin
    return switch term.builtin
    | \sort  => sort: {field: term.val}
    | \sortr => sort: {rev: true, field: term.val}
    | \limit => limit: +term.val
    | \before => before term.val
    | \after => after term.val
    | \is or \has => -> it[term.val]?
  throw "Unknown term: " + term.to-string!

tagged = (tag, item) -->
  -1 < item.tags?.index-of tag

contains = (string, item) -->
  option = \i
  if string.match /[A-Z]/
    option = ''

  reg = new RegExp(string, option)
  if item?.match # if it's a string test it directly
    return item.match reg

  for key of item
    if item[key]?.to-string?!.match reg
      return true
  return false

check-field = (field, func, item) -->
  func item[field]

before = (date, item) -->
  item.date < date

after = (date, item) -->
  item.date > date
