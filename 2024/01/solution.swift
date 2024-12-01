import Foundation

infix operator |> : MultiplicationPrecedence
infix operator >>> : MultiplicationPrecedence

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

let parseLine: (String) -> (Int, Int) = { line in
  line
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .replacingOccurrences(of: "  ", with: "\t")
    .components(separatedBy: "\t")
    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    |> { parts in
      (Int(parts.first!)!, Int(parts.last!)!)
    }
}

let splitLines: ([(Int, Int)]) -> ([Int], [Int]) = { lines in
  lines.reduce(into: ([], [])) { partial, next in
    partial.0.append(next.0)
    partial.1.append(next.1)
  }
}

let filterEmptyLines: ([String]) -> [String] = { lines in
  lines.filter { $0.isEmpty == false }
}

let lineDifference: (([Int], [Int])) -> Int = { lines in
  zip(lines.0, lines.1)
    .map { abs($0.0 - $0.1) }
    .reduce(0, +)
}

let similarityScore: (([Int], [Int])) -> Int = { lines in
  lines.0
    .map { x in
      x
        * lines.1
        .filter { $0 == x }
        .count
    }
    .reduce(0, +)
}

let solve1 =
  readFile
  >>> lines
  >>> filterEmptyLines
  >>> { $0.map(parseLine) }
  >>> splitLines
  >>> { ($0.0.sorted(), $0.1.sorted()) }
  >>> lineDifference

let solve2 =
  readFile
  >>> lines
  >>> filterEmptyLines
  >>> { $0.map(parseLine) }
  >>> splitLines
  >>> similarityScore

solve1("sample.txt") |> output
solve1("input.txt") |> output
solve2("sample.txt") |> output
solve2("input.txt") |> output
