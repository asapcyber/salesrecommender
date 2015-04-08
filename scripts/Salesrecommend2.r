#### Recommend products to customers based on sales history ....
####Reference: https://inclass.kaggle.com/c/predict-movie-ratings
 
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

#Now we can play with our model… for example, let’s try to obtain the top recommendations for a particular customer “COMCAST?
# recommended top 5 items for customer VODAFONE
recom.GOOGLE <- predict(rec, r["GOOGLE",], n=5)

# to display them
as(recom.GOOGLE, "list")
# to obtain the top 3
recom.GOOGLE.top3 <- bestN(recom.GOOGLE, n = 3)
# to display them
as(recom.GOOGLE.top3, "list")

 
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

########## Create CSV File from model #######################
write.csv(getData.frame(recom,decode=TRUE,ratings=TRUE), "SalesRecom.csv")
write.csv(as(recom, "matrix"), "RecomMatrix.csv")
########################################
