//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftOpenAPIGenerator open source project
//
// Copyright (c) 2023 Apple Inc. and the SwiftOpenAPIGenerator project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftOpenAPIGenerator project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
import Foundation

/// An object for building up a generated file line-by-line.
///
/// After creation, make calls such as `writeLine` to build up the file,
/// and call `rendered` at the end to get the full file contents.
final class StringCodeWriter {

    /// The stored lines of code.
    private var lines: [String]

    /// The current nesting level.
    private var level: Int

    /// Whether the next call to `writeLine` will continue writing to the last
    /// stored line. Otherwise a new line is appended.
    private var nextWriteAppendsToLastLine: Bool = false

    /// Creates a new empty writer.
    init() {
        self.level = 0
        self.lines = []
    }

    /// Concatenates the stored lines of code into a single string.
    /// - Returns: The contents of the full file in a single string.
    func rendered() -> String { lines.joined(separator: "\n") }

    /// Writes a line of code.
    ///
    /// By default, a new line is appended to the file.
    ///
    /// To continue the last line, make a call to `nextLineAppendsToLastLine`
    /// before calling `writeLine`.
    /// - Parameter line: The contents of the line to write.
    func writeLine(_ line: String) {
        let newLine: String
        if nextWriteAppendsToLastLine && !lines.isEmpty {
            let existingLine = lines.removeLast()
            newLine = existingLine + line
        } else {
            let indentation = Array(repeating: " ", count: 4 * level).joined()
            newLine = indentation + line
        }
        lines.append(newLine)
        nextWriteAppendsToLastLine = false
    }

    /// Increases the indentation level by 1.
    func push() { level += 1 }

    /// Decreases the indentation level by 1.
    /// - Precondition: Current level must be greater than 0.
    func pop() {
        precondition(level > 0, "Cannot pop below 0")
        level -= 1
    }

    /// Executes the provided closure with one level deeper indentation.
    /// - Parameter work: The closure to execute.
    /// - Returns: The result of the closure execution.
    func withNestedLevel<R>(_ work: () -> R) -> R {
        push()
        defer { pop() }
        return work()
    }

    /// Sets a flag on the writer so that the next call to `writeLine` continues
    /// the last stored line instead of starting a new line.
    ///
    /// Safe to call repeatedly, it gets reset by `writeLine`.
    func nextLineAppendsToLastLine() { nextWriteAppendsToLastLine = true }
}

/// A renderer that uses string interpolation and concatenation
/// to convert the provided structure code into raw string form.
struct TextBasedRenderer: RendererProtocol {

    func render(structured: StructuredSwiftRepresentation, diagnostics: any DiagnosticCollector) throws
        -> InMemoryOutputFile
    {
        let namedFile = structured.file
        renderFile(namedFile.contents)
        let string = writer.rendered()
        return InMemoryOutputFile(baseName: namedFile.name, contents: Data(string.utf8))
    }

    /// The underlying writer.
    private let writer: StringCodeWriter

    /// Creates a new empty renderer.
    static var `default`: TextBasedRenderer { .init(writer: StringCodeWriter()) }

    // MARK: - Internals

    /// Returns the current contents of the writer as a string.
    func renderedContents() -> String { writer.rendered() }

    /// Renders the specified Swift file.
    func renderFile(_ description: FileDescription) {
        if let topComment = description.topComment { renderComment(topComment) }
        if let imports = description.imports { renderImports(imports) }
        for codeBlock in description.codeBlocks {
            renderCodeBlock(codeBlock)
            writer.writeLine("")
        }
    }

    /// Renders the specified comment.
    func renderComment(_ comment: Comment) {
        let prefix: String
        let commentString: String
        switch comment {
        case .inline(let string):
            prefix = "//"
            commentString = string
        case .doc(let string):
            prefix = "///"
            commentString = string
        case .mark(let string, sectionBreak: true):
            prefix = "// MARK: -"
            commentString = string
        case .mark(let string, sectionBreak: false):
            prefix = "// MARK:"
            commentString = string
        }
        let lines = commentString.transformingLines { line in
            if line.isEmpty { return prefix }
            return "\(prefix) \(line)"
        }
        lines.forEach(writer.writeLine)
    }

    /// Renders the specified import statements.
    func renderImports(_ imports: [ImportDescription]?) { (imports ?? []).forEach(renderImport) }

