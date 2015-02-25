import Foundation
import types


class Reader {
    var tokens: [String];
    var position: Int;
    init (tokens: [String]) {
        self.position = 0;
        self.tokens = tokens;
    }
    
    func next() -> String? {
        let x = peek();
        position = position + 1;
        return x;
    }
    
    func peek() -> String? {
        if position == tokens.count {
            return nil;
        } else {
        return tokens[position];
        }
    }
}


func tokenize(s: String) -> [String] {
    let pattern = "[\\s ,]*(~@|[\\[\\]{}()'`~@]|\"(?:[\\\\].|[^\\\\\"])*\"|;.*|[^\\s \\[\\]{}()'\"`~@,;]*)"
    let regex = NSRegularExpression(pattern: pattern, options: .allZeros, error: nil)
    let range = NSMakeRange(0, countElements(s))
    let matches = regex?.matchesInString(s, options: .allZeros, range: range) as [NSTextCheckingResult]
    
    return matches.map {
        let range = $0.range
        return (s as NSString).substringWithRange(range)
    }
}

func read_list(reader: Reader) {
    
}

func read_form(reader: Reader) -> MalT {
    switch reader.peek() as String! {
    case "(":
        read_list(reader)
    default:
        read_form(reader)
    }
}

func read_str(s:String) {
    let coll = tokenize(s);
    let reader = Reader(tokens: coll);
    read_form(reader);
}

class MalType {
    
}

class MalList<T> : MalType {
    var items = [T]()
    func push(item: T) {
        items.append(item)
    }
    func pop() -> T {
        return items.removeLast()
    }
}

// read_str("(col)")class Reader {
    var tokens: [String];
    var position: Int;
    init (tokens: [String]) {
        self.position = 0;
        self.tokens = tokens;
    }
    
    func next() -> String? {
        let x = peek();
        position = position + 1;
        return x;
    }
    
    func peek() -> String? {
        if position == tokens.count {
            return nil;
        } else {
        return tokens[position];
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

func read_atom(reader: Reader) -> MalType {
    var token = reader.next();
    var num_regex = "(^-?[0-9]+$)|(^-?[0-9][0-9.]*$"
    var match = regex(num_regex, token!)
    switch match[0] {
    case: return MalInt(token?.toInt()!)
    }
}

func read_list(reader: Reader) -> MalType {
    var ast:MalList;
    
    while reader.peek() != ")" {
        ast.push(read_atom(reader));
    }
    
    return ast;
}

func read_form(reader: Reader) -> MalType {
    switch reader.peek() as String! {
    case "(":
        read_list(reader)
    default:
        read_form(reader)
    }
    
}

func read_str(s:String) {
    let coll = tokenize(s);
    let reader = Reader(tokens: coll);
    read_form(reader);
}
