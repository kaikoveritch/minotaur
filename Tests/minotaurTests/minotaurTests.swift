import XCTest
import LogicKit
@testable import minotaur

struct Wrapper : Equatable, CustomStringConvertible {
  let term : Term

  var description: String {
      return "\(self.term)"
  }

  static func ==(lhs: Wrapper, rhs: Wrapper) -> Bool {
    return (lhs.term).equals (rhs.term)
  }

}

func resultsOf (goal: Goal, variables: [Variable]) -> [[Variable: Wrapper]] {
    var result = [[Variable: Wrapper]] ()
    for s in solve (goal) {
        let solution  = s.reified ()
        var subresult = [Variable: Wrapper] ()
        for v in variables {
            subresult [v] = Wrapper (term: solution [v])
        }
        if !result.contains (where: { x in x == subresult }) {
            result.append (subresult)
        }
    }
    return result
}

class minotaurTests: XCTestCase {

   // This is solely to make reading the results easier
   func startTests(){
      print("\nStarting tests...\n")
      print("\nPre-defined tests:\n")
   }

    func testDoors() {
        let from = Variable (named: "from")
        let to   = Variable (named: "to")
        let goal = doors (from: from, to: to)
        XCTAssertEqual(resultsOf (goal: goal, variables: [from, to]).count, 18, "number of doors is incorrect")
    }

    func testEntrance() {
        let location = Variable (named: "location")
        let goal     = entrance (location: location)
        XCTAssertEqual(resultsOf (goal: goal, variables: [location]).count, 2, "number of entrances is incorrect")
    }

    func testExit() {
        let location = Variable (named: "location")
        let goal     = exit (location: location)
        XCTAssertEqual(resultsOf (goal: goal, variables: [location]).count, 2, "number of exits is incorrect")
    }

    func testMinotaur() {
        let location = Variable (named: "location")
        let goal     = minotaur (location: location)
        XCTAssertEqual(resultsOf (goal: goal, variables: [location]).count, 1, "number of minotaurs is incorrect")
    }

    func testPath() {
        let through = Variable (named: "through")
        let goal    = path (from: room (4,4), to: room (3,2), through: through)
        XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 2, "number of paths is incorrect")
    }

    func testBattery() {
        let through = Variable (named: "through")
        let goal    = path (from: room (4,4), to: room (3,2), through: through) &&
                      battery (through: through, level: toNat (7))
        XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 1, "number of paths is incorrect")
    }

    func testLosing() {
        let through = Variable (named: "through")
        let goal    = winning (through: through, level: toNat (6))
        XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 0, "number of paths is incorrect")
    }

    func testWinning() {
        let through = Variable (named: "through")
        let goal    = winning (through: through, level: toNat (7))
        XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 1, "number of paths is incorrect")
    }

