import CustomDump
import XCTest

#if canImport(CoreGraphics)
import CoreGraphics
#endif

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *) final class DumpTests: XCTestCase {
    func testAnyType() {
        expectNoDifference(
            String(customDumping: Foo.Bar.self),
            """
            Foo.Bar.self
            """
        )

        struct Feature {
            struct State {}
        }
        expectNoDifference(
            String(customDumping: Feature.State.self),
            """
            DumpTests.Feature.State.self
            """
        )

        expectNoDifference(
            String(customDumping: (x: Double, y: Double).self),
            """
            (x: Double, y: Double).self
            """
        )

        expectNoDifference(
            String(customDumping: Double?.self),
            """
            Double?.self
            """
        )

        expectNoDifference(
            String(customDumping: [Int].self),
            """
            [Int].self
            """
        )

        expectNoDifference(
            String(customDumping: [String: Int].self),
            """
            [String: Int].self
            """
        )

        expectNoDifference(
            String(customDumping: [[Double: Double?]].self),
            """
            [[Double: Double?]].self
            """
        )

        expectNoDifference(
            String(customDumping: [[Double: Double]?].self),
            """
            [[Double: Double]?].self
            """
        )

        expectNoDifference(
            String(customDumping: [[Double: [Double]]]?.self),
            """
            [[Double: [Double]]]?.self
            """
        )

        expectNoDifference(
            String(customDumping: [[[Double: Double]]]?.self),
            """
            [[[Double: Double]]]?.self
            """
        )

        expectNoDifference(
            String(customDumping: [Double: [Double?]].self),
            """
            [Double: [Double?]].self
            """
        )

        expectNoDifference(
            String(customDumping: [Double: [Double]?].self),
            """
            [Double: [Double]?].self
            """
        )
    }

    func testClass() {
        let user = UserClass(
            id: 42,
            name: "Blob"
        )

        var dump = ""
        customDump(user, to: &dump)
        expectNoDifference(
            dump,
            """
            UserClass(
              id: 42,
              name: "Blob"
            )
            """
        )

        dump = ""
        customDump(user, to: &dump, maxDepth: 0)
        expectNoDifference(
            dump,
            """
            UserClass(…)
            """
        )

        let foo = RecursiveFoo()
        foo.foo = foo

        expectNoDifference(
            String(customDumping: foo),
            """
            RecursiveFoo(
              foo: RecursiveFoo(↩︎)
            )
            """
        )
    }

    func testCollection() {
        let users = [
            User(
                id: 1,
                name: "Blob"
            ),
            User(
                id: 2,
                name: "Blob, Jr."
            ),
            User(
                id: 3,
                name: "Blob, Sr."
            )
        ]

        expectNoDifference(
            String(customDumping: users),
            """
            [
              [0]: User(
                id: 1,
                name: "Blob"
              ),
              [1]: User(
                id: 2,
                name: "Blob, Jr."
              ),
              [2]: User(
                id: 3,
                name: "Blob, Sr."
              )
            ]
            """
        )

        var dump = ""
        customDump(users, to: &dump, maxDepth: 1)
        expectNoDifference(
            dump,
            """
            [
              [0]: User(…),
              [1]: User(…),
              [2]: User(…)
            ]
            """
        )

        dump = ""
        customDump(users, to: &dump, maxDepth: 0)
        expectNoDifference(
            dump,
            """
            […]
            """
        )
    }

    func testDictionary() {
        expectNoDifference(
            String(
                customDumping: [
                    1: User(
                        id: 1,
                        name: "Blob"
                    ),
                    2: User(
                        id: 2,
                        name: "Blob, Jr."
                    )
                ]
            ),
            """
            [
              1: User(
                id: 1,
                name: "Blob"
              ),
              2: User(
                id: 2,
                name: "Blob, Jr."
              )
            ]
            """
        )

        expectNoDifference(
            String(
                customDumping: [
                    ID(rawValue: "deadbeef"): User(
                        id: 1,
                        name: "Blob"
                    ),
                    ID(rawValue: "beefdead"): User(
                        id: 2,
                        name: "Blob, Jr."
                    )
                ]
            ),
            """
            [
              ID(rawValue: "beefdead"): User(
                id: 2,
                name: "Blob, Jr."
              ),
              ID(rawValue: "deadbeef"): User(
                id: 1,
                name: "Blob"
              )
            ]
            """
        )

        expectNoDifference(
            String(
                customDumping: OrderedDictionary(
                    pairs: [
                        2: User(
                            id: 2,
                            name: "Blob, Jr."
                        ),
                        1: User(
                            id: 1,
                            name: "Blob"
                        )
                    ] as KeyValuePairs
                )
            ),
            """
            [
              2: User(
                id: 2,
                name: "Blob, Jr."
              ),
              1: User(
                id: 1,
                name: "Blob"
              )
            ]
            """
        )
    }

    func testDictionary_Nested() {
        struct NestedDictionary {
            let content: [String: Int]
        }

        expectNoDifference(
            """
            DumpTests.NestedDictionary(
              content: [
                "a": 5,
                "b": 9,
                "c": 1,
                "d": -3,
                "e": 12
              ]
            )
            """,
            String(
                customDumping: NestedDictionary(
                    content: ["a": 5, "b": 9, "c": 1, "d": -3, "e": 12]
                )
            )
        )
    }

    func testEnum() {
        expectNoDifference(
            String(customDumping: Enum.foo),
            """
            Enum.foo
            """
        )

        expectNoDifference(
            String(customDumping: Enum.bar(42)),
            """
            Enum.bar(42)
            """
        )

        expectNoDifference(
            String(customDumping: Enum.fu(bar: 42)),
            """
            Enum.fu(bar: 42)
            """
        )

        expectNoDifference(
            String(customDumping: Enum.baz(fizz: 0.9, buzz: "2")),
            """
            Enum.baz(
              fizz: 0.9,
              buzz: "2"
            )
            """
        )

        expectNoDifference(
            String(customDumping: Enum.fizz(0.9, buzz: "2")),
            """
            Enum.fizz(
              0.9,
              buzz: "2"
            )
            """
        )

        expectNoDifference(
            String(customDumping: Nested.nest(.fizz(0.9, buzz: "2"))),
            """
            Nested.nest(
              .fizz(
                0.9,
                buzz: "2"
              )
            )
            """
        )
    }

    func testOptional() {
        expectNoDifference(
            String(customDumping: User?(.init(id: 42, name: "Blob"))),
            """
            User(
              id: 42,
              name: "Blob"
            )
            """
        )

        expectNoDifference(
            String(customDumping: User?(nil)),
            """
            nil
            """
        )
    }

    func testSet() {
        expectNoDifference(
            String(customDumping: Set([1, 2, 3])),
            """
            Set([
              1,
              2,
              3
            ])
            """
        )
    }

    func testSingleValue() {
        expectNoDifference(
            String(customDumping: 1),
            """
            1
            """
        )

        expectNoDifference(
            String(customDumping: true),
            """
            true
            """
        )
    }

    func testStruct() {
        let user = User(
            id: 42,
            name: "Blob"
        )

        expectNoDifference(
            String(customDumping: user),
            """
            User(
              id: 42,
              name: "Blob"
            )
            """
        )

        var dump = ""
        customDump(user, to: &dump, maxDepth: 0)
        expectNoDifference(
            dump,
            """
            User(…)
            """
        )

        let pair = Pair(
            driver: User(
                id: 1,
                name: "Blob"
            ),
            passenger: User(
                id: 2,
                name: "Blob, Jr."
            )
        )

        expectNoDifference(
            String(customDumping: pair),
            """
            Pair(
              driver: User(
                id: 1,
                name: "Blob"
              ),
              passenger: User(
                id: 2,
                name: "Blob, Jr."
              )
            )
            """
        )

        dump = ""
        customDump(pair, to: &dump, maxDepth: 1)
        expectNoDifference(
            dump,
            """
            Pair(
              driver: User(…),
              passenger: User(…)
            )
            """
        )
    }

    func testTuple() {
        expectNoDifference(
            String(customDumping: (1, 2)),
            """
            (
              1,
              2
            )
            """
        )

        expectNoDifference(
            String(customDumping: (x: 1, y: 2, ())),
            """
            (
              x: 1,
              y: 2,
              ()
            )
            """
        )
    }

    func testString() {
        expectNoDifference(
            String(customDumping: "Hello!"),
            #""Hello!""#
        )

        expectNoDifference(
            String(customDumping: #"Hello, "world!""#),
            ##"#"Hello, "world!""#"##
        )

        expectNoDifference(
            String(customDumping: ####"This has a "### in it"####),
            #####"####"This has a "### in it"####"#####
        )

        expectNoDifference(
            String(customDumping: "This has a \\ in it"),
            ##"#"This has a \ in it"#"##
        )

        expectNoDifference(
            String(customDumping: "This has no special characters in it"),
            "\"This has no special characters in it\""
        )

        expectNoDifference(
            String(customDumping: "This has a \t in it"),
            "\"This has a \\t in it\""
        )
    }

    func testMultilineString() {
        expectNoDifference(
            String(customDumping: "Hello,\nWorld!"),
            #"""
            """
            Hello,
            World!
            """
            """#
        )

        expectNoDifference(
            String(customDumping: "Hello,\nWorld!"[...]),
            #"""
            """
            Hello,
            World!
            """
            """#
        )

        expectNoDifference(
            String(
                customDumping: Email(
                    subject: "RE: Upcoming Event",
                    body: """
                    To whom it may concern,

                    Look forward to it!

                    Yours,
                    Blob
                    """
                )
            ),
            """
            Email(
              subject: "RE: Upcoming Event",
              body: \"\"\"
                To whom it may concern,
                \n\
                Look forward to it!
                \n\
                Yours,
                Blob
                \"\"\"
            )
            """
        )

        expectNoDifference(
            String(
                customDumping: ##"""
                print(
                  #"""
                  Hello, world!
                  """#
                )
                """##
            ),
            ###"""
            ##"""
            print(
              #"""
              Hello, world!
              """#
            )
            """##
            """###
        )
    }

    func testAnyHashable() {
        expectNoDifference(
            String(customDumping: AnyHashable(42)),
            """
            42
            """
        )

        expectNoDifference(
            String(
                customDumping: [
                    AnyHashable(1): User(id: 1, name: "Blob"),
                    AnyHashable("Blob, Jr."): User(id: 2, name: "Blob, Jr.")
                ]
            ),
            """
            [
              "Blob, Jr.": User(
                id: 2,
                name: "Blob, Jr."
              ),
              1: User(
                id: 1,
                name: "Blob"
              )
            ]
            """
        )
    }

    func testKeyPath() {
        // NB: While this should run on >=5.9, it currently crashes CI on Xcode 15
        #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
        if #available(macOS 13.3, iOS 16.4, watchOS 9.4, tvOS 16.4, *) {
            expectNoDifference(
                String(customDumping: \UserClass.name),
                #"""
                \UserClass.name
                """#
            )

            expectNoDifference(
                String(customDumping: \Pair.driver.name),
                #"""
                \Pair.driver.name
                """#
            )

            expectNoDifference(
                String(customDumping: \(x: Double, y: Double).x),
                #"""
                \(x: Double, y: Double).x
                """#
            )

            #if DEBUG
            expectNoDifference(
                String(customDumping: \User.name.count),
                #"""
                \User.name.count
                """#
            )

            expectNoDifference(
                String(customDumping: \Item.$isInStock),
                #"""
                \Item.$isInStock
                """#
            )

            expectNoDifference(
                String(customDumping: \Wrapped<String>.count),
                #"""
                \Wrapped<String>.subscript(dynamicMember: <unknown>)
                """#
            )
            #endif

            return
        } else {
            expectNoDifference(
                String(customDumping: \UserClass.name),
                #"""
                \UserClass.name
                """#
            )

            expectNoDifference(
                String(customDumping: \Pair.driver.name),
                #"""
                \Pair.driver.name
                """#
            )

            expectNoDifference(
                String(customDumping: \User.name.count),
                #"""
                KeyPath<User, Int>
                """#
            )

            expectNoDifference(
                String(customDumping: \(x: Double, y: Double).x),
                #"""
                WritableKeyPath<(x: Double, y: Double), Double>
                """#
            )

            expectNoDifference(
                String(customDumping: \Item.$isInStock),
                #"""
                KeyPath<Item, Wrapped<Bool>>
                """#
            )

            expectNoDifference(
                String(customDumping: \Wrapped<String>.count),
                #"""
                KeyPath<Wrapped<String>, Int>
                """#
            )
        }
        #endif
    }

    func testNamespacedTypes() {
        expectNoDifference(
            String(customDumping: Namespaced.Class(x: 0)),
            """
            Namespaced.Class(x: 0)
            """
        )

        expectNoDifference(
            String(customDumping: Namespaced.Enum.x(0)),
            """
            Namespaced.Enum.x(0)
            """
        )

        expectNoDifference(
            String(customDumping: Namespaced.Struct(x: 0)),
            """
            Namespaced.Struct(x: 0)
            """
        )
    }

    func testGenerics() {
        expectNoDifference(
            String(customDumping: Result<Result<Int, any Error>, any Error>.success(.success(42))),
            """
            Result.success(
              .success(42)
            )
            """
        )
    }

    func testUnknownContexts() {
        struct Inline {}

        expectNoDifference(
            String(customDumping: Inline.self),
            """
            DumpTests.Inline.self
            """
        )

        expectNoDifference(
            String(customDumping: Inline()),
            """
            DumpTests.Inline()
            """
        )
    }

    func testCustomMirror() {
        expectNoDifference(
            String(customDumping: Button()),
            """
            Button.cancel(
              action: nil,
              label: "Cancel"
            )
            """
        )

        expectNoDifference(
            String(
                customDumping: LoginState(
                    email: "blob@pointfree.co",
                    password: "bl0bisawesome!",
                    token: "secret"
                )
            ),
            """
            LoginState(
              email: "blob@pointfree.co",
              password: <redacted>
            )
            """
        )
    }

    func testCustomOverride() {
        expectNoDifference(
            String(customDumping: Wrapper(rawValue: 42)),
            """
            42
            """
        )
    }

    func testStandardLibrary() {
        expectNoDifference(
            String(customDumping: "©" as Character),
            """
            "©"
            """
        )

        expectNoDifference(
            String(customDumping: "Blob" as StaticString),
            """
            "Blob"
            """
        )

        expectNoDifference(
            String(customDumping: "©" as UnicodeScalar),
            """
            "©"
            """
        )
    }

    func testSuperclass() {
        class Human {
            let name = "John"
            let email = "john@me.com"
            let age = 97
        }

        class Doctor: Human {
            let field = "Podiatry"
        }

        expectNoDifference(
            String(customDumping: Doctor()),
            """
            DumpTests.Doctor(
              name: "John",
              email: "john@me.com",
              age: 97,
              field: "Podiatry"
            )
            """
        )
    }

    func testLayersOfInheritance() {
        class Human {
            let name = "John"
            let email = "john@me.com"
            let age = 97
        }

        class Doctor: Human {
            let field = "Podiatry"
        }

        class Surgeon: Doctor {
            let skillLevel = "Expert"
        }

        expectNoDifference(
            String(customDumping: Surgeon()),
            """
            DumpTests.Surgeon(
              name: "John",
              email: "john@me.com",
              age: 97,
              field: "Podiatry",
              skillLevel: "Expert"
            )
            """
        )
    }

    func testRecursion() {
        class Human {
            let name: String

            init(name: String) {
                self.name = name
            }
        }

        class Child: Human {
            weak var parent: Parent?
        }

        class Parent: Human {
            let children: [Human]

            init(name: String, children: [Child]) {
                self.children = children
                super.init(name: name)

                for child in children {
                    child.parent = self
                }
            }
        }

        let subject = Parent(
            name: "Arthur",
            children: [
                Child(name: "Virginia"),
                Child(name: "Ronald"),
                Child(name: "Fred"),
                Child(name: "George"),
                Child(name: "Percy"),
                Child(name: "Charles")
            ]
        )

        expectNoDifference(
            String(customDumping: subject),
            """
            DumpTests.Parent(
              name: "Arthur",
              children: [
                [0]: DumpTests.Child(
                  name: "Virginia",
                  parent: DumpTests.Parent(↩︎)
                ),
                [1]: #1 DumpTests.Child(
                  name: "Ronald",
                  parent: DumpTests.Parent(↩︎)
                ),
                [2]: #2 DumpTests.Child(
                  name: "Fred",
                  parent: DumpTests.Parent(↩︎)
                ),
                [3]: #3 DumpTests.Child(
                  name: "George",
                  parent: DumpTests.Parent(↩︎)
                ),
                [4]: #4 DumpTests.Child(
                  name: "Percy",
                  parent: DumpTests.Parent(↩︎)
                ),
                [5]: #5 DumpTests.Child(
                  name: "Charles",
                  parent: DumpTests.Parent(↩︎)
                )
              ]
            )
            """
        )
    }

    func testRepetition() {
        class Human {
            let name = "John"
        }

        class User: Human {
            let email = "john@me.com"
            let age = 97

            let human: Human

            init(human: Human) {
                self.human = human
            }
        }

        let human = Human()
        let human2 = Human()

        let user = User(human: human)
        let user2 = User(human: human2)

        expectNoDifference(
            String(
                customDumping: [
                    human,
                    human,
                    human,
                    human2,
                    human2,
                    human2,
                    user,
                    user,
                    user,
                    user2,
                    user2,
                    user2
                ]
            ),
            """
            [
              [0]: DumpTests.Human(name: "John"),
              [1]: DumpTests.Human(↩︎),
              [2]: DumpTests.Human(↩︎),
              [3]: #1 DumpTests.Human(name: "John"),
              [4]: #1 DumpTests.Human(↩︎),
              [5]: #1 DumpTests.Human(↩︎),
              [6]: DumpTests.User(
                name: "John",
                email: "john@me.com",
                age: 97,
                human: DumpTests.Human(↩︎)
              ),
              [7]: DumpTests.User(↩︎),
              [8]: DumpTests.User(↩︎),
              [9]: #1 DumpTests.User(
                name: "John",
                email: "john@me.com",
                age: 97,
                human: #1 DumpTests.Human(↩︎)
              ),
              [10]: #1 DumpTests.User(↩︎),
              [11]: #1 DumpTests.User(↩︎)
            ]
            """
        )
    }

    #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
    func testDuration() {
        expectNoDifference(
            String(customDumping: Duration.seconds(5)),
            """
            5 seconds
            """
        )

        expectNoDifference(
            String(customDumping: Duration.seconds(5) + .milliseconds(123)),
            """
            5 seconds, 123 milliseconds
            """
        )
    }
    #endif

    #if canImport(CoreGraphics)
    func testCoreGraphics() {
        expectNoDifference(
            String(customDumping: CGRect(x: 0.5, y: 0.5, width: 1.5, height: 1.5)),
            """
            CGRect(
              origin: CGPoint(
                x: 0.5,
                y: 0.5
              ),
              size: CGSize(
                width: 1.5,
                height: 1.5
              )
            )
            """
        )
    }
    #endif

    #if canImport(SwiftUI)
    func testSwiftUI() {
        expectNoDifference(
            String(customDumping: Animation.easeInOut),
            """
            Animation.easeInOut
            """
        )
    }
    #endif

    func testObservationRegistrarFiltered() {
        struct ObservationRegistrar {}
        class Object {
            let name = "Blob Sr."
            let _$observationRegistrar = ObservationRegistrar()
        }
        expectNoDifference(
            String(customDumping: Object()),
            """
            DumpTests.Object(
              name: "Blob Sr."
            )
            """
        )
        struct Value {
            let name = "Blob Jr."
            let _$observationRegistrar = ObservationRegistrar()
        }
        expectNoDifference(
            String(customDumping: Value()),
            """
            DumpTests.Value(
              name: "Blob Jr."
            )
            """
        )
    }

    func testExplicitFilteredPropertyPreserved() {
        struct ObservationRegistrar {}
        class Object: CustomDumpReflectable {
            let name = "Blob Sr."
            let _$observationRegistrar = ObservationRegistrar()

            var customDumpMirror: Mirror {
                Mirror(
                    self,
                    children: ["name": self.name, "_$observationRegistrar": self._$observationRegistrar],
                    displayStyle: .class
                )
            }
        }
        expectNoDifference(
            String(customDumping: Object()),
            """
            DumpTests.Object(
              name: "Blob Sr.",
              _$observationRegistrar: DumpTests.ObservationRegistrar()
            )
            """
        )
    }

    func testDiffableObject() {
        struct Login {
            var email: String
        }

        class DiffableObject: _CustomDiffObject {
            var _customDiffValues: (Any, Any) {
                (Login(email: "blob@pointfree.co"), Login(email: "admin@pointfree.co"))
            }
        }

        struct DiffableObjects {
            var obj1: DiffableObject
            var obj2: DiffableObject
        }

        struct DiffableObjectsParent {
            var objs1: DiffableObjects
            var objs2: DiffableObjects
        }

        let obj1 = DiffableObject()
        let obj2 = DiffableObject()

        expectNoDifference(
            String(
                customDumping: DiffableObjectsParent(
                    objs1: DiffableObjects(obj1: obj1, obj2: obj1),
                    objs2: DiffableObjects(obj1: obj2, obj2: obj2)
                )
            ),
            """
            DumpTests.DiffableObjectsParent(
              objs1: DumpTests.DiffableObjects(
                obj1: #1 DumpTests.Login(email: "admin@pointfree.co"),
                obj2: #1 DumpTests.Login(↩︎)
              ),
              objs2: DumpTests.DiffableObjects(
                obj1: #2 DumpTests.Login(email: "admin@pointfree.co"),
                obj2: #2 DumpTests.Login(↩︎)
              )
            )
            """
        )

        expectNoDifference(
            String(
                customDumping: DiffableObjectsParent(
                    objs1: DiffableObjects(obj1: obj1, obj2: obj2),
                    objs2: DiffableObjects(obj1: obj2, obj2: obj1)
                )
            ),
            """
            DumpTests.DiffableObjectsParent(
              objs1: DumpTests.DiffableObjects(
                obj1: #1 DumpTests.Login(email: "admin@pointfree.co"),
                obj2: #2 DumpTests.Login(email: "admin@pointfree.co")
              ),
              objs2: DumpTests.DiffableObjects(
                obj1: #2 DumpTests.Login(↩︎),
                obj2: #1 DumpTests.Login(↩︎)
              )
            )
            """
        )
    }

    func testDiffableObject_Primitive() {
        class DiffableObject: _CustomDiffObject {
            var _customDiffValues: (Any, Any) {
                ("before", "after")
            }

            static func == (lhs: DiffableObject, rhs: DiffableObject) -> Bool {
                false
            }
        }

        struct DiffableObjects {
            var obj1: DiffableObject
            var obj2: DiffableObject
        }

        struct DiffableObjectsParent {
            var objs1: DiffableObjects
            var objs2: DiffableObjects
        }

        let obj1 = DiffableObject()
        let obj2 = DiffableObject()
        let objs1 = DiffableObjects(obj1: obj1, obj2: obj1)
        let objs2 = DiffableObjects(obj1: obj2, obj2: obj2)
        let objsParent = DiffableObjectsParent(objs1: objs1, objs2: objs2)

        expectNoDifference(
            String(customDumping: objsParent),
            """
            DumpTests.DiffableObjectsParent(
              objs1: DumpTests.DiffableObjects(
                obj1: #1 "after",
                obj2: #1 String(↩︎)
              ),
              objs2: DumpTests.DiffableObjects(
                obj1: #2 "after",
                obj2: #2 String(↩︎)
              )
            )
            """
        )
    }
}
