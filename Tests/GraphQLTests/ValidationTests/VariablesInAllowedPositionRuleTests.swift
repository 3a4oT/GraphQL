@testable import GraphQL
import XCTest

class VariablesInAllowedPositionRuleTests: ValidationTestCase {
    override func setUp() {
        rule = VariablesInAllowedPositionRule
    }

    func testBooleanToBoolean() throws {
        try assertValid(
            """
            query Query($booleanArg: Boolean)
            {
              complicatedArgs {
                booleanArgField(booleanArg: $booleanArg)
              }
            }
            """
        )
    }

    func testBooleanToBooleanWithinFragment() throws {
        try assertValid(
            """
            fragment booleanArgFrag on ComplicatedArgs {
              booleanArgField(booleanArg: $booleanArg)
            }
            query Query($booleanArg: Boolean)
            {
              complicatedArgs {
                ...booleanArgFrag
              }
            }
            """
        )

        try assertValid(
            """
            query Query($booleanArg: Boolean)
            {
              complicatedArgs {
                ...booleanArgFrag
              }
            }
            fragment booleanArgFrag on ComplicatedArgs {
              booleanArgField(booleanArg: $booleanArg)
            }
            """
        )
    }

    func testNonNullBooleanToBoolean() throws {
        try assertValid(
            """
            query Query($nonNullBooleanArg: Boolean!)
            {
              complicatedArgs {
                booleanArgField(booleanArg: $nonNullBooleanArg)
              }
            }
            """
        )
    }

    func testNonNullBooleanToBooleanWithinFragment() throws {
        try assertValid(
            """
            fragment booleanArgFrag on ComplicatedArgs {
              booleanArgField(booleanArg: $nonNullBooleanArg)
            }

            query Query($nonNullBooleanArg: Boolean!)
            {
              complicatedArgs {
                ...booleanArgFrag
              }
            }
            """
        )
    }

    func testStringListToStringList() throws {
        try assertValid(
            """
            query Query($stringListVar: [String])
            {
              complicatedArgs {
                stringListArgField(stringListArg: $stringListVar)
              }
            }
            """
        )
    }

    func testNonNullStringListToStringList() throws {
        try assertValid(
            """
            query Query($stringListVar: [String!])
            {
              complicatedArgs {
                stringListArgField(stringListArg: $stringListVar)
              }
            }
            """
        )
    }

    func testStringToStringListInItemPosition() throws {
        try assertValid(
            """
            query Query($stringVar: String)
            {
              complicatedArgs {
                stringListArgField(stringListArg: [$stringVar])
              }
            }
            """
        )
    }

    func testNonNullStringToStringListInItemPosition() throws {
        try assertValid(
            """
            query Query($stringVar: String!)
            {
              complicatedArgs {
                stringListArgField(stringListArg: [$stringVar])
              }
            }
            """
        )
    }

    func testComplexInputToComplexInput() throws {
        try assertValid(
            """
            query Query($complexVar: ComplexInput)
            {
              complicatedArgs {
                complexArgField(complexArg: $complexVar)
              }
            }
            """
        )
    }

    func testComplexInputToComplexInputInFieldPosition() throws {
        try assertValid(
            """
            query Query($boolVar: Boolean = false)
            {
              complicatedArgs {
                complexArgField(complexArg: {requiredArg: $boolVar})
              }
            }
            """
        )
    }

    func testNonNullBooleanToNonNullBooleanInDirective() throws {
        try assertValid(
            """
            query Query($boolVar: Boolean!)
            {
              dog @include(if: $boolVar)
            }
            """
        )
    }

    func testIntToIntNonNull() throws {
        let errors = try assertInvalid(
            errorCount: 1,
            query:
            """
            query Query($intArg: Int) {
              complicatedArgs {
                nonNullIntArgField(nonNullIntArg: $intArg)
              }
            }
            """
        )
        try assertValidationError(
            error: errors[0],
            locations: [
                (line: 1, column: 13),
                (line: 3, column: 39),
            ],
            message: #"Variable "$intArg" of type "Int" used in position expecting type "Int!"."#
        )
    }

    func testIntToIntNonNullWithinFragment() throws {
        let errors = try assertInvalid(
            errorCount: 1,
            query:
            """
            fragment nonNullIntArgFieldFrag on ComplicatedArgs {
              nonNullIntArgField(nonNullIntArg: $intArg)
            }

            query Query($intArg: Int) {
              complicatedArgs {
                ...nonNullIntArgFieldFrag
              }
            }
            """
        )
        try assertValidationError(
            error: errors[0],
            locations: [
                (line: 5, column: 13),
                (line: 2, column: 37),
            ],
            message: #"Variable "$intArg" of type "Int" used in position expecting type "Int!"."#
        )
    }

