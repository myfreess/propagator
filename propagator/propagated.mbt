///|
pub(open) trait Propagated {
  merge(Self, Self) -> Change[Self]
}

///|
fn[T : Eq + Show] merge_default(l : T, r : T) -> Change[T] {
  if l == r {
    Change(false, l)
  } else {
    Contradiction(
      support=@immut/sorted_set.new(),
      err_msg="merge: \{l} != \{r}",
    )
  }
}

///|
pub impl Propagated for Bool with merge(self, other) {
  merge_default(self, other)
}

///|
pub impl Propagated for Int with merge(self, other) {
  merge_default(self, other)
}

///|
pub impl Propagated for Int64 with merge(self, other) {
  merge_default(self, other)
}

///|
pub impl Propagated for UInt with merge(self, other) {
  merge_default(self, other)
}

///|
pub impl Propagated for UInt64 with merge(self, other) {
  merge_default(self, other)
}

///|
pub impl Propagated for BigInt with merge(self, other) {
  merge_default(self, other)
}

///|
fn float_is_posinf(f : Float) -> Bool {
  f > @float.max_value
}

///|
fn float_is_neginf(f : Float) -> Bool {
  f < @float.min_value
}

///|
fn double_is_posinf(d : Double) -> Bool {
  d > @double.max_value
}

///|
fn double_is_neginf(d : Double) -> Bool {
  d < @double.min_value
}

///|
pub impl Propagated for Float with merge(self, other) {
  if self != self && other != other {
    Change(false, self)
  } else if float_is_neginf(self) && float_is_neginf(other) {
    Change(false, self)
  } else if float_is_posinf(self) && float_is_posinf(other) {
    Change(false, self)
  } else if (self - other).abs() < 0.000_001 {
    Change(false, self)
  } else {
    Contradiction(
      support=@immut/sorted_set.new(),
      err_msg="merge: \{self} != \{other}",
    )
  }
}

///|
pub impl Propagated for Double with merge(self, other) {
  if self != self && other != other {
    Change(false, self)
  } else if double_is_neginf(self) && double_is_neginf(other) {
    Change(false, self)
  } else if double_is_posinf(self) && double_is_posinf(other) {
    Change(false, self)
  } else if (self - other).abs() < 0.000_000_001 {
    Change(false, self)
  } else {
    Contradiction(
      support=@immut/sorted_set.new(),
      err_msg="merge: \{self} != \{other}",
    )
  }
}

///|
pub impl[X : Propagated, Y : Propagated] Propagated for (X, Y) with merge(
  self,
  other
) {
  match X::merge(self.0, other.0) {
    Change(x_changed, x) =>
      match Y::merge(self.1, other.1) {
        Change(y_changed, y) => Change(x_changed || y_changed, (x, y))
        Contradiction(_) as contradiction =>
          Contradiction(
            support=contradiction.support,
            err_msg=contradiction.err_msg,
          )
      }
    Contradiction(_) as contradiction =>
      Contradiction(
        support=contradiction.support,
        err_msg=contradiction.err_msg,
      )
  }
}
