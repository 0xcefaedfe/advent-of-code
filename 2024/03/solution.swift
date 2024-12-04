import Foundation

infix operator |> : MultiplicationPrecedence
infix operator >>> : MultiplicationPrecedence

func identity<A>(_ v: A) -> A {
  v
}

func |> <A, B>(a: A, f: (A) -> B) -> B {
  f(a)
}

func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
  { a in g(f(a)) }
}

let readFile = { filename in
  try! String(contentsOfFile: filename)
}

let lines: (String) -> [String] = { input in
  input.components(separatedBy: .newlines)
}

let output: (Any) -> Void = { print($0) }

let filterEmptyLines: ([String]) -> [String] = { lines in
  lines.filter { $0.isEmpty == false }
}

typealias Instruction = [Int]

let parseInstructions: (String) -> [Instruction] = { text in
  let regex = try! NSRegularExpression(pattern: "mul\\([0-9]+,[0-9]+\\)")
  let matches = regex.matches(in: text, range: NSRange(location: 0, length: text.count))
  return matches.map { match in
    (text as NSString).substring(with: match.range)
      .replacing("mul(", with: "")
      .replacing(")", with: "")
      .components(separatedBy: ",")
      .compactMap(Int.init)
  }
}

let eval: (Instruction) -> Int = { instruction in
  instruction.reduce(1, *)
}

let preProcess: (String) -> String = { text in
  var isInDoPart = true
  var temp = ""
  var result = ""

  for ch in text {
    temp.append(ch)
    if temp.hasSuffix("do()") {
      isInDoPart = true
      temp = ""
    } else if temp.hasSuffix("don't()") {
      isInDoPart = false
      temp = ""
    }
    if isInDoPart {
      result.append(ch)
    }
  }
  return result
}

let solve1 =
  readFile
  >>> parseInstructions
  >>> { $0.map(eval) }
  >>> { $0.reduce(0, +) }

let solve2 =
  readFile
  >>> preProcess
  >>> parseInstructions
  >>> { $0.map(eval) }
  >>> { $0.reduce(0, +) }

solve1("sample.txt") |> output
solve1("input.txt") |> output
solve2("sample1.txt") |> output
solve2("input.txt") |> output
