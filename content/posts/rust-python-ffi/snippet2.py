p1 = Point(10, 10)
p2 = Point(15, 21)

p3 = lib.add_points(p1, p2)
print(p3)  # prints: Point(x=25, y=31)

p4 = Point(25, 19)
lib.add_points_inplace(p3, p4)

print(p3)  # prints: Point(x=50, y=50)