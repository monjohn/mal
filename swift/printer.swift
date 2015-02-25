import Foundation
import types

func print_list(list: MalList) -> String {
    let items = list.items;
    var result: String = "(";
    for i in items {
        result = result + " " + pr_str(i);
    }
    return result + ")";
}

func pr_str (t:MalType) -> String {
    switch t {
    case is MalInt:
        return toString((t as MalInt ).value)
    case is MalNil:
        return "nil"
    case is MalStr:
        return (t as MalStr).value
    case is MalList:
        return print_list(t as MalList)
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

