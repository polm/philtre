tap = require \tap
philtre = require("../lib/philtre").philtre

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
    special: "howdy doo"
    body: "blah blah blah piffle poffle"

result = philtre('#fish', data)
tap.equal result.length, 2
tap.equal result.0.title, "My first entry"
tap.equal result.1.title, "My third entry"
result = philtre(':before:2016-03-01', data)
tap.equal result.length, 2
result = philtre(':after:2016-03-01', data)
tap.equal result.length, 1
result = philtre('#fish :after:2016-03-01', data)
tap.equal result.length, 1
result = philtre('#fish #cat :after:2016-03-01', data)
tap.equal result.length, 1
result = philtre('#red :after:2016-03-01', data)
tap.equal result.length, 0
result = philtre(':is:special', data)
tap.equal result.length, 1
result = philtre(':is:special #cat', data)
tap.equal result.length, 1
result = philtre(':is:special #red', data)
tap.equal result.length, 0
result = philtre('"hen ham"', data)
tap.equal result.length, 1
result = philtre('("hen ham") #red', data)
tap.equal result.length, 1
result = philtre('(:is:special)', data)
tap.equal result.length, 1
result = philtre('(#cat)', data)
tap.equal result.length, 2
result = philtre('(:is:special #cat)', data)
tap.equal result.length, 1
result = philtre('(:is:special #cat) #fish', data)
tap.equal result.length, 1
result = philtre('NOT #fish', data)
tap.equal result.length, 1
result = philtre('#cat OR #fish', data)
tap.equal result.length, 3
result = philtre('hare OR (#cat #fish)', data)
tap.equal result.length, 2
result = philtre('(#cat #fish) OR hare', data)
tap.equal result.length, 2
result = philtre('-#fish', data)
tap.equal result.length, 1
result = philtre('special:howdy', data)
tap.equal result.length, 0
result = philtre('special:hello', data)
tap.equal result.length, 0

result = philtre ":sort:body", data
tap.equal result.length, 3
tap.equal result[0].body, "blah blah blah piffle poffle"
result = philtre ":sortr:body", data
tap.equal result.length, 3
tap.equal result[0].body, "words go here lots of words"
result = philtre ":sortr:date :limit:1", data
tap.equal result.length, 1
tap.equal result[0].date, "2016-03-16T23:25:54+09:00"

result = philtre 'date:">2016-02-01"', data
tap.equal result.length, 2

result = philtre 'date:"2016-02-01 .. 2016-03-01"', data
tap.equal result.length, 1
tap.equal result.0.title, "My second entry"

result = philtre '', data
tap.equal result.length, 3

fs = require \fs
dk-data = fs.read-file-sync("./data/dampfkraft.json", "utf-8")
  .split("\n")
  .filter -> it?.length > 0
  .map JSON.parse
tap.equal philtre('#tokyo', dk-data).length, 1
tap.equal philtre('food', dk-data).length, 7
tap.equal philtre('#restaurants', dk-data).length, 7
tap.equal philtre('#restaurants OR food', dk-data).length, 10
tap.equal philtre(':is:location #restaurants OR food', dk-data).length, 7
tap.equal philtre('#restaurants OR food :is:location', dk-data).length, 7

cap-test =
  * title: "one Two"
  * title: "alpha beta"
  * title: "ThreE four"

tap.equal philtre('two', cap-test).length, 1
tap.equal philtre('Two', cap-test).length, 1
tap.equal philtre('three', cap-test).length, 1
tap.equal philtre('Three', cap-test).length, 0