    /// Renders a single import statement.
    func renderImport(_ description: ImportDescription) {
        func render(preconcurrency: Bool) {
            if let canImportModule = description.canImportModule {
                writer.writeLine("#if \(canImportModule.map { "canImport(\($0)" }.joined(separator: " || "))")
            }
            let spiPrefix = description.spi.map { "@_spi(\($0)) " } ?? ""
            let preconcurrencyPrefix = preconcurrency ? "@preconcurrency " : ""
            if let moduleTypes = description.moduleTypes {
                for type in moduleTypes { writer.writeLine("\(preconcurrencyPrefix)\(spiPrefix)import \(type)") }
            } else {
                writer.writeLine("\(preconcurrencyPrefix)\(spiPrefix)import \(description.moduleName)")
            }
            if description.canImportModule != nil {
                writer.writeLine("#endif")
            }
        }

        switch description.preconcurrency {
        case .always: render(preconcurrency: true)
        case .never: render(preconcurrency: false)
        case .onOS(let operatingSystems):
            writer.writeLine("#if \(operatingSystems.map { "os(\($0))" }.joined(separator: " || "))")
            render(preconcurrency: true)
            writer.writeLine("#else")
            render(preconcurrency: false)
            writer.writeLine("#endif")
        }
    }

    /// Renders the specified access modifier.
    func renderedAccessModifier(_ accessModifier: AccessModifier) -> String {
        switch accessModifier {
        case .public: return "public"
        case .package: return "package"
        case .internal: return "internal"
        case .fileprivate: return "fileprivate"
        case .private: return "private"
        }
    }

    /// Renders the specified identifier.
    func renderedIdentifier(_ identifier: IdentifierDescription) -> String {
        switch identifier {
        case .pattern(let string): return string
        case .type(let existingTypeDescription): return renderedExistingTypeDescription(existingTypeDescription)
        }
    }

    /// Renders the specified member access expression.
    func renderMemberAccess(_ memberAccess: MemberAccessDescription) {
        if let left = memberAccess.left {
            renderExpression(left)
            writer.nextLineAppendsToLastLine()
        }
        writer.writeLine(".\(memberAccess.right)")
    }

    /// Renders the specified function call argument.
    func renderFunctionCallArgument(_ arg: FunctionArgumentDescription) {
        if let left = arg.label {
            writer.writeLine("\(left): ")
            writer.nextLineAppendsToLastLine()
        }
        renderExpression(arg.expression)
    }

    /// Renders the specified function call.
    func renderFunctionCall(_ functionCall: FunctionCallDescription) {
        renderExpression(functionCall.calledExpression)
        writer.nextLineAppendsToLastLine()
        writer.writeLine("(")
        let arguments = functionCall.arguments
        if arguments.count > 1 {
            writer.withNestedLevel {
                for (argument, isLast) in arguments.enumeratedWithLastMarker() {
                    renderFunctionCallArgument(argument)
                    if !isLast {
                        writer.nextLineAppendsToLastLine()
                        writer.writeLine(",")
                    }
                }
            }
        } else {
            writer.nextLineAppendsToLastLine()
            if let argument = arguments.first { renderFunctionCallArgument(argument) }
            writer.nextLineAppendsToLastLine()
        }
        writer.writeLine(")")
        if let trailingClosure = functionCall.trailingClosure {
            writer.nextLineAppendsToLastLine()
            writer.writeLine(" ")
            renderClosureInvocation(trailingClosure)
        }
    }

    /// Renders the specified assignment expression.
    func renderAssignment(_ assignment: AssignmentDescription) {
        renderExpression(assignment.left)
        writer.nextLineAppendsToLastLine()
        writer.writeLine(" = ")
        writer.nextLineAppendsToLastLine()
        renderExpression(assignment.right)
    }

    /// Renders the specified switch case kind.
    func renderSwitchCaseKind(_ kind: SwitchCaseKind) {
        switch kind {
        case let .`case`(expression, associatedValueNames):
            let associatedValues: String
            let maybeLet: String
            if !associatedValueNames.isEmpty {
                associatedValues = "(" + associatedValueNames.joined(separator: ", ") + ")"
                maybeLet = "let "
            } else {
                associatedValues = ""
                maybeLet = ""
            }
            writer.writeLine("case \(maybeLet)")
            writer.nextLineAppendsToLastLine()
            renderExpression(expression)
            writer.nextLineAppendsToLastLine()
            writer.writeLine(associatedValues)
        case .multiCase(let expressions):
            writer.writeLine("case ")
            writer.nextLineAppendsToLastLine()
            for (expression, isLast) in expressions.enumeratedWithLastMarker() {
                renderExpression(expression)
                writer.nextLineAppendsToLastLine()
                if !isLast { writer.writeLine(", ") }
                writer.nextLineAppendsToLastLine()
            }
        case .`default`: writer.writeLine("default")
        }
    }

    /// Renders the specified switch case.
    func renderSwitchCase(_ switchCase: SwitchCaseDescription) {
        renderSwitchCaseKind(switchCase.kind)
        writer.nextLineAppendsToLastLine()
        writer.writeLine(":")
        writer.withNestedLevel { renderCodeBlocks(switchCase.body) }
    }

    /// Renders the specified switch expression.
    func renderSwitch(_ switchDesc: SwitchDescription) {
        writer.writeLine("switch ")
        writer.nextLineAppendsToLastLine()
        renderExpression(switchDesc.switchedExpression)
        writer.nextLineAppendsToLastLine()
        writer.writeLine(" {")
        for caseDesc in switchDesc.cases { renderSwitchCase(caseDesc) }
        writer.writeLine("}")
    }

    /// Renders the specified if statement.
    func renderIf(_ ifDesc: IfStatementDescription) {
        let ifBranch = ifDesc.ifBranch
        writer.writeLine("if ")
        writer.nextLineAppendsToLastLine()
        renderExpression(ifBranch.condition)
        writer.nextLineAppendsToLastLine()
        writer.writeLine(" {")
        writer.withNestedLevel { renderCodeBlocks(ifBranch.body) }
        writer.writeLine("}")
        for branch in ifDesc.elseIfBranches {
            writer.nextLineAppendsToLastLine()
            writer.writeLine(" else if ")
            writer.nextLineAppendsToLastLine()
            renderExpression(branch.condition)
            writer.nextLineAppendsToLastLine()
            writer.writeLine(" {")
            writer.withNestedLevel { renderCodeBlocks(branch.body) }
            writer.writeLine("}")
        }
        if let elseBody = ifDesc.elseBody {
            writer.nextLineAppendsToLastLine()
            writer.writeLine(" else {")
            writer.withNestedLevel { renderCodeBlocks(elseBody) }
            writer.writeLine("}")
        }
    }

    /// Renders the specified switch expression.
    func renderDoStatement(_ description: DoStatementDescription) {
        writer.writeLine("do {")
        writer.withNestedLevel { renderCodeBlocks(description.doStatement) }
        if let catchBody = description.catchBody {
            writer.writeLine("} catch {")
            if !catchBody.isEmpty {
                writer.withNestedLevel { renderCodeBlocks(catchBody) }
            } else {
                writer.nextLineAppendsToLastLine()
            }
        }
        writer.writeLine("}")
    }

    /// Renders the specified value binding expression.
    func renderValueBinding(_ valueBinding: ValueBindingDescription) {
        writer.writeLine("\(renderedBindingKind(valueBinding.kind)) ")
        writer.nextLineAppendsToLastLine()
        renderFunctionCall(valueBinding.value)
    }

    /// Renders the specified keyword.
    func renderedKeywordKind(_ kind: KeywordKind) -> String {
        switch kind {
        case .return: return "return"
        case .try(hasPostfixQuestionMark: let hasPostfixQuestionMark): return "try\(hasPostfixQuestionMark ? "?" : "")"
        case .await: return "await"
        case .throw: return "throw"
        case .yield: return "yield"
        }
    }

    /// Renders the specified unary keyword expression.
    func renderUnaryKeywordExpression(_ expression: UnaryKeywordDescription) {
        writer.writeLine(renderedKeywordKind(expression.kind))
        guard let expr = expression.expression else { return }
        writer.nextLineAppendsToLastLine()
        writer.writeLine(" ")
        writer.nextLineAppendsToLastLine()
        renderExpression(expr)
    }

    /// Renders the specified closure invocation.
    func renderClosureInvocation(_ invocation: ClosureInvocationDescription) {
        writer.writeLine("{")
        if !invocation.argumentNames.isEmpty {
            writer.nextLineAppendsToLastLine()
            writer.writeLine(" \(invocation.argumentNames.joined(separator: ", ")) in")
        }
        if let body = invocation.body { writer.withNestedLevel { renderCodeBlocks(body) } }
        writer.writeLine("}")
    }

    /// Renders the specified binary operator.
    func renderedBinaryOperator(_ op: BinaryOperator) -> String { op.rawValue }

    /// Renders the specified binary operation.
    func renderBinaryOperation(_ operation: BinaryOperationDescription) {
        renderExpression(operation.left)
        writer.nextLineAppendsToLastLine()
        writer.writeLine(" \(renderedBinaryOperator(operation.operation)) ")
        writer.nextLineAppendsToLastLine()
        renderExpression(operation.right)
    }

    /// Renders the specified inout expression.
    func renderInOutDescription(_ description: InOutDescription) {
        writer.writeLine("&")
        writer.nextLineAppendsToLastLine()
        renderExpression(description.referencedExpr)
    }

    /// Renders the specified optional chaining expression.
    func renderOptionalChainingDescription(_ description: OptionalChainingDescription) {
        renderExpression(description.referencedExpr)
        writer.nextLineAppendsToLastLine()
        writer.writeLine("?")
    }

    /// Renders the specified tuple expression.
    func renderTupleDescription(_ description: TupleDescription) {
        writer.writeLine("(")
        writer.nextLineAppendsToLastLine()
        let members = description.members
        for (member, isLast) in members.enumeratedWithLastMarker() {
            renderExpression(member)
            if !isLast {
                writer.nextLineAppendsToLastLine()
                writer.writeLine(", ")
            }
            writer.nextLineAppendsToLastLine()
        }
        writer.writeLine(")")
    }

    /// Renders the specified expression.
    func renderExpression(_ expression: Expression) {
        switch expression {
        case .literal(let literalDescription): renderLiteral(literalDescription)
        case .identifier(let identifierDescription): writer.writeLine(renderedIdentifier(identifierDescription))
        case .memberAccess(let memberAccessDescription): renderMemberAccess(memberAccessDescription)
        case .functionCall(let functionCallDescription): renderFunctionCall(functionCallDescription)
        case .assignment(let assignment): renderAssignment(assignment)
        case .switch(let switchDesc): renderSwitch(switchDesc)
        case .ifStatement(let ifDesc): renderIf(ifDesc)
        case .doStatement(let doStmt): renderDoStatement(doStmt)
        case .valueBinding(let valueBinding): renderValueBinding(valueBinding)
        case .unaryKeyword(let unaryKeyword): renderUnaryKeywordExpression(unaryKeyword)
        case .closureInvocation(let closureInvocation): renderClosureInvocation(closureInvocation)
        case .binaryOperation(let binaryOperation): renderBinaryOperation(binaryOperation)
        case .inOut(let inOut): renderInOutDescription(inOut)
        case .optionalChaining(let optionalChaining): renderOptionalChainingDescription(optionalChaining)
        case .tuple(let tuple): renderTupleDescription(tuple)
        }
    }

    /// Renders the specified literal expression.
    func renderLiteral(_ literal: LiteralDescription) {
        func write(_ string: String) { writer.writeLine(string) }
        switch literal {
        case let .string(string):
            // Use a raw literal if the string contains a quote/backslash.
            if string.contains("\"") || string.contains("\\") {
                write("#\"\(string)\"#")
            } else {
                write("\"\(string)\"")
            }
        case let .int(int): write("\(int)")
        case let .float(float, precision): write(String(format: "%.\(precision)f", float))
        case let .bool(bool): write(bool ? "true" : "false")
        case .nil: write("nil")
        case .array(let items):
            writer.writeLine("[")
            if !items.isEmpty {
                writer.withNestedLevel {
                    for (item, isLast) in items.enumeratedWithLastMarker() {
                        renderExpression(item)
                        if !isLast {
                            writer.nextLineAppendsToLastLine()
                            writer.writeLine(",")
                        }
                    }
                }
            } else {
                writer.nextLineAppendsToLastLine()
            }
            writer.writeLine("]")
        }
    }

    /// Renders the specified where clause requirement.
    func renderedWhereClauseRequirement(_ requirement: WhereClauseRequirement) -> String {
        switch requirement {
        case .conformance(let left, let right): return "\(left): \(right)"
        }
    }

    /// Renders the specified where clause.
    func renderedWhereClause(_ clause: WhereClause) -> String {
        let renderedRequirements = clause.requirements.map(renderedWhereClauseRequirement)
        return "where \(renderedRequirements.joined(separator: ", "))"
    }

    /// Renders the specified extension declaration.
    func renderExtension(_ extensionDescription: ExtensionDescription) {
        if let accessModifier = extensionDescription.accessModifier {
            writer.writeLine(renderedAccessModifier(accessModifier) + " ")
            writer.nextLineAppendsToLastLine()
        }
        writer.writeLine("extension \(extensionDescription.onType)")
        writer.nextLineAppendsToLastLine()
        if !extensionDescription.conformances.isEmpty {
            writer.writeLine(": \(extensionDescription.conformances.joined(separator: ", "))")
            writer.nextLineAppendsToLastLine()
        }
        if let whereClause = extensionDescription.whereClause {
            writer.writeLine(" " + renderedWhereClause(whereClause))
            writer.nextLineAppendsToLastLine()
        }
        writer.writeLine(" {")
        for declaration in extensionDescription.declarations {
            writer.withNestedLevel { renderDeclaration(declaration) }
        }
        writer.writeLine("}")
    }

    /// Renders the specified type reference to an existing type.
    func renderedExistingTypeDescription(_ type: ExistingTypeDescription) -> String {
        switch type {
        case .any(let existingTypeDescription): return "any \(renderedExistingTypeDescription(existingTypeDescription))"
        case .generic(let wrapper, let wrapped):
            return "\(renderedExistingTypeDescription(wrapper))<\(renderedExistingTypeDescription(wrapped))>"
        case .optional(let existingTypeDescription):
            return "\(renderedExistingTypeDescription(existingTypeDescription))?"
        case .member(let components): return components.joined(separator: ".")
        case .array(let existingTypeDescription): return "[\(renderedExistingTypeDescription(existingTypeDescription))]"
        case .dictionaryValue(let existingTypeDescription):
            return "[String: \(renderedExistingTypeDescription(existingTypeDescription))]"
        }
    }

    /// Renders the specified typealias declaration.
    func renderTypealias(_ alias: TypealiasDescription) {
        var words: [String] = []
        if let accessModifier = alias.accessModifier { words.append(renderedAccessModifier(accessModifier)) }
        words.append(contentsOf: ["typealias", alias.name, "=", renderedExistingTypeDescription(alias.existingType)])
        writer.writeLine(words.joinedWords())
    }

    /// Renders the specified binding kind.
    func renderedBindingKind(_ kind: BindingKind) -> String {
        switch kind {
        case .var: return "var"
        case .let: return "let"
        }
    }

    /// Renders the specified variable declaration.
    func renderVariable(_ variable: VariableDescription) {
        do {
            if let accessModifier = variable.accessModifier {
                writer.writeLine(renderedAccessModifier(accessModifier) + " ")
                writer.nextLineAppendsToLastLine()
            }
            if variable.isStatic {
                writer.writeLine("static ")
                writer.nextLineAppendsToLastLine()
            }
            writer.writeLine(renderedBindingKind(variable.kind) + " ")
            writer.nextLineAppendsToLastLine()
            renderExpression(variable.left)
            if let type = variable.type {
                writer.nextLineAppendsToLastLine()
                writer.writeLine(": \(renderedExistingTypeDescription(type))")
            }
        }

        if let right = variable.right {
            writer.nextLineAppendsToLastLine()
            writer.writeLine(" = ")
            writer.nextLineAppendsToLastLine()
            renderExpression(right)
        }

        if let body = variable.getter {
            writer.nextLineAppendsToLastLine()
            writer.writeLine(" {")
            writer.withNestedLevel {
                let hasExplicitGetter =
                    !variable.getterEffects.isEmpty || variable.setter != nil || variable.modify != nil
                if hasExplicitGetter {
                    let keywords = variable.getterEffects.map(renderedFunctionKeyword).joined(separator: " ")
                    let line = "get \(keywords) {"
                    writer.writeLine(line)
                    writer.push()
                }
                renderCodeBlocks(body)
                if hasExplicitGetter {
                    writer.pop()
                    writer.writeLine("}")
                }
                if let modify = variable.modify {
                    writer.writeLine("_modify {")
                    writer.withNestedLevel { renderCodeBlocks(modify) }
                    writer.writeLine("}")
                }
                if let setter = variable.setter {
                    writer.writeLine("set {")
                    writer.withNestedLevel { renderCodeBlocks(setter) }
                    writer.writeLine("}")
                }
            }
            writer.writeLine("}")
        }
    }

    /// Renders the specified struct declaration.
    func renderStruct(_ structDesc: StructDescription) {
        if let accessModifier = structDesc.accessModifier {
            writer.writeLine(renderedAccessModifier(accessModifier) + " ")
            writer.nextLineAppendsToLastLine()
        }
        writer.writeLine("struct \(structDesc.name)")
        writer.nextLineAppendsToLastLine()
        if !structDesc.conformances.isEmpty {
            writer.writeLine(": \(structDesc.conformances.joined(separator: ", "))")
            writer.nextLineAppendsToLastLine()
        }
        writer.writeLine(" {")
        if !structDesc.members.isEmpty {
            writer.withNestedLevel { for member in structDesc.members { renderDeclaration(member) } }
        } else {
            writer.nextLineAppendsToLastLine()
        }
        writer.writeLine("}")
    }

    /// Renders the specified protocol declaration.
    func renderProtocol(_ protocolDesc: ProtocolDescription) {
        if let accessModifier = protocolDesc.accessModifier {
            writer.writeLine("\(renderedAccessModifier(accessModifier)) ")
            writer.nextLineAppendsToLastLine()
        }
        writer.writeLine("protocol \(protocolDesc.name)")
        writer.nextLineAppendsToLastLine()
        if !protocolDesc.conformances.isEmpty {
            let conformances = protocolDesc.conformances.joined(separator: ", ")
            writer.writeLine(": \(conformances)")
            writer.nextLineAppendsToLastLine()
        }
        writer.writeLine(" {")
        if !protocolDesc.members.isEmpty {
            writer.withNestedLevel { for member in protocolDesc.members { renderDeclaration(member) } }
        } else {
            writer.nextLineAppendsToLastLine()
        }
        writer.writeLine("}")
    }

    /// Renders the specified enum declaration.
    func renderEnum(_ enumDesc: EnumDescription) {
        if requiresFrozenAnnotation(enumDesc) {
            writer.writeLine("@frozen ")
            writer.nextLineAppendsToLastLine()
        }
        if let accessModifier = enumDesc.accessModifier {
            writer.writeLine("\(renderedAccessModifier(accessModifier)) ")
            writer.nextLineAppendsToLastLine()
        }
        if enumDesc.isIndirect {
            writer.writeLine("indirect ")
            writer.nextLineAppendsToLastLine()
        }
        writer.writeLine("enum \(enumDesc.name)")
        writer.nextLineAppendsToLastLine()
        if !enumDesc.conformances.isEmpty {
            writer.writeLine(": \(enumDesc.conformances.joined(separator: ", "))")
            writer.nextLineAppendsToLastLine()
        }
        writer.writeLine(" {")
        if !enumDesc.members.isEmpty {
            writer.withNestedLevel { for member in enumDesc.members { renderDeclaration(member) } }
        } else {
            writer.nextLineAppendsToLastLine()
        }
        writer.writeLine("}")
    }

    /// Renders the specified enum case associated value.
    func renderedEnumCaseAssociatedValue(_ value: EnumCaseAssociatedValueDescription) -> String {
        var words: [String] = []
        if let label = value.label { words.append(label + ":") }
        words.append(renderedExistingTypeDescription(value.type))
        return words.joinedWords()
    }

    /// Renders the specified enum case declaration.
    func renderEnumCase(_ enumCase: EnumCaseDescription) {
        writer.writeLine("case \(enumCase.name)")
        switch enumCase.kind {
        case .nameOnly: break
        case .nameWithRawValue(let rawValue):
            writer.nextLineAppendsToLastLine()
            writer.writeLine(" = ")
            writer.nextLineAppendsToLastLine()
            renderLiteral(rawValue)
        case .nameWithAssociatedValues(let values):
            if values.isEmpty { break }
            let associatedValues = values.map(renderedEnumCaseAssociatedValue).joined(separator: ", ")
            writer.nextLineAppendsToLastLine()
            writer.writeLine("(\(associatedValues))")
        }
    }

    /// Renders the specified declaration.
    func renderDeclaration(_ declaration: Declaration) {
        switch declaration {
        case let .commentable(comment, nestedDeclaration):
            renderCommentableDeclaration(comment: comment, declaration: nestedDeclaration)
        case let .availableAttribute(attribute, nestedDeclaration):
            renderAvailableAttribute(availableAttribute: attribute, declaration: nestedDeclaration)
        case .variable(let variableDescription): renderVariable(variableDescription)
        case .extension(let extensionDescription): renderExtension(extensionDescription)
        case .struct(let structDescription): renderStruct(structDescription)
        case .protocol(let protocolDescription): renderProtocol(protocolDescription)
        case .enum(let enumDescription): renderEnum(enumDescription)
        case .typealias(let typealiasDescription): renderTypealias(typealiasDescription)
        case .function(let functionDescription): renderFunction(functionDescription)
        case .enumCase(let enumCase): renderEnumCase(enumCase)
        }
    }

    /// Renders the specified function kind.
    func renderedFunctionKind(_ functionKind: FunctionKind) -> String {
        switch functionKind {
        case .initializer(let isFailable): return "init\(isFailable ? "?" : "")"
        case .function(let name, let isStatic): return (isStatic ? "static " : "") + "func \(name)"
        }
    }

    /// Renders the specified function keyword.
    func renderedFunctionKeyword(_ keyword: FunctionKeyword) -> String {
        switch keyword {
        case .throws: return "throws"
        case .async: return "async"
        }
    }

    /// Renders the specified function signature.
    func renderFunctionSignature(_ signature: FunctionSignatureDescription) {
        do {
            if let accessModifier = signature.accessModifier {
                writer.writeLine(renderedAccessModifier(accessModifier) + " ")
                writer.nextLineAppendsToLastLine()
            }
            writer.writeLine(renderedFunctionKind(signature.kind) + "(")
            let parameters = signature.parameters
            let separateLines = parameters.count > 1
            if separateLines {
                writer.withNestedLevel {
                    for (parameter, isLast) in signature.parameters.enumeratedWithLastMarker() {
                        renderParameter(parameter)
                        if !isLast {
                            writer.nextLineAppendsToLastLine()
                            writer.writeLine(",")
                        }
                    }
                }
            } else {
                writer.nextLineAppendsToLastLine()
                if let parameter = parameters.first { renderParameter(parameter) }
                writer.nextLineAppendsToLastLine()
            }
            writer.writeLine(")")
        }

        do {
            let keywords = signature.keywords
            if !keywords.isEmpty {
                for keyword in keywords {
                    writer.nextLineAppendsToLastLine()
                    writer.writeLine(" " + renderedFunctionKeyword(keyword))
                }
            }
        }

        if let returnType = signature.returnType {
            writer.nextLineAppendsToLastLine()
            writer.writeLine(" -> ")
            writer.nextLineAppendsToLastLine()
            renderExpression(returnType)
        }
    }

    /// Renders the specified function declaration.
    func renderFunction(_ functionDescription: FunctionDescription) {
        renderFunctionSignature(functionDescription.signature)
        guard let body = functionDescription.body else { return }
        writer.nextLineAppendsToLastLine()
        writer.writeLine(" {")
        if !body.isEmpty {
            writer.withNestedLevel { renderCodeBlocks(body) }
        } else {
            writer.nextLineAppendsToLastLine()
        }
        writer.writeLine("}")
    }

    /// Renders the specified parameter declaration.
    func renderParameter(_ parameterDescription: ParameterDescription) {
        if let label = parameterDescription.label { writer.writeLine(label) } else { writer.writeLine("_") }
        writer.nextLineAppendsToLastLine()
        if let name = parameterDescription.name, name != parameterDescription.label {
            // If the label and name are the same value, don't repeat it.
            writer.writeLine(" ")
            writer.nextLineAppendsToLastLine()
            writer.writeLine(name)
            writer.nextLineAppendsToLastLine()
        }
        writer.writeLine(": ")
        writer.nextLineAppendsToLastLine()
        writer.writeLine(renderedExistingTypeDescription(parameterDescription.type))
        if let defaultValue = parameterDescription.defaultValue {
            writer.nextLineAppendsToLastLine()
            writer.writeLine(" = ")
            writer.nextLineAppendsToLastLine()
            renderExpression(defaultValue)
        }
    }

    /// Renders the specified declaration with a comment.
    func renderCommentableDeclaration(comment: Comment?, declaration: Declaration) {
        if let comment { renderComment(comment) }
        renderDeclaration(declaration)
    }
    
    func renderAvailableAttribute(availableAttribute: AvailableAttributeDescription, declaration: Declaration) {
        renderAvailableAttribute(availableAttribute: availableAttribute)
        renderDeclaration(declaration)
    }
    
    func renderAvailableAttribute(availableAttribute: AvailableAttributeDescription) {
        let renderedContent = switch availableAttribute {
        case let .os(supportedPlatforms): renderedSupportedPlatform(supportedPlatforms)
        case let .deprecated(deprecationDescription): renderedDeprecation(deprecationDescription)
        }
        let line = "@available(\(renderedContent.joined(separator: ", ")))"
        writer.writeLine(line)
    }
    
    func renderedSupportedPlatform(_ supportedPlatforms: [AvailableAttributeDescription.SupportedPlatform]) -> [String] {
        supportedPlatforms.map { renderedIdentifier($0.platformName) + " " + renderedIdentifier($0.version) }
    }

    func renderedDeprecation(_ deprecation: AvailableAttributeDescription.DeprecationDescription) -> [String] {
        return [
            "*", "deprecated", deprecation.message.map { "message: \"\($0)\"" },
            deprecation.renamed.map { "renamed: \"\($0)\"" },
        ].compactMap({ $0 })
    }

    /// Renders the specified code block item.
    func renderCodeBlockItem(_ description: CodeBlockItem) {
        switch description {
        case .declaration(let declaration): renderDeclaration(declaration)
        case .expression(let expression): renderExpression(expression)
        }
    }

    /// Renders the specified code block.
    func renderCodeBlock(_ description: CodeBlock) {
        if let comment = description.comment { renderComment(comment) }
        let item = description.item
        renderCodeBlockItem(item)
    }

    /// Renders the specified code blocks.
    func renderCodeBlocks(_ blocks: [CodeBlock]) { blocks.forEach(renderCodeBlock) }
}

fileprivate extension Array {

    /// Returns a collection of tuples, where the first element is
    /// the collection element and the second is a Boolean value indicating
    /// whether it is the last element in the collection.
    /// - Returns: A collection of tuples.
    func enumeratedWithLastMarker() -> [(Element, isLast: Bool)] {
        let count = count
        return enumerated().map { index, element in (element, index == count - 1) }
    }
}

fileprivate extension Array where Element == String {
    /// Returns a string where the elements of the array are joined
    /// by a space character.
    /// - Returns: A string with the elements of the array joined by space characters.
    func joinedWords() -> String { joined(separator: " ") }
}

fileprivate extension String {

    /// Returns an array of strings, where each string represents one line
    /// in the current string.
    /// - Returns: An array of strings, each representing one line in the original string.
    func asLines() -> [String] { split(omittingEmptySubsequences: false, whereSeparator: \.isNewline).map(String.init) }

    /// Returns a new string where the provided closure transforms each line.
    /// The closure takes a string representing one line as a parameter.
    /// - Parameter work: The closure that transforms each line.
    /// - Returns: A new string where each line has been transformed using the given closure.
    func transformingLines(_ work: (String) -> String) -> [String] { asLines().map(work) }
}

extension TextBasedRenderer {

    /// Returns the provided expression rendered as a string.
    /// - Parameter expression: The expression.
    /// - Returns: The string representation of the expression.
    static func renderedExpressionAsString(_ expression: Expression) -> String {
        let renderer = TextBasedRenderer.default
        renderer.renderExpression(expression)
        return renderer.renderedContents()
    }

    /// Checks if the given enum description requires a @frozen annotation.
    /// - Parameter enumDesc: The enum description to check.
    /// - Returns: A boolean value indicating whether the enum description requires a @frozen annotation.
    func requiresFrozenAnnotation(_ enumDesc: EnumDescription) -> Bool {
        guard enumDesc.isFrozen else { return false }
        guard let accessModifier = enumDesc.accessModifier else { return false }
        return accessModifier == .public || accessModifier == .package
    }
}
