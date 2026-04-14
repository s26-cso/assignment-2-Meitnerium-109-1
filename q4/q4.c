#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

typedef int (*op_func_t)(int, int);

int main() {
    char op[8];
    int num1, num2;
    char lib_name[32];
    void *handle;
    op_func_t func;

    // Read inputs in an infinite loop
    while (scanf("%5s %d %d", op, &num1, &num2) == 3) {
        // Construct library path assuming local directory (.so inside CWD)
        snprintf(lib_name, sizeof(lib_name), "./lib%s.so", op);

        // Clear any existing dl errors
        dlerror();

        // Load the shared library
        handle = dlopen(lib_name, RTLD_LAZY);
        if (!handle) {
            fprintf(stderr, "Error loading library %s: %s\n", lib_name, dlerror());
            continue;
        }

        // Get the function symbol mapped precisely to the `<op>` string
        dlerror(); // Clear before dlsym check
        func = (op_func_t) dlsym(handle, op);
        char *error = dlerror();
        if (error != NULL) {
            fprintf(stderr, "Error resolving symbol %s: %s\n", op, error);
            dlclose(handle);
            continue;
        }

        // Execute function and print result
        int result = func(num1, num2);
        printf("%d\n", result);

        // FORCEFULLY UNLOAD
        // Required constraint: 2GB maximum boundary on libraries that may span 1.5GB
        dlclose(handle);
    }

    return 0;
}
