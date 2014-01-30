 #SNOPSIS

 #prepares trait phenotype data for histogram plotting


 #AUTHOR
 # Isaak Y Tecle (iyt2@cornell.edu)


options(echo = FALSE)

library(plyr)
#library(R.utils)

allArgs<-commandArgs(trailingOnly=TRUE)


allTraitsPhenoFile <- sub('input_file=', "", allArgs[1])
trait              <- sub('trait_name=', "", allArgs[2])
traitPhenoFile     <- sub('output_file=', "", allArgs[3])

message("population phenotype file: ", allTraitsPhenoFile)
message("pheno data file: ", traitPhenoFile)
message("trait: ", trait)


if (is.null(grep("phenotype_data", allTraitsPhenoFile)))
{
  stop("Phenotype dataset missing.")
}

if (is.null(grep("phenotype_trait", traitPhenoFile)))
{
  stop("Output file is missing.")
}

if (is.null(grep("trait_name", allArgs[3])))
{
  stop("trait name is missing.")
}



allTraitsPhenoData <- read.table(allTraitsPhenoFile,
                        header = TRUE,
                        row.names = NULL,
                        sep = "\t",
                        na.strings = c("NA", " ", "--", "-"),
                        dec = "."
                        )

selectColumns <- c("object_name", "object_id", "stock_id",  trait)
traitPhenoData  <- allTraitsPhenoData[selectColumns]
                   
if (sum(is.na(traitPhenoData[, trait])) > 0)
  {     
    message("number of  pheno missing values for ",
            trait, ": ",
            sum(is.na(traitPhenoData[, trait])))
    #fill in for missing data with mean value
    traitPhenoData[, trait]  <- replace(traitPhenoData[, trait],
                                        is.na(traitPhenoData[, trait]),
                                        mean(traitPhenoData[, trait],
                                             na.rm =TRUE)
                                        ) 
  }

dropColumns <- c("object_id", "stock_id")
traitPhenoData <- traitPhenoData[, !(names(traitPhenoData) %in% dropColumns)]

traitPhenoData <- ddply(traitPhenoData,
                        "object_name",
                        colwise(mean)
                        )

row.names(traitPhenoData) <- traitPhenoData[, 1]
traitPhenoData[, 1] <- NULL

traitPhenoData <- round(traitPhenoData,
                            digits=2
                            )

write.table(traitPhenoData,
            file = traitPhenoFile,
            sep = "\t",
            col.names = NA,
            quote = FALSE,
            append = FALSE
            )

q(save = "no", runLast = FALSE)