    func testIntToIntNonNullWithinNestedFragment() throws {
        let errors = try assertInvalid(
            errorCount: 1,
            query:
            """
            fragment outerFrag on ComplicatedArgs {
              ...nonNullIntArgFieldFrag
            }

            fragment nonNullIntArgFieldFrag on ComplicatedArgs {
              nonNullIntArgField(nonNullIntArg: $intArg)
            }

            query Query($intArg: Int) {
              complicatedArgs {
                ...outerFrag
              }
            }
            """
        )
        try assertValidationError(
            error: errors[0],
            locations: [
                (line: 9, column: 13),
                (line: 6, column: 37),
            ],
            message: #"Variable "$intArg" of type "Int" used in position expecting type "Int!"."#
        )
    }

    func testStringToBoolean() throws {
        let errors = try assertInvalid(
            errorCount: 1,
            query:
            """
            query Query($stringVar: String) {
              complicatedArgs {
                booleanArgField(booleanArg: $stringVar)
              }
            }
            """
        )
        try assertValidationError(
            error: errors[0],
            locations: [
                (line: 1, column: 13),
                (line: 3, column: 33),
            ],
            message: #"Variable "$stringVar" of type "String" used in position expecting type "Boolean"."#
        )
    }

    func testStringToStringList() throws {
        let errors = try assertInvalid(
            errorCount: 1,
            query:
            """
            query Query($stringVar: String) {
              complicatedArgs {
                stringListArgField(stringListArg: $stringVar)
              }
            }
            """
        )
        try assertValidationError(
            error: errors[0],
            locations: [
                (line: 1, column: 13),
                (line: 3, column: 39),
            ],
            message: #"Variable "$stringVar" of type "String" used in position expecting type "[String]"."#
        )
    }

    func testBooleanToNonNullBooleanInDirective() throws {
        let errors = try assertInvalid(
            errorCount: 1,
            query:
            """
            query Query($boolVar: Boolean) {
              dog @include(if: $boolVar)
            }
            """
        )
        try assertValidationError(
            error: errors[0],
            locations: [
                (line: 1, column: 13),
                (line: 2, column: 20),
            ],
            message: #"Variable "$boolVar" of type "Boolean" used in position expecting type "Boolean!"."#
        )
    }

    func testStringToNonNullBooleanInDirective() throws {
        let errors = try assertInvalid(
            errorCount: 1,
            query:
            """
            query Query($stringVar: String) {
              dog @include(if: $stringVar)
            }
            """
        )
        try assertValidationError(
            error: errors[0],
            locations: [
                (line: 1, column: 13),
                (line: 2, column: 20),
            ],
            message: #"Variable "$stringVar" of type "String" used in position expecting type "Boolean!"."#
        )
    }

    func testStringListToStringListNonNull() throws {
        let errors = try assertInvalid(
            errorCount: 1,
            query:
            """
            query Query($stringListVar: [String]) {
              complicatedArgs {
                stringListNonNullArgField(stringListNonNullArg: $stringListVar)
              }
            }
            """
        )
        try assertValidationError(
            error: errors[0],
            locations: [
                (line: 1, column: 13),
                (line: 3, column: 53),
            ],
            message: #"Variable "$stringListVar" of type "[String]" used in position expecting type "[String!]"."#
        )
    }

    func testOptionalVariableWithDefaultValue() throws {
        let errors = try assertInvalid(
            errorCount: 1,
            query:
            """
            query Query($intVar: Int = null) {
              complicatedArgs {
                nonNullIntArgField(nonNullIntArg: $intVar)
              }
            }
            """
        )
        try assertValidationError(
            error: errors[0],
            locations: [
                (line: 1, column: 13),
                (line: 3, column: 39),
            ],
            message: #"Variable "$intVar" of type "Int" used in position expecting type "Int!"."#
        )
    }

    func testIntOptionalWithNonNullDefaultValue() throws {
        try assertValid("""
        query Query($intVar: Int = 1) {
          complicatedArgs {
            nonNullIntArgField(nonNullIntArg: $intVar)
          }
        }
        """)
    }

    func testOptionalVariableWithDefaultValueAndNonNullField() throws {
        try assertValid("""
        query Query($intVar: Int) {
          complicatedArgs {
            nonNullFieldWithDefault(nonNullIntArg: $intVar)
          }
        }
        """)
    }

    func testBooleanWithDefaultValueInDirective() throws {
        try assertValid("""
        query Query($boolVar: Boolean = false) {
          dog @include(if: $boolVar)
        }
        """)
    }
}
