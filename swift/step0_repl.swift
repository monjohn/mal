import Foundation


func prompt() -> String {
    println("user> ");
    var keyboard = NSFileHandle.fileHandleWithStandardInput()
    var inputData = keyboard.availableData
    return NSString(data: inputData, encoding:NSUTF8StringEncoding)!
}

func READ (s: String) -> String {
     return s;
}

func EVAL (ast: String) -> String {
    return ast;
}

func PRINT (s: String) -> String {
    return s;
}

func rep () {
    while true {
    print(PRINT(EVAL(READ(prompt()))));
    }
}

rep();

