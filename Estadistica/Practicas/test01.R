## try sqrt fun 

sqrt(25)


##  try for loops

max <- 0

my_array <- c(64, 3, 75, 14, 5) ## c() crea un vector, mientras que list() una lista

for (val in my_array) {
  print(val)
  if (val > max) {
    max <- val
  }
}

print(max)


## try mean() func

mean_test <- mean(my_array)

print(mean_test)


## try variance calculation

var = sum((my_list-mean_test)**2/(length(my_array)-1))
print(var)


var02 = var(my_array)
print(var02)


## try standard deviation

std01 = sqrt(var)
std02 = sd(my_array)

print(std01)
print(std02)


## - 
