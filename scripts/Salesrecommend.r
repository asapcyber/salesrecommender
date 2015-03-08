#### Recommend products to customers based on sales history ....
#### Reference: https://inclass.kaggle.com/c/predict-movie-ratings
 
# Set data path as per your data file (for example: "c://abc//" )
setwd('C:/Program Files/R/R-3.1.0/Data')
 
# If not installed, first install following three packages in R
library(recommenderlab)
library(reshape2)
library(ggplot2)
# Read training file along with header
tr<-read.csv("Salespredict.csv",header=TRUE)
# Just look at first few lines of this file
head(tr)
# Using acast to convert above data as follows:
#       m1  m2   m3   m4
# u1    3   4    2    5
# u2    1   6    5
# u3    4   4    2    5
g<-acast(tr, Customer ~ Item)
# Check the class of g
class(g)
 
# Convert it as a matrix
R<-as.matrix(g)
 
# Convert R into realRatingMatrix data structure
#   realRatingMatrix is a recommenderlab sparse-matrix like data-structure
r <- as(R, "realRatingMatrix")
r
 
# view r in other possible ways
as(r, "list")     # A list
as(r, "matrix")   # A sparse matrix
 
# I can turn it into data-frame
head(as(r, "data.frame"))
 
# normalize the rating matrix
r_m <- normalize(r)
r_m
as(r_m, "list")
 
# Draw an image plot of raw-ratings & normalized ratings
#  A column represents one specific movie and ratings by users
#   are shaded.
#   Note that some items are always rated 'black' by most users
#    while some items are not rated by many users
#     On the other hand a few users always give high ratings
#      as in some cases a series of black dots cut across items
image(r, main = "Raw Ratings")    
image(r_m, main = "Normalized Ratings")
hist(getRatings(r), breaks=100)
# Can also turn the matrix into a 0-1 binary matrix
r_b <- binarize(r, minRating=1)
as(r_b, "matrix")
 
# Create a recommender object (model)
#   Run anyone of the following four code lines.
#     Do not run all four
#       They pertain to four different algorithms.
#        UBCF: User-based collaborative filtering
#        IBCF: Item-based collaborative filtering
#      Parameter 'method' decides similarity measure
#        Cosine or Jaccard
#rec=Recommender(r[1:nrow(r)],method="UBCF", param=list(normalize = "Z-score",method="Cosine",nn=5, minRating=1))
#rec=Recommender(r[1:nrow(r)],method="UBCF", param=list(normalize = "Z-score",method="Jaccard",nn=5, minRating=1))
rec=Recommender(r[1:nrow(r)],method="IBCF", param=list(normalize = "Z-score",method="Jaccard",minRating=1))
#rec=Recommender(r[1:nrow(r)],method="POPULAR")
 
# Depending upon your selection, examine what you got
print(rec)
names(getModel(rec))
getModel(rec)$nn

#Now we can play with our model… for example, let’s try to obtain the top recommendations for a particular customer “COMCAST″
# recommended top 5 items for customer COMCAST
recom.COMCAST <- predict(rec, r["COMCAST",], n=5)

# to display them
as(recom.COMCAST, "list")
# to obtain the top 3
recom.COMCAST.top3 <- bestN(recom.COMCAST, n = 3)
# to display them
as(recom.COMCAST.top3, "list")
# Predict list of product which can be recommended to given customers	
#to predict affinity to all non-rated items 
predicted.affinity.COMCAST <- predict(rec, r["COMCAST",], type="ratings")
# to see the customer "COMCAST"'s predicted affinity for items we didn't have any value for
as(predicted.affinity.COMCAST, "list")
# .. and the real affinity for the items obtained from the affinity.matrix
as(r["COMCAST",], "list")

 
############Create predictions#############################
# This prediction does not predict movie ratings for test.
#   But it fills up the user 'X' item matrix so that
#    for any userid and movieid, I can find predicted rating
#     dim(r) shows there are 6040 users (rows)
#      'type' parameter decides whether you want ratings or top-n items
#         get top-10 recommendations for a user, as:
#             predict(rec, r[1:nrow(r)], type="topNList", n=10)
recom <- predict(rec, r[1:nrow(r)], type="ratings")
recom
 
