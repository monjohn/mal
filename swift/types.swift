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
