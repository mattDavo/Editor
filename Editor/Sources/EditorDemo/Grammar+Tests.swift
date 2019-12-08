//
//  Grammar+Tests.swift
//  
//
//  Created by Matthew Davidson on 28/11/19.
//

import Foundation
import EditorCore

extension Grammar {
    
    public struct test {
        public static let test01 = Grammar(
            scopeName: "source.test.01",
            fileTypes: [],
            patterns: [
                MatchRule(name: "keyword.special.cat", match: "[Cc]at")
            ]
        )
        
        public static let test02 = Grammar(
            scopeName: "source.test.02",
            fileTypes: [],
            patterns: [
                MatchRule(name: "keyword.special.cat", match: "[Cc]at"),
                BeginEndRule(name: "string.quoted.double", begin: "\"", end: "\"", patterns: [
                    BeginEndRule(name: "source.test.02", begin: #"\\\("#, end: #"\)"#, patterns: [MatchRule(name: "keyword.special.cat", match: "[Cc]at")])
                ])
            ]
        )
        
        public static let test03 = Grammar(
            scopeName: "source.test.03",
            fileTypes: [],
            patterns: [
                MatchRule(name: "keyword.special.cat", match: "[Cc]at"),
                MatchRule(name: "keyword.special.dog", match: "[Dd]og"),
                MatchRule(name: "action", match: "@[^\\s]+"),
                BeginEndRule(
                    name: "string.quoted.double",
                    begin: "\"",
                    end: "\"",
                    patterns: [
                        BeginEndRule(
                            name: "source.test.03",
                            begin: #"\\\("#,
                            end: #"\)"#,
                            patterns: [
                                IncludeGrammarPattern()
                            ]
                        )
                    ]
                ),
                BeginEndRule(name: "comment.line.double-slash", begin: "//", end: "\\n", patterns: [IncludeRulePattern(include: "todo")]),
                BeginEndRule(name: "comment.block", begin: "/\\*", end: "\\*/", patterns: [IncludeRulePattern(include: "todo")])
            ],
            repository: Repository(patterns: [
                "todo": MatchRule(name: "comment.keyword.todo", match: "TODO")
            ])
        )
        
        public static let test04 = Grammar(
            scopeName: "source.test.04",
            fileTypes: [],
            patterns: [
                IncludeRulePattern(include: "bold"),
                IncludeRulePattern(include: "italic")
            ],
            repository: Repository(
                patterns: [
                    "bold": BeginEndRule(name: "markup.bold", begin: "\\*", end: "\\*", patterns: [IncludeRulePattern(include: "italic")]),
                    "italic": BeginEndRule(name: "markup.italic", begin: "_", end: "_", patterns: [IncludeRulePattern(include: "bold")])
                ]
            )
        )
        
        public static let test05 = Grammar(
            scopeName: "source.test.05",
            fileTypes: [],
            patterns: [
                MatchRule(name: "keyword.special.cat", match: "[Cc]at"),
                MatchRule(name: "keyword.special.dog", match: "[Dd]og"),
                MatchRule(name: "action", match: "@[^\\s]+"),
                BeginEndRule(
                    name: "string.quoted.double",
                    begin: "\"",
                    end: "\"",
                    patterns: [
                        BeginEndRule(
                            name: "source.test.03",
                            begin: #"\\\("#,
                            end: #"\)"#,
                            patterns: [
                                IncludeGrammarPattern()
                            ]
                        )
                    ]
                ),
                BeginEndRule(name: "comment.line.double-slash", begin: "//", end: "\\n", patterns: [IncludeRulePattern(include: "todo")]),
                BeginEndRule(name: "comment.block", begin: "/\\*", end: "\\*/", patterns: [IncludeRulePattern(include: "todo")]),
                IncludeRulePattern(include: "bold"),
                IncludeRulePattern(include: "italic"),
                IncludeRulePattern(include: "mono"),
                IncludeRulePattern(include: "test")
            ],
            repository: Repository(patterns: [
                "todo": MatchRule(name: "comment.keyword.todo", match: "TODO"),
                "bold": MatchRule(name: "markup.bold", match: "\\*.*?\\*", captures: [
                    Capture(patterns: [
                        IncludeRulePattern(include: "italic")
                    ])
                ]),
                "italic": MatchRule(name: "markup.italic", match: "_.*?_", captures: [
                    Capture(patterns: [
                        IncludeRulePattern(include: "bold")
                    ])
                ]),
                "mono": MatchRule(name: "markup.mono", match: "`.*?`", captures: [
                    Capture(patterns: [
                        IncludeRulePattern(include: "bold"),
                        IncludeRulePattern(include: "italic")
                    ])
                ]),
                "test": MatchRule(name: "test", match: "\\+((Hello) (world))\\+", captures: [
                    Capture(),
                    Capture(name: "Hello world"),
                    Capture(name: "Hello"),
                    Capture(name: "world")
                ])
            ])
        )
    }
}
