import Foundation

class MalType {}

class MalBool: MalType {
    let value: String;
    init(value:String) {
        self.value = value
    }
}

class MalDict: MalType {
    let items: [String: MalType];
    init(items: [String: MalType]) {
        self.items = items
    }
    func get(k: String) -> MalType? {
        return items[k]
    }
}

class MalError: MalType {
    let value: String;
    init(value: String) {
        self.value = value
    }
}

func helper1(m: MalType) -> MalType {return m}
func helper2(m: MalType, n:MalType) -> MalType {return m}

class MalFun: MalType {

    let a1: (MalType) -> MalType;
    let a2: (MalType, MalType) -> MalType;
    init(a2: (MalType, MalType) -> MalType) {
        self.a2 = a2
        self.a1 = helper1
    }
    init(a1: (MalType) -> MalType) {
        self.a1 = a1
        self.a2 = helper2
    }

}

class MalInt: MalType {
    let value: Int;
    init(value: Int) {
        self.value = value
    }
}

class MalKeyword: MalType {
    let value: String;
    init(value: String) {
        self.value = value
    }
}

class MalList: MalType {
    var items: [MalType];
    init(items: [MalType]) {
        self.items = items
    }
    func count() -> Int {
        return items.count
    }
    func get(i:Int) -> MalType {
        return items[i]
    }
    func push(item: MalType) {
        items.append(item)
    }
    func pop() -> MalType {
        return items.removeLast()
    }

    func first() -> MalType {
        return items[0]
    }
    func second() -> MalType {
        return items[1]
    }
    func rest() -> [MalType] {
        var copy = items
        copy.removeAtIndex(0)
        return copy
    }
}

class MalSymbol: MalType {
    let value: String;
    init(value: String) {
        self.value = value
    }
}

class MalNil: MalType {
    let value: String;
    override init() {
        self.value = "nil"
    }
}

class MalStr: MalType {
    var value: String;
    init(value: String) {
        self.value = value
    }
}

class MalVec: MalType {
    var items: [MalType];
    init(items: [MalType]) {
        self.items = items
    }
    func count() -> Int {
        return items.count
    }
    func get(i:Int) -> MalType {
        return items[i]
    }
    func push(item: MalType) {
        items.append(item)
    }
    func pop() -> MalType {
        return items.removeLast()
    }
}


func printHelper(coll:[MalType]) -> [String] {
    var result:[String] = []
    for i in coll {
        result.append(printString(i))
    }
    return result
}

func printList(list: MalList) -> String {
    let result = printHelper(list.items)
    return "(" + (" ".join(result)) + ")"
}

func printVec(vec: MalVec) -> String {
    let result = printHelper(vec.items)
    return "[" + (" ".join(result)) + "]"
}

func printDict(dict: MalDict) -> String {
    let items = dict.items
    let keys = Array(items.keys)
    var result = [String]()
    for key in keys {
        result.append(key)
        result.append(printString(items[key]!))
    }
    return "{" + (" ".join(result)) + "}"
}

func printString (t:MalType) -> String {

    switch t {
    case is MalInt:
        return toString((t as MalInt ).value)
    case is MalKeyword:
        return (t as MalKeyword).value
    case is MalNil:
        return "nil"
    case is MalStr:
        return (t as MalStr).value
    case is MalSymbol:
        return (t as MalSymbol).value
    case is MalDict:
        return printDict(t as MalDict)
    case is MalList:
        return printList(t as MalList)
    case is MalVec:
        return printVec(t as MalVec)
    case is MalError:
        return (t as MalError).value
    case is MalNil:
        return "nil"
    case is MalBool:
        return (t as MalBool).value
    default:
        return "Error: Cannot printString"
    }
}


class Reader {
    var tokens: [String];
    var position: Int;
    init (tokens: [String]) {
        self.position = 0;
        self.tokens = tokens
    }

    func next() -> String? {
        if let p = peek() {
            position = position + 1
            return p
        } else {
            return nil
        }
    }

    func peek() -> String? {
        if position == tokens.count {
            return nil
        } else {
        return tokens[position]
        }
    }
}

// MARK: ------------ Reading Forms

