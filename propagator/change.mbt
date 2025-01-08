///|
enum Change[T] {
  Change(Bool, T)
  Contradiction(support~ : @immut/sorted_set.T[String], err_msg~ : String)
}

///|
suberror MergeError String
