# Editor Documentation

## Introduction
Editor is composed of two products:
- `EditorCore`: Model definition and implementation of tokenization and theming.
- `EditorUI`: Integration with TextKit for use with NSTextView and UITextView.

You will very likely be using both, keep reading for how to use them.

## `EditorCore`
Most of your interaction with `EditorCore` will be defining your language grammars and themes.

## Grammar
A grammar is a definition of the langauge structure. It allows us to tokenize the text into distinct tokens with all of the scope that each token has so that we can apply context-aware syntax highlighting. For example, if a grammar was defined for the Swift programming langauge and we had the following code:
```Swift
let score = 10

let str = "I rate Editor\(score)/10"
```
We would receive tokens such as `let` with a "keyword" (or whatever it was named) scope.

Now, this doesn't stop there. Scopes can be accumulated and stack on top of each other which makes the syntax highlighting aware. So language grammars start out with a base scope named something like "source.swift". This would mean that `let` would have scopes: `source.swift`, `keyword`. And then `score` inside the string might have something like: `source.swift`, `string.quoted.double`, `source.swift`, `variable.local`.

Let's look at how we define a grammar.

Grammars have the following constructor
```Swift
public init(
    scopeName: String,
    fileTypes: [String] = [],
    patterns: [Pattern] = [],
    foldingStartMarker: String? = nil,
    foldingStopMarker: String? = nil,
    repository: Repository? = nil
)
```
- `scopeName` is the base scope for the text. E.g. `source.swift`.
- `fileTypes` are the file types to use the grammar for. **NOT YET IMPLEMENTED**
- `patterns` are base scope level patterns.
- `foldingStartMarker` **NOT YET IMPLEMENTED**
- `foldingStopMarker` **NOT YET IMPLEMENTED**
- `repository` is the repository of patterns that can referenced from the list of patterns.

Ok, this begs the question, what is a pattern?

## Patterns and Rules
Patterns define the grammar structure so that the text can be split into tokens. The magic to the context-aware tokenization is that patterns can be recursive. This can make defining structure recursive, so we make a distinction between `Pattern`s and `Rules`s, by defining a `Rule` as a `Pattern` that has been resolved and can be applied to the text. So `Pattern`s are simply defined in the grammar, and then turned into concrete `Rule`s when they need to be applied to text.

Types of Patterns:
- `MatchRule`: Matches a single line regex. Already a concrete rule due to its concrete definition. Used for things like keywords.
- `BeginEndRule`: Has a begin regex and end regex, can span multiple lines and can have patterns to apply in between. Usef for patterns like multi-line comments. 
- `IncludeRulePattern`: Refernces a pattern in the repository.
- `IncludeGrammarPattern`: Recursively references the repository.
- `IncludeLanguagePattern`: Reference another language grammar. **NOT YET IMPLEMENTED**

Now whilst there are 5 different patterns, they will all resolve to one or more Rules, and you may have guessed there are actually only two types of rules: `MatchRule` and `BeginEndRule`.

### `MatchRule`
Match a regex on single line of text. Examples:
```Swift
let classRule = MatchRule(name: "keyword.special.class", match: "\\bclass\\b")

let boldRule = MatchRule(name: "markup.bold", match: "\\*.*?\\*", captures: [])

let italicRule = MatchRule(name: "markup.italic", match: "_.*?_", captures: [])
```

### `BeginEndRule`
Match a begin regex, then try matching it's patterns until the first match of the end regex is found, spanning multiple lines. Example:
```Swift
let swiftString = BeginEndRule(
    name: "string.quoted.double",
    begin: "\"",
    end: "\"",
    patterns: [
        MatchRule(name: "source.swift", match: #"\\\(.*\)"#, captures: [
            Capture(patterns: [IncludeGrammarPattern()])
        ])
    ]
)
```
Note the sub-patterns to look for string interpolation and it's captures to recursively include the grammar. But what is a `Capture`? We'll look at that next.


## `Capture`s
When your rules regexes match text (whether it is the MatchRule regex or the two BeginEndRule regexes) you may want to look to apply additional scopes to those matches. A good example is with the bold and italic text `MatchRule` definitions above. You may have noticed they can't be used together to get a bold and italic text token. This is where captures are useful.

Captures take two optional arguments:
```Swift
public init(name: String? = nil, patterns: [Pattern] = [])
```

Use `name` to directly apply the scope to the capture group. Use `patterns` to try and apply more patterns in the capture group.

`Capture`s are applied on the capture group of the index in the array they are defined. Let's take a look at some examples. 


#### MatchRule Captures
Let's use `Capture`s with `MatchRule`s to solve the simultaneously bold and italic problem.

```Swift
let bold = MatchRule(name: "markup.bold", match: "\\*.*?\\*", captures: [
    Capture(patterns: [
        MatchRule(name: "markup.italic", match: "_.*?_", captures: [])
    ])
])
let italic = MatchRule(name: "markup.italic", match: "_.*?_", captures: [
    Capture(patterns: [
        MatchRule(name: "markup.bold", match: "\\*.*?\\*", captures: [])
    ])
])
```
Here it's pretty simple, the 0th capture group (the whole regex match) has the `Capture` applied to look for the other rule.

#### BeginEndRule Captures
**NOT YET IMPLEMENTED**

#### Nested Captures
Captures can quickly get a little confusing when there are nested capture groups. Here is an example to see how it is handled.

Say you have a `MatchRule` like so:
```Swift
MatchRule(name: "example", match: "\\+((Hello) (world))\\+", captures: [
    Capture(),
    Capture(name: "Hello world"),
    Capture(name: "Hello"),
    Capture(name: "world")
])
```
Nested capture groups work such that the above "Hello world" capture is applied, then the "Hello", and finally "world". Any scopes added from parent captures will be cascaded onto the nested captures. For example, using the above rule on the following text:

`+Hello world+`

Will produce tokens like:
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

## `Repository`
The repository is essentially a bank of patterns for a `Grammar`.  Patterns in the repository are referenced by a string key. The repository is really for the sake of clarity and brevity. For example, it makes defining our above italic and bold grammar a lot cleaner. Let's see how:

Original:
```Swift
Grammar(
    scopeName: "source.test.05",
    fileTypes: [],
    patterns: [
        MatchRule(name: "markup.bold", match: "\\*.*?\\*", captures: [
            Capture(patterns: [
                MatchRule(name: "markup.italic", match: "_.*?_", captures: [])
            ])
        ]),
        MatchRule(name: "markup.italic", match: "_.*?_", captures: [
            Capture(patterns: [
                MatchRule(name: "markup.bold", match: "\\*.*?\\*", captures: [])
            ])
        ])
    ]
)
```
Using Repository:
```Swift
Grammar(
    scopeName: "source.test.05",
    fileTypes: [],
    patterns: [
        IncludeRulePattern(include: "bold"),
        IncludeRulePattern(include: "italic"),
    ],
    repository: Repository(patterns: [
        "bold": MatchRule(name: "markup.bold", match: "\\*.*?\\*", captures: [
            Capture(patterns: [
                IncludeRulePattern(include: "italic")
            ])
        ]),
        "italic": MatchRule(name: "markup.italic", match: "_.*?_", captures: [
            Capture(patterns: [
                IncludeRulePattern(include: "bold")
            ])
        ])
    ])
)
```

Now obviously for this example, we have more lines of code but we have removed the duplicate concrete pattern (rule) definition. However, it is not too hard to see that as the Grammar grows, it will be beneficial by reducing the duplicate pattern definition like in the original. 

## Themes
**TODO**

## `EditorUI`

**TODO**
