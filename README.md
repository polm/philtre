# Philtre

A library for searching objects, with syntax inspired by Gmail and Github searches. 

![philtre demo](http://i.imgur.com/tQN1AaD.gif)

At the core of Philtre is a function (`philtre`) that takes two arguments: a query (as a string) and a list of Javascript objects. It then returns the objects that match the query. 

You can try this out using the included command line script and sample data file. The command line script reads one JSON object per line from stdin (like [jq](https://stedolan.github.io/jq/)), filters them using the supplied query, and prints the specified field:

    philtre [query] [field-to-print] < [input.json]

To try it out yourself:

    mkdir fiddle && cd fiddle && git clone https://github.com/polm/philtre.git
    ./bin/philtre "#restaurants" title < data/dampfkraft.json 
    ./bin/philtre "is:location #restaurants" title < data/dampfkraft.json 
    ./bin/philtre "not is:location #restaurants" title < data/dampfkraft.json 
    ./bin/philtre "is:location not #restaurants" title < data/dampfkraft.json 

### Supported Keywords

Note that except for values before a colon in keywords using them (which must match the regex `[A-z]*`), anything may be quoted to preserve whitespace or otherwise special characters.

| keyword | effect |
| --- | --- |
| (default) | non-special words check for a string match on every field of the object. |
| `has:[something]` | true if the object has a field named `something` |
| `is:[something]` | same as `is:` |
| `[key]:[value]` | true if [value] is in the [key] property |
| `and` | does nothing (it's the default) |
| `or` | logical OR of the conditions on either side |
| `not` | negates the next keyword |
| `-[something]` | negates the next keyword; unlike `not` doesn't need a space |
| `(` and `)` | allows grouping of terms |
| `#[xxx]` | true if the `.tags` property contains `xxx` |
| `before:[xxx]` | true if the `.date` property is less than `xxx` |
| `after:[xxx]` | true if the `.date` property is greater than `xxx` |

You may have some questions:

**Why are `is` and `has` the same?**

In looking at sample data it seemed that either relationship could be expressed by having an object property. I might revisit this.

**How does the tag feature work?**

If it's used, it assumes that each object has a property called `tags` that's a list of strings. It checks if the string after the `#` is in that list. This seems to be a pretty common convention for tagged data.

### TODO

See [issues](https://github.com/polm/philtre/issues). 

### Similar Work

[Ghost Query Language](https://github.com/TryGhost/GQL) has basically the same goal but is intended for use via an HTTP API. 

### License

WTFPL, do as you please. 

-POLM
