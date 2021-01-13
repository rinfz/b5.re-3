from ctypes import *

class Point(Structure):
    _fields_ = [("x", c_int), ("y", c_int)]

    def __str__(self):
        return f"Point(x={self.x}, y={self.y})"


lib = cdll.LoadLibrary("libexample.so")
lib.add_points.argtypes = [POINTER(Point), POINTER(Point)]
lib.add_points.restype = Point
lib.add_points_inplace.argtypes = [POINTER(Point), POINTER(Point)]
lib.add_points_inplace.restype = None