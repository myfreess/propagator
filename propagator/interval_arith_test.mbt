struct Interval {
  lo : Double
  hi : Double
}

fn Interval::new(lo~ : Double, hi~ : Double) -> Interval {
  guard lo < hi
  Interval::{ lo, hi }
}

fn op_mul(self : Interval, other : Interval) -> Interval {
  Interval::new(lo = self.lo * other.lo, hi = self.hi * other.hi)
}

fn op_div(self : Interval, other : Interval) -> Interval {
  self * Interval::new(lo = 1.0 / other.hi, hi = 1.0 / other.lo)
}

fn is_empty(self : Interval) -> Bool {
  self.lo > self.hi
}

fn sqrt(self : Interval) -> Interval {
  Interval::new(lo = self.lo.sqrt(), hi = self.hi.sqrt())
}

fn square(self : Interval) -> Interval {
  Interval::new(lo = self.lo * self.lo, hi = self.hi * self.hi)
}

fn Interval::intersect(x : Interval, y : Interval) -> Interval {
  let lo = if x.lo > y.lo { x.lo } else { y.lo }
  let hi = if x.hi < y.hi { x.hi } else { y.hi }
  Interval::new(lo~, hi~)
}

impl Propagated for Interval with merge(self, other) {
  ...
}