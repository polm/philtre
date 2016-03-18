# this is just for the shell command
# reads json objects from stdin, one per line
# outputs those that match query (command line arguments)

philtre = require("./philtre").philtre

read-stdin-as-lines-then = (func) ->
  buf = ''
  process.stdin.set-encoding \utf-8
  process.stdin.on \data, -> buf += it
  process.stdin.on \end, -> func (buf.split "\n" |> no-empty)

no-empty = -> it.filter (-> not (it == null or it == '') )

philtre-from-stdin = ->
  # read stdin, assume one json object per line
  # print objects that match command line
  read-stdin-as-lines-then ->
    query = process.argv.2
    key = process.argv.3
    objects = it.map JSON.parse
    philtre(query, objects).map (out) ->
      if key then out = out[key]
      console.log JSON.stringify out

philtre-from-stdin!

