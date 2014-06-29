Source data
========================================================

To load source data to **shinyBI** you should create `data.table` object named `DT` before `shinyBI()` call. You should already convert fields to appropriate data types. In case of using *binary search* `data.table` feature in pivot you need also setkey on `DT`. Factor fields were not tested, you may use character type instead.  If no `DT` `data.table` object will be prepared before `shinyBI()` call then app will use sample dataset of RStudio CRAN mirror logs (617k rows).

1. Load data from csv:

        library(shinyBI)
        DT <- fread("source.csv")
        shinyBI()

2. Any other file formats that R can read (xlsx, xml, rds, etc.):

        library(shinyBI)
        DT <- readRDS("source_dt.rds")
        shinyBI()

3. You can also query data from database using **native drivers**. Below syntax applied to: [Oracle](http://cran.r-project.org/web/packages/ROracle/index.html), [SQLite](http://cran.r-project.org/web/packages/RSQLite/index.html), [PostreSQL](http://cran.r-project.org/web/packages/RPostgreSQL/index.html), [MySQL](http://cran.r-project.org/web/packages/RMySQL/index.html):

        library(shinyBI)
        library(RSQLite)
        conn <- dbConnect(dbDriver("SQLite"), dbname = "sqlite.db")
        DT <- as.data.table(dbGetQuery(conn, "SELECT * FROM source_table"))
        dbDisconnect(conn)
        shinyBI()

4. For data stored in database in normalized structure (**star schema** or **snowflake schema**) you may query all tables and perform batch join in R, of course you can still join on database side using extended SQL query and load already denormalized table. Below syntax applied to any [ODBC](http://cran.r-project.org/web/packages/RODBC/index.html) driver:

        library(devtools) # source_url batch join function
        library(shinyBI)
        library(RODBC)
        conn <- odbcConnect("odbc_driver_name", uid="user", pwd="pass")
        customer <- as.data.table(sqlQuery(conn, "SELECT * FROM customer"))
        product <- as.data.table(sqlQuery(conn, "SELECT * FROM product"))
        time <- as.data.table(sqlQuery(conn, "SELECT * FROM time"))
        geography <- as.data.table(sqlQuery(conn, "SELECT * FROM geography"))
        sales <- as.data.table(sqlQuery(conn, "SELECT * FROM sales"))
        close(conn)
        # pull request to data.table, man: https://github.com/jangorecki/datatable/blob/master/man/joinbyv.Rd
        source_url("https://raw.githubusercontent.com/jangorecki/datatable/master/R/joinbyv.R")
        DT <- joinbyv(master = sales, 
                      join = list(customer,product,time,sales), 
                      by = list("id_customer","id_product","id_time","id_geography"))
        rm(sales, customer, product, time, geography); gc()
        shinyBI()

If you are in App below you can see last few rows of currently loaded `DT`:
