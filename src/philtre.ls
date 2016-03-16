
tagged = (tag, item) -->
  -1 < item.tags?.index-of tag

# TODO lowercase match
contains = (string, item) -->
  for key of item
    if -1 < item[key].index-of string
      return true
  return false

has = (field, item) -->
  item?[field]

before = (date, item) -->
  item.date < date

after = (date, item) -->
  item.date > date

philtre-core = (query) ->
  conds = []
  while query.length > 0
    if query.0 == \# # this is a tag
      word = query.split(' ').0.substr 1
      query = query.substr 2 + word.length
      conds.push tagged word
      continue

    /*
    if query.0 == '"' or query.0 == "'" # this is a quoted string
      word = ''
      opener = query.0
      query.shift!
      while query.length > 0
        char = query.shift!
        if char == opener then break # found closing quote
        if char == "\\" # escape
          # this will blow up if the last character is a backslash, that's fine
          word += query.shift!
          continue
        word += char
      # now word is the quoted string
      conds.push contains word
      query = query.trim!
      continue
    */

    if -1 < query.index-of ":" # control word
      token = query.split(' ').0
      [key, value] = token.split ':'
      switch key
      | \is, \has => conds.push has value
      | \before => conds.push before value
      | \after => conds.push after value
      default conds.push -> false
      query = query.substr (key.length + value.length + 1)
      continue

    # default - just a hit
    word = query.split(' ').0
    query = query.substr 1 + word.length
    conds.push contains word
  return conds

export philtre = (query) ->
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

  return (items) ->
    items.filter ->
      for f in conds
        if not f it then return false
      return true
