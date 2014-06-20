Pivot process
========================================================

Define pivot proces:
 - *filters* should be an `expression` to be passed to `i` argument in `data.table`, can use *binary search* `data.table` feature.
 - *functions* should be the function names to be applied on corresponding *measures*, or scalar function name to be applied on all provided *measures*.
 - *NA omit* will be applied only to functions which accept `na.rm` argument.
 - *refresh* button will indicate pivot processing.
