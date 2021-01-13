impl std::ops::Add for Point {
  type Output = Self;

  fn add(self, other: Self) -> Self {
      Self {
          x: self.x + other.x,
          y: self.y + other.y,
      }
  }
}