#include "utils/numeric.h"

/* Functions in datatypes/numeric.c */
extern Numeric tsql_set_var_from_str_wrapper(const char *str);
extern int32_t tsql_numeric_get_typmod(Numeric num);

/* Functions in datatypes/varchar.c */
extern void *tsql_varchar_input(const char *s, size_t len, int32 atttypmod);