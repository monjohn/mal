import Foundation

class Env: MalType {
    var outer:  Env?
    var data = [String:MalType]()

    func bind(binds:[MalType], exprs:[MalType]) {
        for (index, binding) in enumerate(binds) {
            let k = (binding as MalSymbol).value
            if k == "&" {
                let end = exprs.count - 1
         //       let rest = Array(exprs[index...end])
        //     set(k, v: MalList(items: rest))
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

class Cell: MalType {
    let value: MalType? = nil
    var next: Cell? = nil

    override init() {
    }
    init(value: MalType) {
        self.value = value
    }
    init(value: MalType, next: Cell?) {
        self.value = value
        self.next = next
    }
}

class MalList: MalType, SequenceType {
    var count: Int = 0
    var head: Cell? = nil

    override init() {}
    init(head: Cell) {
        self.head = head
    }

    func isEmpty() -> Bool {
        if let h = head  {
            return true
        } else {
            return false
        }
    }

    func cons(value: MalType) -> MalList {
        let cell = Cell(value: value, next: head)
        head = cell
        count++
        return self
    }

    // Returns value of first cell or MalNil
    func peek() -> MalType {
        if let v = head?.value {
            return v
        } else {
            return MalNil()
        }
    }
    // Returns value of second cell or MalNil
    func secondV() -> MalType {
        if let v = head?.next?.value {
            return v
        } else {
            return MalNil()
        }
    }

    func pop() -> MalType? {
        let temp = head
        if let v = head?.value {
            head = head!.next
            count--
            return v
        } else {
            return nil
        }
    }

//    func peek() -> MalType? {
//        if let t = head {
//            return t.value
//        } else {
//            return nil
//        }
//    }

    func rest() -> MalList? {
        if let t = head?.next {
            let tail = self
            tail.pop()
            return tail
        } else {
            return nil
        }
    }

    func generate() -> GeneratorOf<MalType> {
        // Duplicate list
        var coll = MalList(head: self.head!)
        return GeneratorOf<MalType> {
            return coll.pop()
        }
    }

    func nth(n:Int) -> MalList {
        var list = self
        for var x = 0; x < n; x++ {
            if let h = list.head {
                list.pop()
            }

        }
        return list
    }

    func reverseHelper(oldL: MalList, newL: MalList) -> MalList {
        if let cell = oldL.head {
            oldL.pop()
            return reverseHelper(oldL, newL: newL.cons(cell.value!))
        } else {
            return newL
        }
    }

    func reverse() -> MalList {
        var copy = MalList(head: self.head!)
        return reverseHelper(copy, newL: MalList())
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

func listToArray(list: MalList) -> [MalType] {
    var array = [MalType]()
    for item in list {
        array.append(item)
    }
    return array
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
    var result:[String] = []
    for i in list {
        result.append(printString(i))    }
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
        var accumlator = MalList()
        for i in (t as MalList) {
            accumlator.cons(checkForError(i))
        }
        return accumlator.reverse()
    case is MalVec:
        accumlator = MalVec(items: [])
        for i in (t as MalList) {
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
        } else if s.hasPrefix(";") {
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
    var ast = MalList()
    reader.next();
    while reader.peek() != end {
        if let p = reader.peek() {
            ast.cons(readForm(reader));
        } else {
            return MalError(value: "expected '\(end)', got EOF")
        }
    }
    reader.next()
    return ast.reverse();
}

func listToDict(list:MalList) -> MalType {
    func even(x:Int) -> Bool {
        return x % 2 == 0
    }
    //   let items = list.items
    if list.count % 2 == 0 {
        var keys = [String]()
        var values = [MalType]()
        var dict = [String: MalType]()
        var ind:Int = 0
        for item in list {
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


//func readVec(reader: Reader) -> MalType {
//    var list = readList(reader, start: "[", end: "]")
//    if list is MalList {
//        return MalVec(items: (list as MalList).items)
//    } else {
//        return list
//    }
//}

func readVec(reader: Reader) -> MalType {
    var ast = MalVec(items:[]);
    reader.next();
    while reader.peek() != "]" {
        if let p = reader.peek() {
            ast.push(readForm(reader));
        } else {
            return MalError(value: "expected ']', got EOF")
        }
    }
    reader.next()
    return ast
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
    let reader = Reader(tokens: coll);
    return readForm(reader);
}


func malReadString(s:MalStr) -> MalType {
    return readString(s.value)
}

// MARK: -------------- Eval -------------------


func apply(list: MalList) -> MalType {
    let fun = list.peek()
    switch fun {
    case is MalFun:
        if let args = list.rest() {
        return (fun as MalFun).fn(args)
        } else {
            return MalError(value: "No args found in apply")
        }
    default:
        //  println((fun as MalInt).value)
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
        return ast
    case is MalSymbol:
        if let sym = env.get((ast as MalSymbol).value) {
            return sym
        } else {
            let msg = "'" + (ast as MalSymbol).value + "' not found."
            println(msg)
            return MalError(value: msg)
        }
    case is MalDict:
        return evalDict(ast as MalDict, env)
    case is MalVec:
        return MalVec(items: (ast as MalVec).items.map
            {eval($0,env)})
    case is MalList:
        var newList = MalList()
        (ast as MalList).count
        for i in (ast as MalList) {
            print("EvalAst: ")
            println(i)
            i
            newList.cons(eval(i, env))
        }
        newList.reverse().peek()
        return newList.reverse()
    default:
        return ast;
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


func isPair(ast: MalType) -> Bool {
    switch ast {
    case is MalList:
        return (ast as MalList).isEmpty()
    case is MalVec:
        return (ast as MalVec).items.isEmpty
    default:
        return false
    }
}

func quasiquote(ast: MalType) -> MalType {
    if (!isPair(ast)) {
        return MalList().cons(ast).cons(MalSymbol(value: "quote"))
    }

    if ((ast as MalList).peek() as MalSymbol).value == "unquote" {
        return (ast as MalList).secondV()
    }

    let f = (ast as MalList).peek() as MalList

    if (isPair(f) && (f.peek() as MalSymbol).value == "splice-unquote")  {
      //  return MalList().cons(MalSymbol(value: "concat"));
        (ast as MalList).count
        (ast as MalList).pop()
        (ast as MalList).count
        let rest = quasiquote(ast)
        return MalList().cons(rest).cons((f as MalList).secondV()).cons(MalSymbol(value: "concat"))
    }
    (ast as MalList).count
    (ast as MalList).pop()
    (ast as MalList).count
    let rest = quasiquote(ast)
    return MalList().cons(quasiquote(f)).cons(MalSymbol(value: "cons"))
}

// TODO: add Vec for let*

func eval(ast: MalType, env: Env) -> MalType {
    print("EVAL: ")
    println(ast)
 //   var ast = ast
 //   var env = env
    switch ast {
    case is MalList:
        // check for special forms
        let fst = (ast as MalList).peek()
        switch fst {
            case is MalSymbol:
                let snd = (ast as MalList).secondV()
                let rest = (ast as MalList).nth(2)

                switch (fst as MalSymbol).value {
                case "def!":
                    return env.set((fst as MalSymbol).value,
                        v: eval(rest , env))
                case "let*":
                    var newEnv = Env().outer(env)
                    let bindings = snd as MalVec
                    newEnv = createLetEnv(bindings, newEnv)
                    rest.peek()
                    return eval(rest, newEnv)
                case "do":
                    let c = (ast as MalList).count - 1
                    let newList = (ast as MalList).rest()!
                    for var i = 1; i < c; i++ {
                        if let h = newList.head!.value {
                            eval(h, env)
                            newList.pop()
                        }}
                    return evalAst(newList.peek(), env)
                case "if":
                    let cond = (eval(snd, env))
                    switch cond {
                    case is MalNil:
                        return rest.count > 3 ? (eval(rest.head!.value!, env)) : MalNil()
                    case is MalBool:
                        if (cond as MalBool).value == false {
                            return rest.count > 3 ? (eval(rest.secondV(), env)) : MalNil()
                        } else {return (eval(rest.peek(), env))
                        }
                    default:
                        return (eval(rest.peek(), env))}
                case "quote":
                    return snd
                    case "quasiquote":
                    return quasiquote(snd)

                case "fn*":
                    var syms = [MalType]()
                    switch snd {
                    case is MalList:
                        syms = listToArray(snd as MalList)
                    case is MalVec:
                        syms = (snd as MalVec).items
                    default:
                        return MalError(value: "Second element not list or vector")
                    }
                    let body = rest
                    return MalFun(fn: {(vals:MalList) -> MalType in
                        let c = vals.count
                        var newEnv = Env().outer(env)
                        var newList = MalList()
                        for var i = 0; i < vals.count; i++  {
                            if (syms[i] as MalSymbol).value == "&" {
                                let end = vals.count - 1
                                var rest = MalList()
                                do {
                                    rest.cons(eval(vals.peek(), env))
                                } while vals.count > 1

                        //      let rest = Array(valsArray[i...end]).map {eval( $0, env)}

                                newEnv.set((syms[i+1] as MalSymbol).value, v: rest)
                            } else {
                                newEnv.set((syms[i] as MalSymbol).value, v: eval(vals.peek(), env))
                            }
                        }
                        return eval(body, newEnv)})
                default:
                    // otherwise apply first argument as function
                    fst
                    let result = evalAst(ast, env)
                    println((result as MalList).secondV())
                    (result as MalList).peek()
                    return apply(evalAst(ast, env) as MalList)
                }

            default:
                // FIX: Why does get called??
                (ast as MalList).peek()
                return evalAst(ast,  env)
            }
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
            let l1 =  MalList(head: (x as MalList).head!)
            let l2 =  MalList(head: (y as MalList).head!)
            if l1.count == l2.count {
                do {
                    let h1 = l1.peek()
                    let h2 = l2.peek()
                    let boo = equals(h1, h2)
                    if boo.value == false {
                        return MalBool(value: false)
                    }
                } while l1.count > 0
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
    "cons": MalFun(fn: { (args:MalList) -> MalType in
        return (args.secondV() as MalList).cons(args.peek())
    }),
    "concat": MalFun(fn: { (args:MalList) -> MalType in
        var newList = MalList()
        for list in args {
            if list is MalList {
                for i in (list as MalList) {
                    newList.cons(i)
                }
            }
        }
        return newList.reverse()
    }),
    "+": MalFun(fn: { (args:MalList) -> MalType in
        return MalInt(value:((args.peek() as MalInt).value + (args.secondV() as MalInt).value))}),
    "-": MalFun(fn: { (args:MalList) -> MalType in
        return MalInt(value:((args.peek() as MalInt).value - (args.secondV() as MalInt).value))}),
    "*": MalFun(fn: { (args:MalList) -> MalType in
        return MalInt(value:((args.peek() as MalInt).value * (args.secondV() as MalInt).value))}),
    "/": MalFun(fn: { (args:MalList) -> MalType in
        return MalInt(value:((args.peek() as MalInt).value / (args.secondV() as MalInt).value))}),
    "list": MalFun(fn: {(args: MalList) -> MalList in
        var newList = MalList()
        for i in args {
            newList.cons(i) }
        return newList}),
    "list?": MalFun(fn: {(x: MalList) -> MalBool in return x.peek() is MalList ? MalBool(value: true) : MalBool(value: false)}),
    "empty?": MalFun(fn: {(x: MalList) -> MalType in
        let fst = x.peek()
        switch fst {
        case is MalList:
            return (fst as MalList).count == 0 ? MalBool(value: true) : MalBool(value: false)
        case is MalVec:
            return ((fst as MalVec).count() as MalInt).value == 0 ? MalBool(value: true) : MalBool(value: false)
        default:
            return MalError(value: "Not a collection")}}),
    "count": MalFun(fn: {(x: MalList) -> MalInt in
        let fst = x.peek()
        if fst is MalList {
            return MalInt(value:(fst as MalList).count)
        } else if fst is MalVec{
            return (fst as MalVec).count()
        } else {return MalInt(value: 0)} }),
    "=": MalFun({(x: MalList) -> MalBool in
        return equals(x.peek(), x.secondV())}),
    "<": MalFun({(x: MalList) -> MalBool in
        return MalBool(value: (x.peek() as MalInt).value < (x.secondV() as MalInt).value)}),
    ">": MalFun({(x: MalList) -> MalBool in
        return MalBool(value: (x.peek() as MalInt).value > (x.secondV() as MalInt).value)}),
    "<=": MalFun({(x: MalList) -> MalBool in
        return MalBool(value: (x.peek() as MalInt).value <= (x.secondV() as MalInt).value)}),
    ">=": MalFun({(x: MalList) -> MalBool in
        return MalBool(value: (x.peek() as MalInt).value >= (x.secondV() as MalInt).value)}),
    "pr-str": MalFun({(x: MalList) -> MalStr in
        var array = [String]()
        for i in x {
            array.append( printString(i, printReadably: true) )
        }
        return MalStr(value: " ".join(array))}),
    "str": MalFun({(x: MalList) -> MalStr in
        var array = [String]()
        for i in x {
            array.append( printString(i, printReadably: false) )
        }
        return MalStr(value: " ".join(array))}),
    "prn": MalFun({(x: MalList) -> MalNil in
        var array = [String]()
        for i in x {
            array.append( printString(i, printReadably: true) )
        }
        println(" ".join(array))
        return MalNil()}),
    "println": MalFun({(x: MalList) -> MalNil in
        var array = [String]()
        for i in x {
            array.append( printString(i, printReadably: false) )
        }

        println(" ".join(array))
        return MalNil()}),
    "read-string": MalFun({(x: MalList) -> MalType in
        switch x.peek() {
        case is MalStr:
            let s = (x.peek() as MalStr).value
            return malReadString(x.peek() as MalStr)
        case is MalError:
            println((x.peek() as MalError).value)
            return x.peek()
        default:
            return MalError(value: "read-string takes a string")}}),
    "slurp": MalFun({(x: MalList) -> MalType in
        let file = "~/Developer/mal/swift/" +  printString(x.peek() as MalStr)
        println(file)
        let location = file.stringByExpandingTildeInPath
        if let contents = NSString(contentsOfFile: location, encoding: NSUTF8StringEncoding, error: nil) {
            return MalStr(value: contents.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
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

// add eval
replEnv.set("eval", v: MalFun({(x: MalType) -> MalType in
    return eval(x, replEnv)}) )


func prompt() -> String {
    var keyboard = NSFileHandle.fileHandleWithStandardInput()
    var inputData = keyboard.availableData
    return NSString(data: inputData, encoding:NSUTF8StringEncoding)!
}

func slurp() -> String {
    let file = "~/Developer/mal/tests/incA.mal"
    let location = file.stringByExpandingTildeInPath
    if let contents = NSString(contentsOfFile: location, encoding: NSUTF8StringEncoding, error: nil) {
        return contents.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    return "Wrongo slurp"
}


func rep() -> String {
    println("user> ");
    while true {
        var s = printString(eval(readString(prompt()), replEnv))
        println( "=>" + s)
    }
    return "Goodbye"
}

func rep(s: String) -> String {
    return printString(eval(readString(s), replEnv))
}


// FIX: Currently Broken due to finding empty Strings
// rep("(def! load-file (fn* (f) (eval (read-string (str \"(do \"(slurp f)\")\")))))")




// rep("(eval (read-string \"(+ 1 1)\" ))")
//rep("(def! resolve (fn* [exp] (eval (read-string (str \"(do \" exp \")\")))))")
//rep("(resolve \"(* 2 2)\" )")

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

  //  replEnv.set("*ARGV*", v: MalList(items:args))
    file = "(load-file " + file + ")"
    println(file)
    rep(file);
    // Process(kill);
} else {
    // rep()
}
rep("(let* [a 2] (+ 1 a))")
//rep("(+ 1  2)")

//var mylist = MalList()
//let n1 = MalInt(value: 1)
//let n2 = MalInt(value: 2)
//let n3 = MalInt(value: 3)
//mylist.cons(n1).cons(n2).cons(n3);
//let p = mylist.nth(2).peek()
//(p as MalInt).value
//

