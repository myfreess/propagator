///|
struct Cell[T] {
  merge : (T, T) -> Change[T]
  watchers : Array[(T) -> Unit raise MergeError]
  mutvar : Ref[T?]
}

///|
pub fn[T] op_equal(self : Cell[T], other : Cell[T]) -> Bool {
  physical_equal(self.mutvar, other.mutvar)
}

///|
pub fn[T : Propagated] Cell::new_default() -> Cell[T] {
  Cell::{ merge: Propagated::merge, watchers: [], mutvar: Ref::{ val: None } }
}

///|
pub fn[T] Cell::new(merge~ : (T, T) -> Change[T]) -> Cell[T] {
  Cell::{ merge, watchers: [], mutvar: Ref::{ val: None } }
}

///|
pub fn[T : Propagated] Cell::new_with(
  merge~ : (T, T) -> Change[T] = Propagated::merge,
  known? : T
) -> Cell[T] {
  Cell::{ merge, watchers: [], mutvar: Ref::{ val: known } }
}

///|
pub fn[T] write(self : Cell[T], val : T) -> Unit raise MergeError {
  match self.mutvar.val {
    None => {
      self.mutvar.val = Some(val)
      for watcher in self.watchers.iter() {
        watcher(val)
      }
    }
    Some(oldval) =>
      match (self.merge)(oldval, val) {
        Change(true, newval) => {
          self.mutvar.val = Some(newval)
          for watcher in self.watchers.iter() {
            watcher(newval)
          }
        }
        Change(false, _) => ()
        Contradiction(_) as contradiction =>
          if contradiction.support.is_empty() {
            raise MergeError(contradiction.err_msg)
          } else {
            raise MergeError(
              "\{contradiction.err_msg}, supported by \{contradiction.support.iter().collect()}",
            )
          }
      }
  }
}

///|
pub fn[T] content(self : Cell[T]) -> T? {
  self.mutvar.val
}

///|
pub fn[T] attach(
  self : Cell[T],
  watcher~ : (T) -> Unit raise MergeError
) -> Unit raise MergeError {
  match self.mutvar.val {
    None => self.watchers.push(watcher)
    Some(val) => {
      watcher(val)
      self.watchers.push(watcher)
    }
  }
}

///|
pub fn[T] Cell::unify(x : Cell[T], y : Cell[T]) -> Unit raise MergeError {
  x.attach(watcher=fn(val) { y.write(val) })
  y.attach(watcher=fn(val) { x.write(val) })
}

///|
pub fn[T] apply_to(
  self : Cell[T],
  f : (T) -> Unit raise MergeError
) -> Unit raise MergeError {
  match self.mutvar.val {
    None => ()
    Some(val) => f(val)
  }
}

///|
pub fn[X, Y] Cell::attach2(
  watcher~ : (X, Y) -> Unit raise MergeError,
  x : Cell[X],
  y : Cell[Y]
) -> Unit raise MergeError {
  x.attach(watcher=fn(x) { y.apply_to(fn(y) { watcher(x, y) }) })
  y.attach(watcher=fn(y) { x.apply_to(fn(x) { watcher(x, y) }) })
}

///|
pub fn[I, O] Cell::lift(
  f : (I) -> O,
  input : Cell[I],
  output~ : Cell[O]
) -> Unit raise MergeError {
  input.attach(watcher=fn(val) { output.write(f(val)) })
}

///|
pub fn[X, Y, O] Cell::lift2(
  f : (X, Y) -> O,
  lhs_input : Cell[X],
  rhs_input : Cell[Y],
  output~ : Cell[O]
) -> Unit raise MergeError {
  Cell::attach2(lhs_input, rhs_input, watcher=fn(x, y) { output.write(f(x, y)) })
}