########## Examination of model & experimentation  #############
########## This section can be skipped #########################
 
# Convert prediction into list, user-wise
as(recom, "list")
# Study and Compare the following:
as(r, "matrix")     # Has lots of NAs. 'r' is the original matrix
as(recom, "matrix") # Is full of ratings. NAs disappear
as(recom, "matrix")[,1:10] # Show ratings for all users for items 1 to 10
as(recom, "matrix")[5,3]   # Rating for user 5 for item at index 3
as.integer(as(recom, "matrix")[5,3]) # Just get the integer value
as.integer(round(as(recom, "matrix")[6039,8])) # Just get the correct integer value
as.integer(round(as(recom, "matrix")[368,3717])) 
 
# Convert all your recommendations to list structure
rec_list<-as(recom,"list")
head(summary(rec_list))
# Access this list. User 2, item at index 2
rec_list[[2]][2]
# Convert to data frame all recommendations for user 1
u1<-as.data.frame(rec_list[[1]])
attributes(u1)
class(u1)
# Create a column by name of id in data frame u1 and populate it with row names
u1$id<-row.names(u1)
# Check movie ratings are in column 1 of u1
u1
# Now access movie ratings in column 1 for u1
u1[u1$id==3952,1]


#To evaluate our Rec.model we need data, more precisely, experimentally obtained data. 
# The only experimentally obtained data source is our affinity.data, so we need to 
# take a chunk to train our model, but leave another chunk to validate whether the 
# model produces the right output. This technique is called “split”.
# create evaluation scheme splitting taking 90% of the date for training and leaving 10% for validation or test
e <- evaluationScheme(r[1:500], method="split", train=0.9, given=3, goodRating=5)
# creation of recommender model based on ubcf
Rec.ubcf <- Recommender(getData(e, "train"), "UBCF")
# creation of recommender model based on ibcf for comparison
Rec.ibcf <- Recommender(getData(e, "train"), "IBCF")
# making predictions on the test data set
p.ubcf <- predict(Rec.ubcf, getData(e, "known"), type="ratings")
# making predictions on the test data set
p.ibcf <- predict(Rec.ibcf, getData(e, "known"), type="ratings")
# obtaining the error metrics for both approaches and comparing them
error.ubcf<-calcPredictionAccuracy(p.ubcf, getData(e, "unknown"))
error.ibcf<-calcPredictionAccuracy(p.ibcf, getData(e, "unknown"))
error <- rbind(error.ubcf,error.ibcf)
rownames(error) <- c("UBCF","IBCF")
error
scheme <- evaluationScheme(r[1:500], method="cross", k=4, given=1,goodRating=5)
results <- evaluate(scheme, method="POPULAR", n=c(1,3,5,10,15,20))
getConfusionMatrix(results)[[1]]
avg(results)
plot(results, annotate=TRUE)

########## Create submission File from model #######################
# Read test file
test<-read.csv("test_v2.csv",header=TRUE)
head(test)
# Get ratings list
rec_list<-as(recom,"list")
head(summary(rec_list))
ratings<-NULL
# For all lines in test file, one by one
for ( u in 1:length(test[,2]))
{
   # Read userid and movieid from columns 2 and 3 of test data
   userid <- test[u,2]
   movieid<-test[u,3]
 
   # Get as list & then convert to data frame all recommendations for user: userid
   u1<-as.data.frame(rec_list[[userid]])
   # Create a (second column) column-id in the data-frame u1 and populate it with row-names
   # Remember (or check) that rownames of u1 contain are by movie-ids
   # We use row.names() function
   u1$id<-row.names(u1)
   # Now access movie ratings in column 1 of u1
   x= u1[u1$id==movieid,1]
   # print(u)
   # print(length(x))
   # If no ratings were found, assign 0. You could also
   #   assign user-average
   if (length(x)==0)
   {
     ratings[u] <- 0
   }
   else
   {
     ratings[u] <-x
   }
 
}
length(ratings)
tx<-cbind(test[,1],round(ratings))
# Write to a csv file: submitfile.csv in your folder
write.table(tx,file="submitfile.csv",row.names=FALSE,col.names=FALSE,sep=',')
# Submit now this csv file to kaggle
########################################



