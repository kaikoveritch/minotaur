import LogicKit

let zero = Value (0)

func succ (_ of: Term) -> Map {
    return ["succ": of]
}

func toNat (_ n : Int) -> Term {
    var result : Term = zero
    for _ in 1...n {
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

func entrance (location: Term) -> Goal {
    return  (location === room(1,4)) || (location === room(4,4))
}

func exit (location: Term) -> Goal {
    return  (location === room(1,1)) || (location === room(4,3))
}

func minotaur (location: Term) -> Goal {
    return (location === room(3,2))
}

func path_rec (from: Term, to: Term, through: Term, subs: Term) -> Goal {
   return   (doors(from: from, to: to) && (List.cons(to, subs) === through)) ||
            (
               fresh{x in
                  doors(from: from, to: x) &&
                  path_rec(from: x, to: to, through: through, subs: List.cons(x, subs))
               }
            )
}

func path (from: Term, to: Term, through: Term) -> Goal {
   let subs = List.cons(from, List.empty)
    return  path_rec(from: from, to: to, through: through, subs: subs)
}

func battery (through: Term, level: Term) -> Goal {
    return  fresh{x in fresh{y in fresh{L in
      (List.cons(x, List.cons(y, L)) === through) &&
      (
         fresh{p in
            ((L === List.empty) && (succ(succ(p)) === level)) ||
            ((succ(p) === level) && battery(through: List.cons(y, L), level: p))
         }
      )
   }}}
}

func winning (through: Term, level: Term) -> Goal {
    return  
}
