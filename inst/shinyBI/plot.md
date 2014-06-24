Plot pivot results
========================================================

Plot arguments:
 - *x axis* variable
 - *y axis* variable
 - optional *groups* (series) variable

For the plotting feature you should perform the pivot table on the lowest *rows* granularity that you want to plot: 
 - do not group by `week, date` if you are going to plot on `week` granularity
 - do not group by `date, package` if you are not going to use `package` in plotting
