extern (C) void main() {
    int x = 0, y = 0;

    pthread_t inc_x_thread;

    if (pthread_create(&inc_x_thread, null, &inc_x, &x)) {
        printf("Error creating thread\n");
        return;
    }

    while (++y < 100) {}

    if (pthread_join(inc_x_thread, null)) {
        printf("Error joining thread\n");
        return;
    }

    printf("x=%d, y=%d\n", x, y);
}