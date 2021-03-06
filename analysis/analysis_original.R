
library(RMySQL)

db = dbConnect(MySQL(), user='root', password='root', dbname='ecommerce', host='localhost')

result = dbSendQuery(db, "SELECT * from analysis_data_table")
result2 = dbSendQuery(db, "SELECT * from table1_top1")

data = fetch(result, n=-1)

y <- data[,1]
X <- as.matrix(data[,2:11])

logit <- glm( y ~ X , binomial(link='logit') )

summary( logit )

table <- summary(logit)$coefficients

for( i in 1:10 ){
  query <- sprintf('INSERT INTO analysis_estimates VALUES (\'coef%s\',%f,%f,%f,%f);',i,table[i,1],table[i,2],table[i,3],table[i,4])
  query = dbSendQuery(db, query )
}

#
inv.link <- function(eta){ exp(eta)/(1+exp(eta))}
beta     <- coef(logit)
c=3
x <- seq(min(X[,c]),max(X[,c]),0.01)
p <- rep(0,length(x))
for( i in 1:length(x) ){
 cat('.')
 eta  <- beta[1] + x[i]*beta[1+c] + colMeans(X[,setdiff(1:10,c)]) %*% beta[ 1+setdiff(1:10,c) ]
 p[i] <- inv.link(eta)
 
 query <- sprintf('INSERT INTO analysis_prob VALUES (\'coef%s\',%f,%f);',c,x[i],p[i])
 query = dbSendQuery(db, query )
}

