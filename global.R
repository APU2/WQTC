# PREP for analysis

library(lubridate)
library(data.table)
library(lubridate)
library(ggplot2)
library(plyr)
library(dplyr)
#library(RGtk2)
library(caret)
library(reshape2)
library(rpart)
#library(pROC)
#library(Hmisc)
#library(gbm)
library(zoo)
library(rattle)
#library(glmulti)
#library(leaps)
library(shiny)
#library(shinyapps)
library(shinydashboard)
library(devtools)
library(rCharts)
library(qcc)
library(googleVis)
library(ggvis)
library(IRanges)
library(dygraphs)
library(rpart.plot)
library(tree)
library(randomForest)
library(htmlwidgets)

library(DiagrammeR)
library(htmlwidgets)
library(knitr)
library(ascii)
library(party)


#read data
RUNSTATS<-data.table(read.csv("DATA/RUNSTATS.csv"))

#format run data

RUNSTATS[,STRT:=ymd_hms(STRT)]
RUNSTATS[,END:=ymd_hms(END)]
RUNSTATS[,FILTER_ID:=factor(paste("STREAM",STREAM, "FILTER",FILTER))]
RUNSTATS[,RUN_HL :=(TERM_HL_NORM - CBHL_NORM)]
RUNSTATS[,RIPEN_HIGH:= ifelse(MAX_TURB_TIME < 3, 1,0)]



RUNSTATS[,V1:=NULL]
#RUNSTATS[,END:=NULL]
#RUNSTATS[,RUN_TIME_HRS:=NULL]
RUNSTATS[,MAX_INT:=NULL]
RUNSTATS[,TURB_VAR:=NULL]
RUNSTATS[,TURB_ZEROS:=NULL]

# id failing runs
RUNSTATS$RUN_FAIL<- ifelse(RUNSTATS$T99 > 0.1  , 1, 0)
#| RUNSTATS$TURB_MEAN > RUNSTATS$HIGH_LIMIT

# Subset failing runs
FAIL<- RUNSTATS[RUNSTATS$RUN_FAIL == 1]

# get interval lookup of failing runs
RUN_INTERVALS<-IRanges(start = as.numeric(RUNSTATS$STRT),end = as.numeric(RUNSTATS$END), names = RUNSTATS$STREAM)
FAILURE_INTERVALS<-IRanges(start = as.numeric(FAIL$STRT),end = as.numeric(FAIL$END), names = FAIL$STREAM)


RUNSTATS[, CONCURRENT_FAILS:= countOverlaps(
          IRanges(start = as.numeric(STRT),end = as.numeric(END), names = STREAM),FAILURE_INTERVALS)]

RUNSTATS[, CONCURRENT_FAILS_STREAM:= countOverlaps(
          IRanges(start = as.numeric(STRT),end = as.numeric(END), names = STREAM),FAILURE_INTERVALS[names(FAILURE_INTERVALS)==STREAM]), by = STREAM]

# high level failure types
RUNSTATS$HIGH_PERIOD<-ifelse(RUNSTATS$MAX_TURB_TIME < 3,"EARLY", ifelse(RUNSTATS$MAX_TURB_TIME/RUNSTATS$RUN_TIME_HRS >0.7,"END", "MID"))

RUNSTATS$FILTERS_IMPACTED<-ifelse(RUNSTATS$CONCURRENT_FAILS == 1, "SINGLE FILTER", ifelse(RUNSTATS$CONCURRENT_FAILS == RUNSTATS$CONCURRENT_FAILS_STREAM, "SINGLE STREAM", "MULTI STREAM"))

RUNSTATS$FAILTYPEA<-ifelse(RUNSTATS$RUN_FAIL == 1 , paste( RUNSTATS$HIGH_PERIOD), "OK")
RUNSTATS$FAILTYPEB<-ifelse(RUNSTATS$RUN_FAIL == 1 , paste( RUNSTATS$FILTERS_IMPACTED,RUNSTATS$HIGH_PERIOD), "OK")

# get long df for control charting
RUNSTATS_MEL<- data.table(melt(RUNSTATS, id=c("STREAM", "FILTER", "FILTER_ID", "RUN","STRT", "END", "HIGH_PERIOD", "FILTERS_IMPACTED","FAILTYPEA","FAILTYPEB", "RUN_FAIL", "CONCURRENT_FAILS", "CONCURRENT_FAILS_STREAM", "MAX_TURB_TIME")))

#RUNSTATS_MEL[, cut_val := cut(value, breaks = 7), by = variable]

RUNSTATS_MEL_FAIL<- data.table(RUNSTATS_MEL[RUNSTATS_MEL$RUN_FAIL ==1])

# set random number generation
set.seed(31)

# split data into training and test sets
TRY_FILTER<- data.table(RUNSTATS)

# ensure categorical predictors are factors

TRY_FILTER[,YEAR:= factor(year(STRT))]
TRY_FILTER[,MONTH:= factor(month(STRT))]
TRY_FILTER[,FILTER_ID:= factor(FILTER_ID)]
TRY_FILTER[,STREAM:= factor(STREAM)]
TRY_FILTER[,FILTER:= factor(FILTER)]



# remove unwated variables from training and test data


