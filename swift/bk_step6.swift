import Foundation

class Env: MalType {
    var outer:  Env?
    var data = [String:MalType]()

    func bind(binds:[MalType], exprs:[MalType]) -> Env {
        for var i = 0; i < binds.count; i++ {
            var k = (binds[i] as MalSymbol).value
            if k == "&" {
                let end = exprs.count - 1
                let rest = Array(exprs[i...end])
                k = (binds[i + 1] as MalSymbol).value
                set(k, v: MalList(items: rest))
                break
            } else {
                set(k, v: exprs[i])
            }
        }
        return self
    }

    func outer(outerEnv: Env) -> (Env) {
        outer = outerEnv
        return self
    }
    func set(k:String, v: MalType) -> MalType {
        data[k] = v
        return v
    }
    func find(k:String) -> [String:MalType]? {
        if let result = data[k] {
            return .Some(data)
        } else if let result = outer?.find(k) {
            return outer?.find(k)
        } else {
            return .None
        }
    }
    func get(k:String) -> MalType? {
        if let result = find(k) {
            return result[k]
        } else {
            return .None // MalError(value: k + " not found")
        }
    }
}

// MARK: -------------- Types -------------------

class MalType {
}

class MalBool: MalType, Equatable {
    let value: Bool;
    init(value:Bool) {
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

class MalFun: MalType {
    let fn: (MalList) -> MalType
    var ast: MalType?
    var params: [MalType]?
    var env: Env?

    init(fn: (MalList) -> MalType) {
        self.fn = fn
    }
}

class MalInt: MalType, Equatable {
    let value: Int;
    init(value: Int) {
        self.value = value
    }

}

class MalKeyword: MalType, Equatable {
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
    func count() -> MalInt {
        return MalInt(value: items.count)
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
    func third() -> MalType {
        return items[2]
    }
    func rest() -> MalList {
        var copy = items
        copy.removeAtIndex(0)
        return MalList(items: copy)
    }
}

class MalNil: MalType, Equatable {
    let value = "nil"
}

class MalStr: MalType, Equatable {
    var value: String;
    init(value: String) {
        self.value = value
    }
}

class MalSymbol: MalType, Equatable {
    let value: String;
    init(value: String) {
        self.value = value
    }
}

class MalVec: MalType {
    var items: [MalType];
    init(items: [MalType]) {
        self.items = items
    }
    func count() -> MalInt {
        return MalInt(value: items.count)
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
    func third() -> MalType {
        return items[2]
    }
    func rest() -> [MalType] {
        var copy = items
        copy.removeAtIndex(0)
        return copy
    }

}
// MARK: -------------- Equatable -------------------

func == (lhs: MalBool, rhs: MalBool) -> Bool {
    return lhs.value == rhs.value}
func == (lhs: MalInt, rhs: MalInt) -> Bool {
    return lhs.value == rhs.value}
func == (lhs: MalKeyword, rhs: MalKeyword) -> Bool {
    return lhs.value == rhs.value}
func == (lhs: MalNil, rhs: MalNil) -> Bool {
    return lhs.value == rhs.value}
func == (lhs: MalStr, rhs: MalStr) -> Bool {
    return lhs.value == rhs.value}
func == (lhs: MalSymbol, rhs: MalSymbol) -> Bool {
    return lhs.value == rhs.value}



// MARK: -------------- Printer -------------------

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

func printString (t:MalType, printReadably: Bool = true) -> String {
    switch t {
    case is MalBool:
        return  (t as MalBool).value == true ? "true" : "false"
    case is MalDict:
        return printDict(t as MalDict)
    case is MalError:
        return (t as MalError).value
    case is MalFun:
        return "#<function>"
    case is MalInt:
        return toString((t as MalInt ).value)
    case is MalKeyword:
        return (t as MalKeyword).value
    case is MalList:
        return printList(t as MalList)
    case is MalNil:
        return "nil"
    case is MalStr:
        if !printReadably {
            var st = (t as MalStr).value
            st = st.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
            st = st.stringByReplacingOccurrencesOfString("\n", withString: "\\\n")
            return st
        } else {
            return (t as MalStr).value
        }
    case is MalSymbol:
        return (t as MalSymbol).value

    case is MalVec:
        return printVec(t as MalVec)

    default:
        return "Error: Cannot printString"
    }
}

// MARK: -------------- Error Checking -------------------


func checkForError(t: MalType) -> MalType {
    var accumlator: MalType
    switch t {
    case is MalError:
        return t
    case is MalList:
        accumlator = MalList(items: [])
        let items = (t as MalList).items
        for i in items {
            (accumlator as MalList).push(checkForError(i))
        }
        return accumlator
    case is MalVec:
        accumlator = MalVec(items: [])
        let items = (t as MalList).items
        for i in items {
            (accumlator as MalVec).push(checkForError(i))
        }
        return accumlator
    default: return t
    }
}


func errorCheckandPrint(t:MalType) -> String {
    let x = checkForError(t)
    return printString(x)
}

// MARK: -------------- Reader -------------------


class Reader {
    var tokens: [String];
    var position: Int;
    init (tokens: [String]) {
        self.position = 0;
        self.tokens = tokens
    }

    func next() -> String? {
        let p = peek();
        position = position + 1
        return p
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
        let set = NSCharacterSet(charactersInString: ", ")
        return s1.stringByTrimmingCharactersInSet(set)
    }
}

func tokenize(s: String) -> [String] {
    let pattern = "[\\s ,]*(~@|[\\[\\]\\{\\}\\(\\)'`~^@]|\"(?:\\\\.|[^\\\\\"])*\"|;.*|[^\\s\\[\\]\\{\\}\\('\"`,;\\)]*)"
    return regex(pattern, s)
}


func containsMatch(pattern: String, inString string: String) -> Bool {
    let regex = NSRegularExpression(pattern: pattern, options: .allZeros, error: nil)
    let range = NSMakeRange(0, countElements(string))
    return regex?.firstMatchInString(string, options: .allZeros, range: range) != nil
}


func readAtom(reader: Reader) -> MalType {

    if let s = reader.next() {
        //  println(s)
        if containsMatch("^-?[0-9]+$", inString: s) {
            return MalInt(value: s.toInt()!)
        } else if s == "false" {
            return MalBool(value: false)
        } else if s == "true" {
            return MalBool(value: true)
        } else if s == "nil" {
            return MalNil()
        } else if s == "" {
            return MalNil()
        } else if s.hasPrefix(":") {
            return MalKeyword(value: s)
        } else if s.hasPrefix("\"") {
            var t = s.substringWithRange(Range<String.Index>(start: s.startIndex.successor(), end: s.endIndex.predecessor()))
            t = t.stringByReplacingOccurrencesOfString("\\\"", withString: "\"")

            return MalStr(value: t)
        } else {
            return MalSymbol(value: s)
        }
    } else {
        return MalError(value: "No type found")
    }
}


func readList(reader: Reader, start: String = "(", end: String = ")") -> MalType {
    var ast = MalList(items:[]);
    reader.next();
    while reader.peek() != end {
        if let p = reader.peek() {
            ast.push(readForm(reader));
        } else {
            return MalError(value: "expected '\(end)', got EOF")
        }
    }
    reader.next()
    return ast;
}

func listToDict(list:MalList) -> MalType {
    func even(x:Int) -> Bool {
        return x % 2 == 0
    }
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

func readDict(reader:Reader) -> MalType {
    let list = readList(reader, start: "{", end: "}") as MalList
    return listToDict(list)
}


func readVec(reader: Reader) -> MalType {
    var list = readList(reader, start: "[", end: "]")
    if list is MalList {
        return MalVec(items: (list as MalList).items)
    } else {
        return list
    }
}

func readForm(reader: Reader) -> MalType {
    if let p = reader.peek() {
        switch p {
        case "(":
            return readList(reader)
        case ")":
            reader.next()
            return MalError(value: "Unexpected ')'")
        case "[":
            return readVec(reader)
        case "]":
            reader.next()
            return MalError(value: "Unexpected ']'")
        case "{":
            return readDict(reader)
        case "}":
            reader.next()
            return MalError(value: "Unexpected '{'")
        default:
            return readAtom(reader)
        }
    } else {
        return MalError(value: "readForm not found")
    }
}

func readString(s:String) -> MalType {
    let tokens = tokenize(s);
    let filtered = tokens.map {
      $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }.filter{
        !$0.hasPrefix(";") }
    return readForm(Reader(tokens: filtered));
}


func malReadString(s:MalStr) -> MalType {
// these were when to compensate for str not printing readibly
//let s1 = s.value
//    var s1 = (s.value).stringByReplacingOccurrencesOfString("\\\"", withString: "\"")
//    let s2 =  s1.stringByReplacingOccurrencesOfString("\\", withString: "")
//    print("malReadString: "); println(s2)
    return readString(s.value)
}

// MARK: -------------- Eval -------------------


func evalDict(d: MalDict, env:Env) -> MalType {
    let dict = d.items
    let keys = dict.keys
    var result = [String:MalType]()
    for key in keys {
        result[key] = eval(dict[key]!, env)
    }
    return MalDict(items: result)
}

func evalAst(ast: MalType, env:Env) -> MalType {
    switch ast {
    case is MalError:
        println((ast as MalError).value)
        return ast
    case is MalSymbol:
        if let fun = env.get((ast as MalSymbol).value) {
            return (fun as MalType)
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
    default:
      return ast
    }
}

func createLetEnv(list: MalVec, env:Env) -> Env {
    let items  = list.items
    let c = items.count
    for( var x = 0; x < c; x = x + 2 ) {
        let k = (items[x] as MalSymbol).value as String
        env.set(k,v: (eval(items[(x + 1)], env)))
    }
    return env
}


func isPair(x: MalType) -> Bool {
    switch x {
    case is MalList:
        return (x as MalList).items.isEmpty
    case is MalVec:
        return (x as MalList).items.isEmpty
    default:
        return false
    }
}

// TODO: add Vec for let*

func eval(ast: MalType, env: Env) -> MalType {
//    print("EVAL: "); println(ast)
    if ast is MalError {
      println((ast as MalError).value)
    }
    var ast = ast
    var env = env
    while true {
        switch ast {
        case is MalList:
            var items = (ast as MalList).items
            // check for special forms
            if items.count == 0 {
                return ast
            } else {
                let fst = items[0]
                switch fst {
                case is MalSymbol:
                    switch (fst as MalSymbol).value {
                    case "def!":
                        return env.set((items[1] as MalSymbol).value,
                            v: eval(items[2], env ))
                    case "let*":
                        var newEnv = Env().outer(env)
                        let bindings = items[1] as MalVec
                        newEnv = createLetEnv(bindings, newEnv)
                        env = newEnv
                        ast = items[2]
                        continue
                        // return eval(items[2], newEnv)
                    case "do":
                        let end = items.count - 1
                        for var i = 1; i < end; i++ {
                            //  (items[i] as MalList).items
                            eval(items[i], env)
                        }
                        ast = items[end]
                    case "if":
                        let cond = (eval(items[1], env))
                        switch cond {
                        case is MalNil:
                            if items.count > 3  {
                                ast = items[3];continue
                            } else {
                                return MalNil()
                            }
                        case is MalBool:
                            if (cond as MalBool).value == false {
                                if items.count > 3 {
                                    ast = items[3]; continue
                                } else {
                                    return MalNil()
                                }
                            } else {
                                ast = items[2]; continue
                            }
                        default:
                            ast = items[2]; continue
                        }
                    case "quote":
                        return items[1]
                    case "fn*":
                        var syms = [MalType]()
                        switch items[1] {
                        case is MalList:
                            syms = (items[1] as MalList).items
                        case is MalVec:
                            syms = (items[1] as MalVec).items
                        default:
                            return MalError(value: "Second element not list or vector")
                        }
                        let body = items[2]
                        var fun =  MalFun(
                            fn: {(args:MalList) -> MalType in
                                var newEnv = Env().outer(env)
                                newEnv.bind(syms, exprs: args.items)
                                return eval(body, newEnv)})
                        fun.params = syms
                        fun.env = env
                        fun.ast = body
                        return fun
                    default:
                        // otherwise look up first argument in Env
                        ast = evalAst(ast, env)
                    }
                case is MalFun:
                    items.removeAtIndex(0)
                    let args = Array<MalType>(items)
                    if let body = (fst as MalFun).ast {
                        if let fEnv = (fst as MalFun).env {
                            if let params = (fst as MalFun).params {
                                ast = body
                                var newEnv = Env().outer(fEnv)
                               newEnv.bind(params, exprs: args)
                                env = newEnv
                            }}} else {
                        let rest = MalList (items: args)
                        return (fst as MalFun).fn(rest)
                    }
                default:
                    // called when first item in list is a list
                    return evalAst(ast,  env)
                }}
        default:
            return evalAst(ast,  env)
        }
    }
}

// MARK: -------------- core.ns -------------------

func equals(x: MalType, y: MalType) -> MalBool {
    if x.dynamicType === y.dynamicType {
        switch x {
        case is MalError:
            return MalBool(value: false)
        case is MalBool:
            return MalBool(value: x as MalBool == y as MalBool)
        case is MalInt:
            return MalBool(value: x as MalInt == y as MalInt)
        case is MalKeyword:
            return MalBool(value: x as MalKeyword == y as MalKeyword)
        case is MalNil:
            return MalBool(value: x as MalNil == y as MalNil)
        case is MalStr:
            return MalBool(value: x as MalStr == y as MalStr)
        case is MalSymbol:
            return MalBool(value: x as MalSymbol == y as MalSymbol)
        case is MalList:
            let l1 = (x as MalList).items
            let l2 = (y as MalList).items
            if l1.count == l2.count {
                for (index, item) in (enumerate(l1)) {
                    let boo = equals(item, l2[index])
                    if boo.value == false {
                        return MalBool(value: false)
                    }
                }
                return MalBool(value: true)
            } else {
                MalBool(value: false)
            }
            return MalBool(value: true)
        case is MalVec:
            let l1 = (x as MalVec).items
            let l2 = (y as MalVec).items
            if l1.count == l2.count {
                for (index, item) in (enumerate(l1)) {
                    let boo = equals(item, l2[index])
                    if boo.value == false {
                        return MalBool(value: false)
                    }
                }
                return MalBool(value: true)
            } else {
                MalBool(value: false)
            }
            return MalBool(value: true)
        default:
            return MalBool(value: false)
        }
    } else {
        return MalBool(value: false)}
}



let ns = [
    "+": MalFun(fn: { (args:MalList) -> MalType in
        return MalInt(value:((args.first() as MalInt).value + (args.second() as MalInt).value))}),
    "-": MalFun(fn: { (args:MalList) -> MalType in
        return MalInt(value:((args.first() as MalInt).value - (args.second() as MalInt).value))}),
    "*": MalFun(fn: { (args:MalList) -> MalType in
        return MalInt(value:((args.first() as MalInt).value * (args.second() as MalInt).value))}),
    "/": MalFun(fn: { (args:MalList) -> MalType in
        return MalInt(value:((args.first() as MalInt).value / (args.second() as MalInt).value))}),
    "list": MalFun(fn: {(argList: MalList) -> MalList in
        var newList = MalList(items: [])
        let args = (argList as MalList).items
        for i in args {
            newList.push(i) }
        return newList}),
    "list?": MalFun(fn: {(x: MalList) -> MalBool in return x.first() is MalList ? MalBool(value: true) : MalBool(value: false)}),
    "empty?": MalFun(fn: {(x: MalList) -> MalType in
        let fst = x.first()
        switch fst {
        case is MalList:
            return ((fst as MalList).count() as MalInt).value == 0 ? MalBool(value: true) : MalBool(value: false)
        case is MalVec:
            return ((fst as MalVec).count() as MalInt).value == 0 ? MalBool(value: true) : MalBool(value: false)
        default:
            return MalError(value: "Not a collection")}}),
    "count": MalFun(fn: {(x: MalList) -> MalInt in
        let fst = x.first()
        fst
        if fst is MalList {
            return (fst as MalList).count()
        } else if fst is MalVec{
            return (fst as MalVec).count()
        } else {return MalInt(value: 0)} }),
    "=": MalFun({(x: MalList) -> MalBool in
        return equals(x.first(), x.second())}),
    "<": MalFun({(x: MalList) -> MalBool in
        return MalBool(value: (x.first() as MalInt).value < (x.second() as MalInt).value)}),
    ">": MalFun({(x: MalList) -> MalBool in
        return MalBool(value: (x.first() as MalInt).value > (x.second() as MalInt).value)}),
    "<=": MalFun({(x: MalList) -> MalBool in
        return MalBool(value: (x.first() as MalInt).value <= (x.second() as MalInt).value)}),
    ">=": MalFun({(x: MalList) -> MalBool in
        return MalBool(value: (x.first() as MalInt).value >= (x.second() as MalInt).value)}),
    "pr-str": MalFun({(x: MalList) -> MalStr in
        let lst = x.items.map {printString($0)}
        return MalStr(value: " ".join(lst))}),
    "str": MalFun({(x: MalList) -> MalStr in
        let lst = x.items.map {printString($0, printReadably: true)}
        return MalStr(value: "".join(lst))
        }),
    "prn": MalFun({(x: MalList) -> MalNil in
        let lst = x.items.map {printString($0)}
        println(" ".join(lst))
        return MalNil()}),
    "println": MalFun({(x: MalList) -> MalNil in
        let lst = x.items.map {printString($0, printReadably: false)}
        println(" ".join(lst))
        return MalNil()}),
    "read-string": MalFun({(x: MalList) -> MalType in
        switch x.first() {
        case is MalStr:
            let s = (x.first() as MalStr).value
            return malReadString(x.first() as MalStr)
        case is MalError:
            println((x.first() as MalError).value)
            return x.first()
        default:
            return MalError(value: "read-string takes a string")}}),
    "slurp": MalFun({(x: MalList) -> MalType in
        var error : NSError?
        let file = (x.first() as MalStr).value
        if let contents = NSString(contentsOfFile: file, encoding: NSUTF8StringEncoding, error: &error) {
            let trimmed = contents.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            return MalStr(value: trimmed)
        } else {
            let msg = "Read Failure: \(error!.localizedDescription)"
            println(msg)
            return MalStr(value: msg)
        }}),
]

func populateEnv() -> Env {
    var env = Env()
    for (k, v) in ns {
        env.set(k, v: v)
    }
    return env
}

var replEnv = populateEnv()


replEnv.set("eval", v: MalFun({(x: MalType) -> MalType in
//  print("mal eval: ")
    return eval(x, replEnv)}) )


func prompt() -> String {
    var keyboard = NSFileHandle.fileHandleWithStandardInput()
    var inputData = keyboard.availableData
    return NSString(data: inputData, encoding:NSUTF8StringEncoding)!
}

func slurp(file:String) -> String {
    var error : NSError?
    if let contents = NSString(contentsOfFile: file, encoding: NSUTF8StringEncoding, error: &error) {
        return contents.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    } else {
     let msg = "Read Failure: \(error!.localizedDescription)"
     println(msg)
     return msg
    }
}


func rep() {
    println("user> ");
    while true {
        var s = printString(eval(readString(prompt()), replEnv))
        println( "=>" + s)
    }
}

func rep(s: String) -> String {
    return printString(eval(readString(s), replEnv))
}

 rep("(def! not (fn* (a) (if a false true)))")

rep("(def! load-file (fn* (f) (eval (read-string (str \"(do \"(slurp f)\")\")))))")
rep("(load-file \"../tests/incC.mal\") ")


if Process.arguments.count > 2 {
    var args = [MalType]()
    var file = ""
    for (index, s) in enumerate(Process.arguments) {
        if index == 1{
            file = s
        } else {
            args.append(MalStr(value: s))
        }}

    replEnv.set("*ARGV*", v: MalList(items:args))
    file = "(load-file " + file + ")"
    println(file)
    rep(file);
    // Process(kill);
} else {
   //  rep(slurp("../tests/incC.mal"))
     rep()
}


// (load-file "../tests/incB.mal")

