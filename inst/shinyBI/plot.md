Plot pivot results
========================================================

Plot arguments:
 - *x axis* variable
 - *y axis* variable
 - optional *groups* (series) variable
Notes:
 - you should perform the pivot table on the lowest *rows* granularity that you want to plot, so:
  - do not group by `week, date` if you are going to plot on `week` granularity
  - do not group by `date, package` if you are not going to use `package` in plotting
 - in case of non readable axis labels use mouse hover on plot.
 - still experimental, so in case of plot stuck refresh App
 - interactive guideline works only on `lineChart` plot type
