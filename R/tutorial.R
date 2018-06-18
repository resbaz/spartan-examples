# Import the tree data CSV
w1 <- read.csv(file="w1.dat",sep=",",head=TRUE)
tree <- read.csv(file="trees91.csv",sep=",",head=TRUE)
# Plot a histogram of the data
hist(w1$vals)

# adding titles and labels - always annotate your plots!
hist(w1$vals,main='Leaf BioMass in High CO2 Environment',xlab='BioMass of Leaves')
title('Leaf BioMass in High CO2 Environment',xlab='BioMass of Leaves')

# add other kinds of plots (e.g., stripchart)
hist(w1$vals,main='Leaf BioMass in High CO2 Environment',xlab='BioMass of Leaves',ylim=c(0,16))
stripchart(w1$vals,add=TRUE,at=15.5)

# Specify the number of breaks to use
hist(w1$vals,breaks=2)
hist(w1$vals,breaks=4)
hist(w1$vals,breaks=6)
hist(w1$vals,breaks=8)
hist(w1$vals,breaks=12)

# Specify the size of the domain using xlim
hist(w1$vals,breaks=12,xlim=c(0,10))
hist(w1$vals,breaks=12,xlim=c(-1,2))
hist(w1$vals,breaks=12,xlim=c(0,2))
hist(w1$vals,breaks=12,xlim=c(1,1.3))
hist(w1$vals,breaks=12,xlim=c(0.9,1.3))

