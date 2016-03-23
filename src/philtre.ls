
tagged = (tag, item) -->
  -1 < item.tags?.index-of tag

contains = (string, item) -->
  # smart case - insenstive unless caps in search
  option = \i
  if string.match /[A-Z]/
    option = ''

  reg = new RegExp(string, option)
  for key of item
    if item[key]?.to-string?!.match reg
      return true
  return false

has = (field, item) -->
  item?[field]

check-field = (field, value, item) -->
  -1 < item?[field]?to-string!.index-of value

before = (date, item) -->
  item.date < date

after = (date, item) -->
  item.date > date

get-quoted-string = (str) ->
  # look for same char as first char
  opener = str.0
  str = str.substr 1
  return get-until-closer str, opener

make-not = (f) ->
  return -> not f it

make-or = (a, b) ->
  return -> (a it) or (b it)

get-paren-string = (str) ->
  str = str.substr 1 # first char should be "("
  return get-until-closer str, ")"

get-until-closer = (str, closer) ->
  # first character is ' or "
  # find non-escaped match
  out = ''
  while str.length > 0
    char = str.0
    str = str.substr 1
    if char == closer # done!
      return [out, str]
    if char == "\\" # note this can throw
      out += str.0
      str = str.substr 1
      continue
    out += char

philtre-core = (query) ->
  conds = []
  while query.length > 0
    # subquery
    if query.0 == "("
      [word, query] = get-paren-string query
      conds.push philtre-core word
      continue

    if query.0 == "-" # treat as sugar for NOT
      conds.push "NOT"
      query = query.substr 1
      continue

    if query.0 == \# # this is a tag
      query = query.substr 1 # get rid of #
      if -1 < query.index-of ' '
        word = query.substr 0, query.index-of ' '
      else
        word = query
      query = query.substr 1 + word.length
      conds.push tagged word
      continue

    if query.match /^[A-z]*:/ # control word
      # key cannot be quoted, must be ASCII letters
      # value can be quoted and contain anything
      key = query.substr 0, query.index-of ":"
      query = query.substr 1 + query.index-of ":"
      if query.0 == \" or query.0 == \'
        [value, query] = get-quoted-string query
      else
        if -1 < query.index-of ' '
          value = query.substr 0, query.index-of ' '
        else
          value = query
        query = query.substr 1 + value.length

      conds.push switch key
      | \is, \has => has value
      | \before => before value
      | \after => after value
      default check-field key, value
      continue

    # default - just a hit
    if query.0 == \" or query.0 == \'
      [word, query] = get-quoted-string query
    else
      if -1 < query.index-of ' '
        word = query.substr 0, query.index-of ' '
      else
        word = query
      query = query.substr 1 + word.length

    # check for special vanilla words
    ucw = word.to-upper-case!
    if ucw == "AND" then continue # no-op
    if ucw == "OR" or ucw == "NOT"
      # fix after everything's loaded
      conds.push ucw
      continue

    #TODO figure out why this is happening and make it stop
    if word == ''
      continue

    # completely normal word, hit on it
    conds.push contains word
    continue

  # clean up special tokens
  conds-out = []
  ii = 0
  while ii < conds.length
    # first check for or
    if conds[ii + 1] == "OR"
      conds-out.push make-or conds[ii], conds[ii + 2]
      ii += 3
      continue

    if conds[ii] == "NOT"
      conds-out.push make-not conds[ii + 1]
      ii += 2
      continue

    # normal
    conds-out.push conds[ii]
    ii += 1

  return ->
    for f in conds-out
      if not f it then return false
    return true

export philtre = (query, items) -->
  # input is a plaintext string
  # output is a function that can be used to filter a list of objects

  # syntax notes
  # - ordinary word - object contains (any field)
  # - is: or has: - object has that field
  # - #xyz - checks .tags (assumes it's a list of strings)
  # - AND - does nothing
  # - OR - does an OR of terms on either side
  # - () - grouping
  # - xyz:>10 - comparisons
  # - NOT - "-#fish" is like "not tagged fish"

  query = query.trim!
  # array of boolean functions to be AND-ed
  conds = philtre-core query

  items.filter conds
