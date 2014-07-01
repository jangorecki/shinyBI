Pivot process
========================================================

Define pivot proces:
 - *filters* should be an `expression` to be passed to `i` argument in `data.table`, can use *binary search* `data.table` feature.
 - *functions* should be the function names to be applied on corresponding *measures*, or scalar function name to be applied on all provided *measures*.
 - *NA omit* will be applied only to defined functions which accept `na.rm` argument.
 - *distinct* can be useful in case if you need to list few columns without applying any *functions* on *measures*.
 - you can also provide *measures*/*functions* without providing *rows*, it will aggregate *measures* to one row of results. Common use case would be to check `percent NA` on provided columns on whole dataset.
 - *pivot* button will indicate pivot processing.
