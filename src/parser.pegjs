query
  = ws qq:(meta / token)+ ws { return qq; }

meta
  = left:token ws "AND" rws right:token { return {and: [left, right]}; } / 
    left:token ws "OR" rws right:token { return {or: [left, right]}; }  / 
    "NOT" rws tt:token { return {not: tt}; }

token
  = subquery / tag / keyword / builtin / word

word
  = negword / ss:string { return {literal: ss}; }

negword
  = "-" not:token { return {not: not}; }

ws "whitespace"
  = [ \n\t]*

rws "required-whitespace"
  = " " ws

subquery
  = "(" qq:query ")" ws { return {subquery: qq}; }

string
  = quoted / unquoted

quoted
  = '"' chars:char* '"' ws { return chars.join(""); }

/* 
See JSON example for how this works:
https://github.com/pegjs/pegjs/blob/master/examples/json.pegjs
*/

char
  = [^\0-\x1F\x22\x5C] / "\\" seq:( '"' / "\\" ) { return seq; }

unquoted
  = chars:[^\0-\x1F\x22\x5C:)(\" ]+ ws { return chars.join(""); }

tag
  = "#" val:string { return {tag: val}; }

builtin
  = ":" head:[A-z] tail:[A-z0-9]* ":" val:string { return {builtin: (head + tail.join("")), val: val}; }

keyword
  = head:[A-z] tail:[A-z0-9]* ":" val:value { return {key: (head + tail.join("")), val: val}; }

value
  = '"' inner:innerval '"' { return inner; } / ss:string { return {literal: ss} }
  
innerval 
  = 
    rr:range { return rr; } /
    ">"  val:string { return {greaterthan: val}; } /
    ">=" val:string { return {greaterthaneq: val}; } /
    "<"  val:string { return {lessthan: val}; } /
    "<=" val:string { return {lessthaneq: val}; } 

/* this doesn't work. */
range
  = low:string ws ".." ws high:string { return {and: [{greaterthaneq: low}, {lessthaneq: high}]}; }

