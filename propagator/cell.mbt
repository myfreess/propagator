
struct Cell[T] {
  merge : (T, T) -> Change[T]
  watchers : Array[(T) -> Unit!MergeError]
  mutvar : Ref[T?]
}

pub fn op_equal[T](self : Cell[T], other : Cell[T]) -> Bool {
  physical_equal(self.mutvar, other.mutvar)
}

pub fn Cell::new_default[T : Propagated]() -> Cell[T] {
  Cell::{
    merge  : Propagated::merge,
    watchers : [],
    mutvar : Ref::{ val : None }
  }
}

pub fn Cell::new[T](merge~ : (T, T) -> Change[T]) -> Cell[T] {
  Cell::{
    merge  : merge,
    watchers : [],
    mutvar : Ref::{ val : None }
  }
}

pub fn Cell::new_with[T : Propagated](merge~ : (T, T) -> Change[T] = Propagated::merge, known? : T) -> Cell[T] {
  Cell::{
    merge  : merge,
    watchers : [],
    mutvar : Ref::{ val : known }
  }
}

pub fn write[T](self : Cell[T], val : T) -> Unit!MergeError {
  match self.mutvar.val {
    None => {
      self.mutvar.val = Some(val)
      for watcher in self.watchers.iter() {
        watcher!(val)
      }
    }
    Some(oldval) => {
      match (self.merge)(oldval, val) {
        Change(true, newval) => {
          self.mutvar.val = Some(newval)
          for watcher in self.watchers.iter() {
            watcher!(newval)
          }
        }
        Change(false, _) => ()
        Contradiction(_) as contradiction => {
          if contradiction.support.is_empty() {
            raise MergeError(contradiction.err_msg)
          } else {
            raise MergeError("\{contradiction.err_msg}, supported by \{contradiction.support.iter().collect()}")
          }
        }
      }
    }
  }
}

pub fn content[T](self : Cell[T]) -> T? {
  self.mutvar.val
}

pub fn attach[T](self : Cell[T], watcher~ : (T) -> Unit!MergeError) -> Unit!MergeError {
  match self.mutvar.val {
    None => {
      self.watchers.push(watcher)
    }
    Some(val) => {
      watcher!(val)
      self.watchers.push(watcher)
    }
  }
}

pub fn Cell::unify[T](x : Cell[T], y : Cell[T]) -> Unit!MergeError {
  x.attach!(watcher = fn (val) { y.write!(val) })
  y.attach!(watcher = fn (val) { x.write!(val) })
}

pub fn apply_to[T](self : Cell[T], f : (T) -> Unit!MergeError) -> Unit!MergeError {
  match self.mutvar.val {
    None => ()
    Some(val) => f!(val)
  }
}

pub fn Cell::attach2[X, Y](watcher~ : (X, Y) -> Unit!MergeError, x : Cell[X], y : Cell[Y]) -> Unit!MergeError {
  x.attach!(watcher = fn (x) { y.apply_to!(fn (y) { watcher!(x, y) }) })
  y.attach!(watcher = fn (y) { x.apply_to!(fn (x) { watcher!(x, y) }) })
}


pub fn Cell::lift[I, O](f : (I) -> O, input : Cell[I], output~ : Cell[O]) ->  Unit!MergeError {
  input.attach!(watcher = fn (val ) { output.write!(f(val)) })
}

pub fn Cell::lift2[X, Y, O](f : (X, Y) -> O, lhs_input : Cell[X], rhs_input : Cell[Y], output~ : Cell[O]) ->  Unit!MergeError {
  Cell::attach2!(lhs_input, rhs_input, watcher = fn (x, y) { output.write!(f(x, y)) })
}