TRY_FILTER[,STRT:=NULL]
TRY_FILTER[,END:=NULL]
TRY_FILTER[,TURB_MEAN:=NULL]
TRY_FILTER[,T95:=NULL]
TRY_FILTER[,T99:=NULL]
TRY_FILTER[,RUN:=NULL]
TRY_FILTER[,TERM_HL_NORM:=NULL]
TRY_FILTER[,TURB_LOAD:=NULL]
#TRY_FILTER[,SPECIFIC_HL:=NULL]
TRY_FILTER[,HIGH_LIMIT:=NULL]
TRY_FILTER[,RIPEN_MAX:=NULL]
#TRY_FILTER[,MAX_TURB_FLOW:=NULL]
TRY_FILTER[,TURB_HIGH_RATE:=NULL]
TRY_FILTER[,RIPEN_HIGH:=NULL]
TRY_FILTER[,X:=NULL]
TRY_FILTER[,YEAR:=NULL]
TRY_FILTER[,MONTH:=NULL]
#TRY_FILTER[,RUN_FAIL:=NULL]
TRY_FILTER[,TURB_DIFF:=NULL]
TRY_FILTER[,MAX_TURB_TIME:=NULL]
TRY_FILTER[,STREAM_TURB_SD:=NULL]
TRY_FILTER[,STREAM_TURB_MEAN:=NULL]
TRY_FILTER[,FAILTYPEA:=NULL]
TRY_FILTER[,HIGH_PERIOD:=NULL]
TRY_FILTER[,FILTERS_IMPACTED:=NULL]
TRY_FILTER[,FAILTYPEB:=NULL]
TRY_FILTER[,CONCURRENT_FAILS:=NULL]
TRY_FILTER[,CONCURRENT_FAILS_STREAM:=NULL]

TRY_FILTER[,SPECIFIC_HL:=NULL]
TRY_FILTER[,MAX_TURB_FLOW:=NULL]
TRY_FILTER[,RUN_TIME_HRS:=NULL]


train = sample(1: nrow ( TRY_FILTER ) , nrow ( TRY_FILTER ) * .7)

TRY_FILTER_TRAIN<-TRY_FILTER[train,]
TRY_FILTER_TEST<-TRY_FILTER[-train,]

val = sample(1: nrow ( TRY_FILTER_TEST ) , nrow ( TRY_FILTER_TEST ) * .5)
TRY_FILTER_VAL<-TRY_FILTER_TEST[val,]
TRY_FILTER_TEST<-TRY_FILTER_TEST[-val,]

# TRAIN_MELT<-melt(TRY_FILTER_TRAIN, id = c("STREAM","FILTER","FILTER_ID","RUN_FAIL","RIPEN_HIGH","CONCURRENT_FAILS", "CONCURRENT_FAILS_STREAM", "HIGH_PERIOD", "FILTERS_IMPACTED","FAILTYPEA","FAILTYPEB"))
#TRAIN_MELT_HL<-melt(TRY_FILTER_TRAIN, id = c("STREAM","FILTER","FILTER_ID","RUN_FAIL", "RUN_HL"))


zoowrap<- function(x){ zoobit<- zoo(x$value, x$STRT)
return(zoobit)
}

zoowrap_cusum<- function(x){ zoobit<- zoo(x$cusum_day, x$STRT)
return(zoobit)
}

# Subset failing runs
FAILURES<- RUNSTATS[RUNSTATS$RUN_FAIL == 1]




# create random forest model

set.seed(12)
rf_mod<- randomForest(formula = factor(RUN_FAIL)~., data = na.omit(TRY_FILTER_TRAIN), mtry = 7, importance = FALSE , ntree = 20, nodesize= 4)

RF_PRED<-predict(rf_mod, newdata = TRY_FILTER_TEST)

cont_tab<- table( TRY_FILTER_TEST$RUN_FAIL, RF_PRED)

RF_IMP<- data.frame(importance(rf_mod, type = 2, scale = TRUE))
RF_IMP$variable<- row.names(RF_IMP)
RF_IMP<- RF_IMP[order(RF_IMP$RANK),]


# 
# rf_mod_ctree<- cforest(formula = factor(RUN_FAIL)~FLOW_SD+LEVEL_SD+LEVEL_MEAN+FILTER, data = na.omit(TRY_FILTER_TRAIN), controls = cforest_unbiased(ntree = 30, trace = TRUE))
# 
# CTREE_PRED<-predict(rf_mod_ctree, newdata = TRY_FILTER_TEST)
# 
# cont_tab_ctree<- table( TRY_FILTER_TEST$RUN_FAIL, CTREE_PRED)
# 
# 
# CTREE_IMP<-data.frame(varimp(rf_mod_ctree, conditional = TRUE, mincriterion = .99))
# CTREE_IMP$vaiable<- row.names(CTREE_IMP)
# 
# summary(TRY_FILTER)

RF_IMP <- transform( RF_IMP,
                     variable = ordered(variable, levels = rownames(RF_IMP[order(RF_IMP$MeanDecreaseGini, decreasing = FALSE),])))
          
RF_IMP$RANK<-rank(1/RF_IMP$MeanDecreaseGini)


INF_TAB<- read.csv("DATA/INFERENCE_TAB.csv", stringsAsFactors = FALSE)
INF_TAB<- melt(INF_TAB, id=1)


FAULT_LAB<- read.csv("DATA/FAULT_LABS.csv", stringsAsFactors = FALSE)

diag_tab<- ddply(INF_TAB, .(variable),mutate,
                           score = value * RF_IMP[match(VARIABLE, row.names(RF_IMP)), "MeanDecreaseGini"])

diag_tab<-ddply(diag_tab, .(variable), summarise,
                          score = mean(score, na.rm =TRUE))

diag_tab<- diag_tab[order(diag_tab$score, decreasing = TRUE),]
          diag_tab$cause<- FAULT_LAB[match(diag_tab$variable, FAULT_LAB$VARIABLE),"label"]


