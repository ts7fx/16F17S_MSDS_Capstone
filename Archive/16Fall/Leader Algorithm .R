# Source- Leader Algorithm: http://people.inf.elte.hu/fekete/algoritmusok_msc/klaszterezes/John%20A.%20Hartigan-Clustering%20Algorithms-John%20Wiley%20&%20Sons%20(1975).pdf
# 
# Algorithm constructs a partition of the cases and a leading case for each cluster, such that every case in a cluster is within a Distance T of the leading case. 
# 
# The threshold T is a measure of the diameter of each cluster.
# 
# The algorithm makes one pass through the cases, assigning each to the first cluster whose leader is close enough and making a new cluster, and a new leader for cases that not close to any existing leaders. 
# 
# 1)	Begin with I = 1. The number of clusters be K = 1, classify the first case into the first cluster, P(1) = 1, and define L(1) = 1 to be the leading case of the first cluster. 
# 2)	Increase I by 1. If I> M, stop. If I is less than or equal to M, begin working with cluster J.
# 3)	If the distance between I and J> T, go to step 4. If not, case I is assigned to cluster J; P(I) = J, go to step 2. 
# 4)	Increase J to J+1. If J is less than or equal to K, return to step 3. IF J< K, a new cluster is created, with K increased by 1. Set P(1) = K, L(K) = I ,  and return to Step 2. 




setwd("/Users/Kerry/Documents/UVA-DSI/Network Intrusion")
test<-as.data.frame(read.table("/Users/Kerry/Downloads/Key_protocol.txt", sep = ",", header = TRUE))
test$Protocol<-as.factor(test$Protocol)

test$Prot_fac<-as.numeric(test$Protocol)


library(leaderCluster)
test<-subset(test, select = freq:mean_length)
leaderCluster(test, radius = 50)

?leaderCluster


