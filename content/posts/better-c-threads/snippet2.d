extern(C) void* inc_x(void* data) {
    int* x_ptr = cast(int*) data;
    while (++(*x_ptr) < 100) {}
    printf("Done on thread\n");
    return null;
}