import Foundation

class Env: MalType {
    var outer:  Env?
    var data = [String:MalType]()
    
    func bind(binds:[MalType], exprs:[MalType]) {
        for (index, binding) in enumerate(binds) {
            let k = (binding as MalSymbol).value
            if k == "&" {
                let end = exprs.count - 1
                let rest = Array(exprs[index...end])
                set(k, v: MalList(items: rest))
                break
            } else {
                set(k, v: exprs[index])
            }
        }
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
        if containsMatch("^-?[0-9]+$", inString: s) {
            return MalInt(value: s.toInt()!)
        } else if s == "false" {
            return MalBool(value: false)
        } else if s == "true" {
            return MalBool(value: true)
        } else if s == "" {
            return MalNil()
        } else if s.hasPrefix(";") {
            return MalNil()
        } else if s == "nil" {
            return MalNil()
        } else if s.hasPrefix(":") {
            return MalKeyword(value: s)
        } else if s.hasPrefix("\"") {
        let t = s.substringWithRange(Range<String.Index>(start: s.startIndex.successor(), end: s.endIndex.predecessor()))   
        var ss = t.stringByReplacingOccurrencesOfString("\\\"", withString: "\"")
            ss = s.stringByReplacingOccurrencesOfString("\\\n", withString: "\n")
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
    let coll = tokenize(s);
    println(coll)
    let reader = Reader(tokens: coll);
    return readForm(reader);
}

func malReadString(s:MalStr) -> MalType {
    return readString(s.value)
}

// MARK: -------------- Eval -------------------


func apply(list: MalList) -> MalType {
    let fun = list.items[0]

    let args = list.rest()
    switch fun {
    case is MalFun:
        return (fun as MalFun).fn(args)
    default:
    println((fun as MalError).value)
        return MalError(value: "First item in list is not a function")
    }
}

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
        
    case is MalInt:
        ast
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
    default: return ast;
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



// TODO: add Vec for let*

func eval(ast: MalType, env: Env) -> MalType {
    switch ast {
    case is MalList:
        var items = (ast as MalList).items
        // check for special forms
        if items.count > 0 {
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
                return eval(items[2], newEnv)
            case "do":
                let c = items.count - 1
                for var i = 1; i < c; ++i {
                    evalAst(items[i], env)
                }
                return evalAst(items[c], env)
            case "if":
                let cond = (eval(items[1], env))
                switch cond {
                case is MalNil:
                    return items.count > 3 ? (eval(items[3], env)) : MalNil()
                case is MalBool:
                    if (cond as MalBool).value == false {
                        return items.count > 3 ? (eval(items[3], env)) : MalNil()
                    } else {return (eval(items[2], env))
                    }
                default:
                    return (eval(items[2], env))}
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
                return MalFun(fn: {(args:MalList) -> MalType in
                    let vals = args.items
                    var newEnv = Env().outer(env)
                    for var i = 0; i < args.items.count; i++  {
                        if (syms[i] as MalSymbol).value == "&" {
                            let end = vals.count - 1
                            let rest = Array(vals[i...end]).map {eval( $0, env)}
                            newEnv.set((syms[i+1] as MalSymbol).value, v: MalList(items:rest))
                            i = args.items.count
                        } else {
                            newEnv.set((syms[i] as MalSymbol).value, v: eval(vals[i], env))
                        }
                    }
                    return eval(body, newEnv)})
            default:
                // otherwise apply first argument as function
                let temp = evalAst(ast, env)
                return apply(evalAst(ast, env) as MalList)
            }
        default:
            return apply(evalAst(ast,  env) as MalList)
            }} else {return MalList(items: [])}
    default:
        return evalAst(ast,  env)
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
        println(args)
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
        let lst = x.items.map {printString($0, printReadably: false)}
        return MalStr(value: "".join(lst))}),
    "prn": MalFun({(x: MalList) -> MalNil in
        let lst = x.items.map {printString($0)}
        println(" ".join(lst))
        return MalNil()}),
    "println": MalFun({(x: MalList) -> MalNil in
        let lst = x.items.map {printString($0, printReadably: false)}
        println(" ".join(lst))
        return MalNil()}),
   "read-string": MalFun({(x: MalList) -> MalType in
        return malReadString(x.first() as MalStr)}),
    "slurp": MalFun({(x: MalList) -> MalType in
        let file = "~/Developer/mal/tests/"  + (x.first() as MalStr).value
        let location = file.stringByExpandingTildeInPath
        if let contents = NSString(contentsOfFile: location, encoding: NSUTF8StringEncoding, error: nil) {
        let contents1 = contents.stringByReplacingOccurrencesOfString("\n", withString: "")
     //   let string = contents1.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
       // let string1 = string[string.startIndex..<string.endIndex.predecessor()]
        return MalStr(value: contents1.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
        } else {
            println("Erro Loading file at " + location)
            return MalError(value: "Error loading contents of file")
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
replEnv.set("eval", v: MalFun({(x: MalList) -> MalType in
        return eval(x, replEnv)}) )


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

func rep(s: String) {
    printString(eval(readString(s), replEnv))
}

// FIX: Currently Broken -- will not concate or something
 rep("(def! load-file (fn* (f) (eval (read-string (str \"(do \"(slurp f)\")\")))))")
// rep("(load-file \"incA.mal\")")

 rep("(eval (read-string (slurp  \"incA.mal\")))")

func slurp() -> String {
       let file = "~/Developer/mal/tests/incA.mal" 
       println("Slurp Print")
        let location = file.stringByExpandingTildeInPath
        if let contents = NSString(contentsOfFile: location, encoding: NSUTF8StringEncoding, error: nil) {
        let contents1 = contents.stringByReplacingOccurrencesOfString("\n", withString: "")
        println(contents1)
        return  contents1.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
      //  return string[string.startIndex..<string.endIndex.predecessor()]
        }
        return "Wrongo slurp"
}

// rep(slurp())

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
   rep()
}


