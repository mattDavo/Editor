# Editor

A language grammar tokenizer and themer, with an integrated editor.



## Grammar

### Capture groups
#### MatchRule
You can define capture groups in your MatchRules like so:
```Swift
MatchRule(name: "example", match: "\\+((Hello) (world))\\+", captures: [
    Capture(),
    Capture(name: "Hello world"),
    Capture(name: "Hello"),
    Capture(name: "world")
])
```
Captures can have name, patterns or both. Nested capture groups work such that the above "Hello world" capture is applied, then the "Hello", and finally "world". Any scopes added from parent captures will be cascaded onto the nested captures. For example, using the above rule on the following text:

`+Hello world+`

Will produce:
```
Tokenizing line: +Hello world+

 - Token from 0 to 1 '+' with scopes: [source.test.05, test, ]
 - Token from 1 to 6 'Hello' with scopes: [source.test.05, test, , Hello world, Hello]
 - Token from 6 to 7 ' ' with scopes: [source.test.05, test, , Hello world]
 - Token from 7 to 12 'world' with scopes: [source.test.05, test, , Hello world, world]
 - Token from 12 to 13 '+' with scopes: [source.test.05, test, ]
 - Token from 13 to 14 '
' with scopes: [source.test.05]
```
