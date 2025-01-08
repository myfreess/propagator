///|
enum Interval {
  Empty
  Interval(lo~ : Double, hi~ : Double)
}

///|
fn Interval::new(lo~ : Double, hi~ : Double) -> Interval {
  guard lo < hi
  Interval(lo~, hi~)
}

///|
fn not_intersect_to(self : Interval, other : Interval) -> Bool {
  match (self, other) {
    (Empty, _) => true
    (_, Empty) => true
    (Interval(_) as l, Interval(_) as r) => l.hi < r.lo || l.lo > r.hi
  }
}

///|
impl Propagated for Interval with merge(self, other) {
  ...
}
