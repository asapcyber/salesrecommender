# salesrecommender
Sales recommender system for Viavi customers (recommend products based on quarterly sales)

This document describes a Proof of Concept developed by Viavi IT to demonstrate the implementation of a recommender system for Viavi Customers using quarterly sales data. Based on this small-scale implementation it is suggested that a more comprehensive deployment be pursued and launched on Viavi Sales systems and/or customer portals.

# Objective
Take quarterly sales data from customers and use normalized sales quantity as a proxy for product ratings (i.e. the more a customer buys of a given product the higher the product is rated). Then create a recommender system that makes product recommendations for customers when quoting, tracking an opportunity or when a customer searches for a product (like Amazon, Netflix).

# Approach
In this POC we have implemented a Collaborative Filtering Recommender System. In spite of a lot of known issues like the cold start problem, this kind of systems is broadly adopted, easier to model and known to deliver good results. Specific aspects of this implementation include:
* Collecting quarterly Sales data by customer and product and aggregating quantities sold.
* Implementing a recommender system using <a href=http://cran.r-project.org/web/packages/recommenderlab/index.html>Recommenderlab </a>, an R package that provides the infrastructure to develop and test recommender algorithms for rating data.
* Creating an output matrix of recommendations (Customer x Products) as well as a log of the error estimates or recommendation accuracy.

For more information on using R for predicting user/customer ratings see another example <a href=https://ashokharnal.wordpress.com/2014/12/18/using-recommenderlab-for-predicting-ratings-for-movielens-data/>here.</a>
