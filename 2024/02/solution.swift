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

let parseLine: (String) -> [Int] = { line in
  line
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .components(separatedBy: .whitespaces)
    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    .compactMap(Int.init)
}

let filterEmptyLines: ([String]) -> [String] = { lines in
  lines.filter { $0.isEmpty == false }
}

let isSafeLevel: ([Int]) -> Bool = { levels in
  let levelDifferences: [Int] = {
    var prev = levels.first!
    return
      levels
      .dropFirst()
      .reduce(into: []) { partial, current in
        let x = abs(current - prev)
        prev = current
        partial.append(x)
      }
  }()

  let allLevelsIncreaseOrDecrease: ([Int]) -> Bool = { levels in
    guard levels.count > 2 else { return false }
    let first = levels[0]
    let second = levels[1]
    let isIncreasing = second > first
    var prev = levels.first!
    return
      levels
      .dropFirst()
      .allSatisfy { level in
        let currentLevelIncreasing = level > prev
        prev = level
        return isIncreasing == currentLevelIncreasing
      }
  }

  let allDifferencesAreInRange: ([Int]) -> Bool = { differences in
    differences.allSatisfy {
      (1...3) ~= $0
    }
  }

  return allLevelsIncreaseOrDecrease(levels)
    && allDifferencesAreInRange(levelDifferences)
}

let isSafeLevel2: ([Int]) -> Bool = { levels in
  if isSafeLevel(levels) {
    return true
  }

  for index in (0..<levels.count) {
    var adjustedLevels = levels
    adjustedLevels.remove(at: index)
    if isSafeLevel(adjustedLevels) {
      return true
    }
  }
  return false
}

let solve1 =
  readFile
  >>> lines
  >>> filterEmptyLines
  >>> { $0.map(parseLine) }
  >>> { $0.map(isSafeLevel) }
  >>> { $0.filter(identity) }
  >>> { $0.count }

let solve2 =
  readFile
  >>> lines
  >>> filterEmptyLines
  >>> { $0.map(parseLine) }
  >>> { $0.map(isSafeLevel2) }
  >>> { $0.filter(identity) }
  >>> { $0.count }

solve1("sample.txt") |> output
solve1("input.txt") |> output
solve2("sample.txt") |> output
solve2("input.txt") |> output
