import Foundation

class MalType {
}

class MalBool: MalType {
    let value: String;
    init(value:String) {
        self.value = value
    }
}

class MalError: MalType {
    let value: String;
    init(value: String) {
        self.value = value
    }
}

class MalInt: MalType {
    let value: Int;
    init(value: Int) {
        self.value = value
    }
}

class MalList: MalType {
    var items = [MalType]()
    func push(item: MalType) {
        items.append(item)
    }
    func pop() -> MalType {
        return items.removeLast()
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



func printList(list: MalList) -> String {
    let items = list.items;
    var result:[String] = []
    for i in items {
        result.append(printString(i))
    }
    return "(" + (" ".join(result)) + ")"
}

func printString (t:MalType) -> String {
    switch t {
    case is MalInt:
        return toString((t as MalInt ).value)
    case is MalNil:
        return "nil"
    case is MalStr:
        return (t as MalStr).value
    case is MalList:
        return printList(t as MalList)
    case is MalError:
        return (t as MalError).value
    case is MalNil:
        return "nil"
    case is MalBool:
        return (t as MalBool).value
    default:
        return "Error: Cannot pr_str"
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


func regex(p:String, s:String) -> [String] {
    let regex = NSRegularExpression(pattern: p, options: .allZeros, error: nil)
    let range = NSMakeRange(0, countElements(s))
    let matches = regex?.matchesInString(s, options: .allZeros, range: range) as [NSTextCheckingResult]
    return matches.map {
        let range = $0.range
        return (s as NSString).substringWithRange(range)
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
        } else {
            return MalStr(value: s)
        }
    } else {
        return MalError(value: "No type found")
    }
}



func readForm(reader: Reader) -> MalType {
    func readList(reader: Reader, start: String = "(", end: String = ")")
        -> MalType {
        var ast = MalList();
        reader.next();
        while reader.peek() != end {
            ast.push(readForm(reader));
        }
        reader.next();
        return ast;
    }
    switch reader.peek() as String! {
    case "(":
        return readList(reader)
    case ")":
        return MalError(value: "Unexpected ')'")
    case "[":
        return readList(reader, start: "[", end: "]")
    case "]":
        return MalError(value: "Unexpected ']'")
    default:
       return readAtom(reader)
    }
}

func readString(s:String) -> MalType {
    let coll = tokenize(s);
    let reader = Reader(tokens: coll);
    return readForm(reader);
}


func prompt() -> String {
    var keyboard = NSFileHandle.fileHandleWithStandardInput()
    var inputData = keyboard.availableData
    return NSString(data: inputData, encoding:NSUTF8StringEncoding)!
}


func EVAL (m: MalType) -> MalType {
    return m;
}


func rep() {
    println("user> ");
    while true {
        var s = printString(EVAL(readString(prompt())))
        //  s = s.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        println( "=>" + s)
    }
}


rep()




