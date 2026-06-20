#include <criterion/criterion.h>

#include "add.h"

Test(add, positive) { cr_assert_eq(add(2, 3), 5); }

Test(add, negative) { cr_assert_eq(add(-2, -3), -5); }

Test(add, zero) { cr_assert_eq(add(0, 0), 0); }
