import LogicKit

let zero = Value (0)

func succ (_ of: Term) -> Map {
    return ["succ": of]
}

func toNat (_ n : Int) -> Term {
    var result : Term = zero
    for _ in 0..<n {
        result = succ (result)
    }
    return result
}

struct Position : Equatable, CustomStringConvertible {
    let x : Int
    let y : Int

    var description: String {
        return "\(self.x):\(self.y)"
    }

    static func ==(lhs: Position, rhs: Position) -> Bool {
      return lhs.x == rhs.x && lhs.y == rhs.y
    }

}


// rooms are numbered:
// x:1,y:1 ... x:n,y:1
// ...             ...
// x:1,y:m ... x:n,y:m
func room (_ x: Int, _ y: Int) -> Term {
  return Value (Position (x: x, y: y))
}

// Finds rooms couples connected by a door (oriented)
func doors (from: Term, to: Term) -> Goal {
    return  (from === room(1,2) && to === room(1,1)) ||
            (from === room(1,2) && to === room(2,2)) ||
            (from === room(1,3) && to === room(1,2)) ||
            (from === room(1,4) && to === room(1,3)) ||
            (from === room(2,1) && to === room(1,1)) ||
            (from === room(2,2) && to === room(3,2)) ||
            (from === room(2,3) && to === room(2,2)) ||
            (from === room(2,3) && to === room(1,3)) ||
            (from === room(2,4) && to === room(2,3)) ||
            (from === room(3,1) && to === room(2,1)) ||
            (from === room(3,2) && to === room(3,3)) ||
            (from === room(3,2) && to === room(4,2)) ||
            (from === room(3,4) && to === room(2,4)) ||
            (from === room(3,4) && to === room(3,3)) ||
            (from === room(4,1) && to === room(3,1)) ||
            (from === room(4,2) && to === room(4,1)) ||
            (from === room(4,2) && to === room(4,3)) ||
            (from === room(4,4) && to === room(3,4))
}

// Finds rooms who are entrances to the labyrinth
func entrance (location: Term) -> Goal {
    return  (location === room(1,4)) || (location === room(4,4))
}

// Finds rooms who are exits of the labyrinth
func exit (location: Term) -> Goal {
    return  (location === room(1,1)) || (location === room(4,3))
}

// Finds rooms who contain a minotaur
func minotaur (location: Term) -> Goal {
    return (location === room(3,2))
}

// Recursive step to help with 'path' function
func path_rec (from: Term, to: Term, through: Term, subs: Term) -> Goal {
   return   // Either the two rooms tested are directly linked
            (doors(from: from, to: to) && (List.cons(to, subs) === through))
            ||
            // Or we recursively check for every adjacent room to the starting one if there is
            // a path to the target (while adding the 'from' room to the total path)
            (
               fresh{x in
                  doors(from: from, to: x) &&
                  delayed(path_rec(from: x, to: to, through: through, subs: List.cons(x, subs)))
               }
            )
}
// Links to rooms with a path (if possible), which is a list of rooms
func path (from: Term, to: Term, through: Term) -> Goal {
   let subs = List.cons(from, List.empty) // Initial path to feed to the recursion (only the starting room)
    return  path_rec(from: from, to: to, through: through, subs: subs) // Call recursion with same parameters
}

// For a couple: path (represented as a list), battery level.
// Checks if the number of elements contained (rooms) is
// inferior or equal to the given battery level
func battery (through: Term, level: Term) -> Goal {
    return  fresh{x in fresh{y in fresh{L in
               // We first 'extract' the two first rooms
               (List.cons(x, List.cons(y, L)) === through)
               &&
               // Then...
               (
                  fresh{p in
                     // Either they are the last rooms and level-2 is still a natural (is defined)
                     ((L === List.empty) && (succ(succ(p)) === level))
                     ||
                     // Or we continue recursively on the path without the first room and level-1
                     (
                        (succ(p) === level) &&
                        delayed(battery(through: List.cons(y, L), level: p))
                     )
                  }
               )
            }}}
}

// Verifies wether the path crosses a minotaur or not
func meetMinotaur (through: Term) -> Goal {
   return   fresh{x in fresh{L in
               (List.cons(x,L) === through) &&
               (minotaur(location: x) || delayed(meetMinotaur(through: L)))
            }}
}

// For a couple: path, battery level.
// Uses the defined goals to verify that it is a valid path, crosses the minotaur,
// and will end before the battery is out.
func winning (through: Term, level: Term) -> Goal {
    return  fresh{en in fresh{ex in
               entrance(location: en) &&
               exit(location: ex) &&
               path(from: en, to: ex, through: through) &&
               battery(through: through, level: level) &&
               meetMinotaur(through: through)
            }}
}