func regex(p:String, s:String) -> [String] {
    let regex = NSRegularExpression(pattern: p, options: .allZeros, error: nil)
    let range = NSMakeRange(0, countElements(s))
    let matches = regex?.matchesInString(s, options: .allZeros, range: range) as [NSTextCheckingResult]
    return matches.map {
        let range = $0.range
        let s1 = (s as NSString).substringWithRange(range)
        return s1.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}

func tokenize(s: String) -> [String] {
    let pattern = "[\\s ,]*(~@|[\\[\\]{}()'`~@]|\"(?:[\\\\].|[^\\\\\"])*\"|;.*|[^\\s \\[\\]{}()'\"`~@,;]*)"
    return regex(pattern, s)
}

func containsMatch(pattern: String, inString string: String) -> Bool {
    let regex = NSRegularExpression(pattern: pattern, options: .allZeros, error: nil)
    let range = NSMakeRange(0, countElements(string))
    return regex?.firstMatchInString(string, options: .allZeros, range: range) != nil
}


func readAtom(reader: Reader) -> MalType {
    if let s = reader.next() {
        if containsMatch("^-?[0-9]+$", inString: s) {
            return MalInt(value: s.toInt()!)
        } else if s == "false" {
            return MalBool(value: "false")
        } else if s == "true" {
            return MalBool(value: "true")
        } else if s == "nil" {
            return MalNil()
        } else if s.hasPrefix(":") {
            return MalStr(value: s)
        } else if !s.hasPrefix("\"") {
            return MalSymbol(value: s)
        } else {
            return MalStr(value: s)
        }
    } else {
        return MalError(value: "No type found")
    }
}


func readList(reader: Reader, start: String = "(", end: String = ")") -> MalType {
    var ast = MalList(items:[]);
    reader.next();
    while reader.peek() != end {
        reader.peek()
        ast.push(readForm(reader));
    }
    reader.next()
    return ast;
}

func even(x:Int) -> Bool {
   return x % 2 == 0
}

func readDict(reader:Reader) -> MalType {
    let list = readList(reader, start: "{", end: "}") as MalList
    let items = list.items
    if items.count % 2 == 0 {

    var keys = [String]()
    var values = [MalType]()
    var dict = [String: MalType]()
    var ind:Int = 0
        for item in items {
            if even(ind) {
                keys.append((item as MalStr).value)
            } else {
                values.append(item)
            }
            ind = ind + 1
        }
        for i in 0..<(keys.count) {
            dict[keys[i]] = values[i]
        }
    return MalDict(items: dict)
} else {
        return MalError(value: "Odd number of elements.")
}
}


func readVec(reader: Reader) -> MalType {
    var list = readList(reader, start: "[", end: "]") as MalList
    return MalVec(items: list.items)
}

func readForm(reader: Reader) -> MalType {
    if let p = reader.peek() {
        switch p {
        case "(":
            return readList(reader)
        case ")":
            return MalError(value: "Unexpected ')'")
        case "[":
            return readVec(reader)
        case "]":
            return MalError(value: "Unexpected ']'")
        case "{":
            return readDict(reader)
        case "}":
            return MalError(value: "Unexpected '{'")
        default:
            return readAtom(reader)
        }
    } else {
        return MalError(value: "Expected closing paren")
    }
}

func readString(s:String) -> MalType {
    let coll = tokenize(s);
    let reader = Reader(tokens: coll);
    return readForm(reader);
}

// MARK: ------- EVAL

func _apply(fun: MalFun , a1: MalType, a2: MalType) -> MalType {
    return fun.a2(a1, a2)
}

func _apply(fun: MalFun, a1: MalType) -> MalType {
    return fun.a1(a1)
}

func apply(fun: MalFun, args: [MalType]) -> MalType {
    switch args.count {
    case 1:
        return _apply(fun, args[0])
    case 2:
        return _apply(fun, args[0], args[1])
//    case 3:
//        return _apply(fun, args[0], args[1], args[2])
    default: return MalError(value: "apply is broken")
    }
}

func evalDict(d: MalDict, env:[String: MalFun]) -> MalType {
let dict = d.items
    let keys = dict.keys
    var result = [String:MalType]()
    for key in keys {
        result[key] = eval(dict[key]!, env)
    }
    return MalDict(items: result)
}

func evalAst(ast: MalType, env:[String: MalFun]) -> MalType {
    switch ast {
    case is MalInt:
        return ast
    case is MalSymbol:
        if let sym = env[(ast as MalSymbol).value] {
            return (sym as MalFun)
        } else {
            let msg = "'" + (ast as MalSymbol).value + "' not found."
            return MalError(value: msg)
        }
    case is MalDict:
            return evalDict(ast as MalDict, env)
    case is MalVec:
        return MalVec(items: (ast as MalVec).items.map
            {eval($0,env)})
    case is MalList:
        return MalList(items: (ast as MalList).items.map
            {eval($0,env)})
    default: return ast;
    }
}

func eval(ast: MalType, env:[String: MalFun]) -> MalType {
    switch ast {
    case is MalList:
        printString(ast)
        let result = evalAst(ast, env) as MalList
        result.second()
        let fun = result.first() as MalFun
        let args = result.rest()
        return apply(fun, args)
    default:
        return evalAst(ast,  env)
    }
}



let replEnv = [
    "+": MalFun(a2: { (a:MalType, b:MalType) -> MalType in
        return MalInt(value:((a as MalInt).value + (b as MalInt).value))}),
    "-": MalFun(a2:{ (a:MalType, b:MalType) -> MalType in
        return MalInt(value:((a as MalInt).value - (b as MalInt).value))}),
    "*": MalFun(a2: { (a:MalType, b:MalType) -> MalType in
        return MalInt(value:((a as MalInt).value * (b as MalInt).value))}),
    "/": MalFun(a2: { (a:MalType, b:MalType) -> MalType in
        return MalInt(value:((a as MalInt).value / (b as MalInt).value))})
   ]

func prompt() -> String {
    var keyboard = NSFileHandle.fileHandleWithStandardInput()
    var inputData = keyboard.availableData
    return NSString(data: inputData, encoding:NSUTF8StringEncoding)!
}

func rep() {
    println("user> ");
    while true {
        var s = printString(eval(readString(prompt()), replEnv))
        println( "=>" + s)
    }
}

rep()

