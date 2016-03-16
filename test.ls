philtre = require("./src/philtre").philtre

assert = (cond, error) ->
  if not cond
    console.error "failed check: " + error
  else
    console.log "ok: " + error

data =
  * title: "My first entry"
    date: "2016-01-16T23:25:54+09:00"
    tags: <[ red blue fish ]>
    body: "words go here lots of words"
  * title: "My second entry"
    date: "2016-02-16T23:25:54+09:00"
    tags: <[ red blue cat ]>
    body: "hat hen ham hare hill cat fish"
  * title: "My third entry"
    date: "2016-03-16T23:25:54+09:00"
    tags: <[ cat fish ]>
    special: "yee-haw"
    body: "blah blah blah piffle poffle"


result = philtre('#fish')(data)
assert (result.length == 2), "two results matched"
assert (result.0.title == "My first entry"), "Correct title"
assert (result.1.title == "My third entry"), "Correct title"
result = philtre('before:2016-03-01')(data)
assert (result.length == 2), "two results matched"
result = philtre('after:2016-03-01')(data)
assert (result.length == 1), "one result matched"
result = philtre('#fish after:2016-03-01')(data)
assert (result.length == 1), "one result matched"
result = philtre('#fish #cat after:2016-03-01')(data)
assert (result.length == 1), "one result matched"
result = philtre('#red after:2016-03-01')(data)
assert (result.length == 0), "no result matched"
result = philtre('is:special')(data)
assert (result.length == 1), "one result matched"
result = philtre('is:special #cat')(data)
assert (result.length == 1), "one result matched"
result = philtre('is:special #red')(data)
assert (result.length == 0), "no result matched"



