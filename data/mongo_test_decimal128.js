// Test data for Decimal128 support
// This script creates collections with Decimal128 fields for regression testing.
use mongo_fdw_regress
db.test_decimal128.drop();
db.test_decimal128.insertMany([
   {c1: NumberInt(1), c2: "pi", c3: NumberDecimal("3.14159265358979323846")},
   {c1: NumberInt(2), c2: "large", c3: NumberDecimal("12345678901234567890.123456789")},
   {c1: NumberInt(3), c2: "negative", c3: NumberDecimal("-99999.99999")},
   {c1: NumberInt(4), c2: "zero", c3: NumberDecimal("0")},
   {c1: NumberInt(5), c2: "small_int", c3: NumberDecimal("42")},
   {c1: NumberInt(6), c2: "max_precision", c3: NumberDecimal("1234567890123456789012345678901234")},
]);
