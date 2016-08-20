// Generated by LiveScript 1.4.0
(function(){
  var tap, philtre, data, result, fs, dkData, capTest;
  tap = require('tap');
  philtre = require("../lib/philtre").philtre;
  data = [
    {
      title: "My first entry",
      date: "2016-01-16T23:25:54+09:00",
      tags: ['red', 'blue', 'fish'],
      body: "words go here lots of words"
    }, {
      title: "My second entry",
      date: "2016-02-16T23:25:54+09:00",
      tags: ['red', 'blue', 'cat'],
      body: "hat hen ham hare hill cat fish"
    }, {
      title: "My third entry",
      date: "2016-03-16T23:25:54+09:00",
      tags: ['cat', 'fish'],
      special: "howdy doo",
      body: "blah blah blah piffle poffle"
    }
  ];
  result = philtre('#fish', data);
  tap.equal(result.length, 2);
  tap.equal(result[0].title, "My first entry");
  tap.equal(result[1].title, "My third entry");
  result = philtre(':before:2016-03-01', data);
  tap.equal(result.length, 2);
  result = philtre(':after:2016-03-01', data);
  tap.equal(result.length, 1);
  result = philtre('#fish :after:2016-03-01', data);
  tap.equal(result.length, 1);
  result = philtre('#fish #cat :after:2016-03-01', data);
  tap.equal(result.length, 1);
  result = philtre('#red :after:2016-03-01', data);
  tap.equal(result.length, 0);
  result = philtre(':is:special', data);
  tap.equal(result.length, 1);
  result = philtre(':is:special #cat', data);
  tap.equal(result.length, 1);
  result = philtre(':is:special #red', data);
  tap.equal(result.length, 0);
  result = philtre('"hen ham"', data);
  tap.equal(result.length, 1);
  result = philtre('("hen ham") #red', data);
  tap.equal(result.length, 1);
  result = philtre('(:is:special)', data);
  tap.equal(result.length, 1);
  result = philtre('(#cat)', data);
  tap.equal(result.length, 2);
  result = philtre('(:is:special #cat)', data);
  tap.equal(result.length, 1);
  result = philtre('(:is:special #cat) #fish', data);
  tap.equal(result.length, 1);
  result = philtre('NOT #fish', data);
  tap.equal(result.length, 1);
  result = philtre('#cat OR #fish', data);
  tap.equal(result.length, 3);
  result = philtre('hare OR (#cat #fish)', data);
  tap.equal(result.length, 2);
  result = philtre('(#cat #fish) OR hare', data);
  tap.equal(result.length, 2);
  result = philtre('-#fish', data);
  tap.equal(result.length, 1);
  process.exit(1);
  result = philtre('special:howdy', data);
  tap.equal(result.length, 1);
  result = philtre('special:hello', data);
  tap.equal(result.length, 0);
  fs = require('fs');
  dkData = fs.readFileSync("./data/dampfkraft.json", "utf-8").split("\n").filter(function(it){
    return (it != null ? it.length : void 8) > 0;
  }).map(JSON.parse);
  tap.equal(philtre('#tokyo', dkData).length, 1);
  tap.equal(philtre('food', dkData).length, 7);
  tap.equal(philtre('#restaurants', dkData).length, 7);
  tap.equal(philtre('#restaurants or food', dkData).length, 10);
  tap.equal(philtre('is:location #restaurants or food', dkData).length, 7);
  tap.equal(philtre('#restaurants or food is:location', dkData).length, 7);
  capTest = [
    {
      title: "one Two"
    }, {
      title: "alpha beta"
    }, {
      title: "ThreE four"
    }
  ];
  tap.equal(philtre('two', capTest).length, 1);
  tap.equal(philtre('Two', capTest).length, 1);
  tap.equal(philtre('three', capTest).length, 1);
  tap.equal(philtre('Three', capTest).length, 0);
}).call(this);
