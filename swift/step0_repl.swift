import Foundation


func prompt() -> String {
    print("-> ");
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
 println("MAL repl ");
    while true {
    print(PRINT(EVAL(READ(prompt()))));
    }
}

rep();