//==============================================================================
// * Added tests *
//==============================================================================

   // This is solely to make reading the results easier
   func startAddedTests(){
      print("\nAdded tests...\n")
   }

   // Additional path tests
   func testALotOfPaths() {
      print("\nTesting paths:\n")

      let through = Variable (named: "through")

      // Paths (2,1) -> (4,1)
      print("Paths (2,1) -> (4,1)")
      var goal = path (from: room (2,1), to: room (4,1), through: through)
      XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 0, "number of paths is incorrect")

      // Paths (1,4) -> (1,1)
      print("Paths (1,4) -> (1,1)")
      goal = path (from: room (1,4), to: room (1,1), through: through)
      XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 2, "number of paths is incorrect")

      // Paths (4,2) -> (1,1)
      print("Paths (4,1) -> (1,1)")
      goal = path (from: room (4,2), to: room (1,1), through: through)
      XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 1, "number of paths is incorrect")

      // Paths (4,4) -> (3,3)
      print("Paths (4,4) -> (3,3)")
      goal = path (from: room (4,4), to: room (3,3), through: through)
      XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 3, "number of paths is incorrect")

      print("\n")
   }

   // Additional battery tests
   func testALotOfBattery() {

      print("\nTesting battery:\n")

      let through = Variable (named: "through")

      // Paths (1,4) -> (1,1) with 7 battery level
      print("Paths (1,4) -> (1,1) with 7 battery level")
      var goal = path (from: room (1,4), to: room (1,1), through: through) &&
                     battery (through: through, level: toNat (7))
      XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 1, "number of paths is incorrect")

      // Paths (1,4) -> (1,1) with 3 battery level
      print("Paths (1,4) -> (1,1) with 3 battery level")
      goal = path (from: room (1,4), to: room (1,1), through: through) &&
                     battery (through: through, level: toNat (3))
      XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 0, "number of paths is incorrect")

      // Paths (4,4) -> (3,3) with 9 battery level
      print("Paths (4,4) -> (3,3) with 9 battery level")
      goal = path (from: room (4,4), to: room (3,3), through: through) &&
                     battery (through: through, level: toNat (9))
      XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 3, "number of paths is incorrect")

      // Paths (4,4) -> (3,3) with 8 battery level
      print("Paths (4,4) -> (3,3) with 8 battery level")
      goal = path (from: room (4,4), to: room (3,3), through: through) &&
                     battery (through: through, level: toNat (8))
      XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 2, "number of paths is incorrect")

      // Paths (4,4) -> (3,3) with 5 battery level
      print("Paths (4,4) -> (3,3) with 5 battery level")
      goal = path (from: room (4,4), to: room (3,3), through: through) &&
                     battery (through: through, level: toNat (5))
      XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 1, "number of paths is incorrect")

      print("\n")
   }

   // Additional loss tests
   func testALotOfLosing() {

      print("\nTesting losses:\n")

      let through = Variable (named: "through")

      // Loss with 0 battery level
      print("Loss with 0 battery level")
      var goal = winning (through: through, level: toNat (0))
      XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 0, "number of paths is incorrect")

      // Loss with 3 battery level
      print("Loss with 3 battery level")
      goal = winning (through: through, level: toNat (3))
      XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 0, "number of paths is incorrect")

      // Loss with 4 battery level
      print("Loss with 4 battery level")
      goal = winning (through: through, level: toNat (4))
      XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 0, "number of paths is incorrect")

      print("\n")
   }

   // Additional win tests
   func testALotOfWinning() {

      print("\nTesting wins:\n")

      let through = Variable (named: "through")

      // Win with 8 battery level
      print("Win with 8 battery level")
      var goal = winning (through: through, level: toNat (8))
      XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 2, "number of paths is incorrect")

      // Win with 9 battery level
      print("Win with 9 battery level")
      goal = winning (through: through, level: toNat (9))
      XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 2, "number of paths is incorrect")

      // Win with 10 battery level
      print("Win with 10 battery level")
      goal = winning (through: through, level: toNat (10))
      XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 4, "number of paths is incorrect")

      print("\n")
   }

   // Tests the actual path for a fixed level of battery, by displaying it
   func whatHappens() {
      print("\nDisplaying the composition of the path(s) with 7 of battery level:\n")
      let through = Variable (named: "through")
      let goal    = winning (through: through, level: toNat (7))
      print("The solutions for 7 battery power are:")
      for sol in solve(goal) {
         let reified = sol.reified()
         print("* \(reified[through])")
      }
      print("\n")
   }

   // This is solely to make reading the results easier
   func endTests() {
      print("\nEnd of tests\n")
   }


    static var allTests : [(String, (minotaurTests) -> () throws -> Void)] {
        return [
            ("startTests", startTests),
            ("testDoors", testDoors),
            ("testEntrance", testEntrance),
            ("testExit", testExit),
            ("testMinotaur", testMinotaur),
            ("testPath", testPath),
            ("testBattery", testBattery),
            ("testLosing", testLosing),
            ("testWinning", testWinning),
            ("startAddedTests", startAddedTests),
            ("testALotOfPaths", testALotOfPaths),
            ("testALotOfBattery", testALotOfBattery),
            ("testALotOfLosing", testALotOfLosing),
            ("testALotOfWinning", testALotOfWinning),
            ("whatHappens", whatHappens),
            ("endTests", endTests),
        ]
    }
}
