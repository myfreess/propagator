///|
fn adder(x : Cell[Int], y : Cell[Int], z : Cell[Int]) -> Unit raise MergeError {
  Cell::lift2(fn(x, y) { x + y }, x, y, output=z)
  Cell::lift2(fn(z, x) { z - x }, z, x, output=y)
  Cell::lift2(fn(z, y) { z - y }, z, y, output=x)
}

///|
fn test_bidirct_add(x : Int, y : Int) -> Unit raise Error {
  let z = x + y
  // forward
  {
    let lhs_input = Cell::new_default()
    let rhs_input = Cell::new_default()
    let output = Cell::new_default()
    adder(lhs_input, rhs_input, output)
    lhs_input.write(x)
    rhs_input.write(y)
    assert_eq(output.content().unwrap(), z)
  }
  // backward, get x
  {
    let lhs_input = Cell::new_default()
    let rhs_input = Cell::new_default()
    let output = Cell::new_default()
    adder(lhs_input, rhs_input, output)
    output.write(z)
    rhs_input.write(y)
    assert_eq(lhs_input.content().unwrap(), x)
  }
  // backward, get y
  let lhs_input = Cell::new_default()
  let rhs_input = Cell::new_default()
  let output = Cell::new_default()
  adder(lhs_input, rhs_input, output)
  output.write(z)
  rhs_input.write(x)
  assert_eq(lhs_input.content().unwrap(), y)
}

///|
test "forward add" {
  for x in 1..<100 {
    for y in 50..<100 {
      test_bidirct_add(x, y)
    }
  }
}
