mod ffi {
  use super::Point;

  #[no_mangle]
  pub extern "C" fn add_points(a: *const Point, b: *const Point) -> Point {
      unsafe { *a + *b }
  }

  #[no_mangle]
  pub extern "C" fn add_points_inplace(a: *mut Point, b: *const Point) {
      unsafe {
          (*a).x += (*b).x;
          (*a).y += (*b).y;
      }
  }
}