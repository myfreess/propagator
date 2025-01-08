///|
pub(all) struct Supported[T] {
  support : @immut/sorted_set.T[String]
  value : T
}

///|
pub impl[T : Propagated] Propagated for Supported[T] with merge(self, other) {
  match Propagated::merge(self.value, other.value) {
    Change(false, _) => Change(false, self)
    Change(true, value) =>
      Change(true, Supported::{ support: self.support + other.support, value })
    Contradiction(support~, err_msg~) =>
      Contradiction(support=support + self.support + other.support, err_msg~)
  }
}
