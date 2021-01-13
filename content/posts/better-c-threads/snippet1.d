// D provides printf, import here for use later
// (and note that we can't use writeln like we normally would in D)
import core.stdc.stdio : printf;

extern(C) {
    alias pthread_t = ulong;
    // Laziness as it's actually a union but we don't care here.
    alias pthread_attr_t = void;

    int pthread_create(pthread_t *newthread,
                       const pthread_attr_t* attr,
                       void* function(void*) start_routine,
                       void* arg);

    int pthread_join(pthread_t t, void** t_return);
}