#R code for PCA

Library(stats)


inputs<-commandArgs()

traitsData<-grep("traitsdata",
                 allargs,
                 ignore.case=TRUE,
                 perl=TRUE,
                 value=TRUE
               )
