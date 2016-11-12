#analysis u2b
#Copyright (C) 2016  Filippo Valle (mail@fvalle.me)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should read a copy of the license at https://www.gnu.org/licenses/gpl-3.0.html
#
#run source("/Users/Filippo/Desktop/uni2b/analysis.R")
#path
path<-"/Users/Filippo/Desktop/uni2b/"

library(rpart)
library(rattle)
library(rpart.plot)
library(RColorBrewer)
library(randomForest)
library(RCurl)

set.seed(314)
start <- Sys.time()

print("analisys.R  Copyright (C) 2016 Filippo Valle")

#leggo file
train_path <- paste(path,"train.csv", sep="") 
if(!exists("train_old")) train_old <-read.csv(file=train_path)
 
train <- train_old

print("train loaded")
 

test_path <- paste(path,"test.csv", sep="")
if(!exists("test_old")) test_old <- read.csv(file=test_path)
test <- test_old

print("test loaded")


#Metto mediana punteggio dove non c'è

train$Punteggio[train$Punteggio==" equipment or floor not properly drained"]<-16
#train$Punteggio <- as.numeric(levels(train$Punteggio))[train$Punteggio]
print("media punteggio train: ")
meanPunteggio<-median(train$Punteggio, na.rm = TRUE)
print(meanPunteggio)
train$Punteggio[train$Punteggio=="NA"] <- meanPunteggio
train$Punteggio[is.na(train$Punteggio)] <- meanPunteggio

test$Punteggio[test$Punteggio==" equipment or floor not properly drained"]<-16
print("media punteggio test: ")
meanPunteggio <- median(test$Punteggio, na.rm = TRUE)
print(meanPunteggio)
test$Punteggio[test$Punteggio=="NA"] <- meanPunteggio
test$Punteggio[is.na(test$Punteggio)] <- meanPunteggio
test$Punteggio[test$Punteggio==test_old$Punteggio[86001]] <-meanPunteggio
test$Punteggio <- as.numeric(test$Punteggio)


print("ok punteggio")

#Assegno coefficienti di livelllo

train$Coefficiente.di.livello<-"D"
train$Coefficiente.di.livello[train$Punteggio<=27]<-"B"
train$Coefficiente.di.livello[train$Punteggio<=13]<-"A"
train$Coefficiente.di.livello[train$Punteggio>27]<-"C"
train$Coefficiente.di.livello <- factor(train$Coefficiente.di.livello)

test$Coefficiente.di.livello<-"D"
test$Coefficiente.di.livello[test$Punteggio<=27]<-"B"
test$Coefficiente.di.livello[test$Punteggio<=13]<-"A"
test$Coefficiente.di.livello[test$Punteggio>27]<-"C"
test$Coefficiente.di.livello <- factor(test$Coefficiente.di.livello)


print("ok CL")

#creo variabile Azione da stimare nel set test 

test$Azione<-""
train$Azione<-factor(train$Azione)

print("ok azione")

#correggo criticità in test

test$Criticità[test$Criticità==" anti-siphonage or backflow prevention device not provided where required"]<-"Critical"
test$Criticità <- factor(test$Criticità)

print("ok criticità")

#correggo tipo cucina

test$Tipo.cucina[test$Tipo.cucina=="Californian"]<-"American"
test$Tipo.cucina[test$Tipo.cucina=="Hawaiian"]<-"American"
test$Tipo.cucina[test$Tipo.cucina=="Nuts/Confectionary"]<-"Bottled beverages, including water, sodas, juices, etc."
test$Tipo.cucina[test$Tipo.cucina=="Soups"]<-"oups & Sandwiches"
test$Tipo.cucina[test$Tipo.cucina=="Southwestern"]<-"American"

#Faccio macro categorie per rientrare nelle 53 richieste

train$Tipo.cucina[train$Tipo.cucina=="Armenian"]<-"Asian"
train$Tipo.cucina[train$Tipo.cucina=="Afghan"]<-"Asian"
train$Tipo.cucina[train$Tipo.cucina=="Bangladeshi"]<-"Asian"
train$Tipo.cucina[train$Tipo.cucina=="Caribbean"]<-"American"
train$Tipo.cucina[train$Tipo.cucina=="Chinese/Cuban"]<-"Chinese"
train$Tipo.cucina[train$Tipo.cucina=="Chinese/Japanese"]<-"Chinese"
train$Tipo.cucina[train$Tipo.cucina=="Creole/Cajun"]<-"Creole"
train$Tipo.cucina[train$Tipo.cucina=="Czech"]<-"Eastern European"
train$Tipo.cucina[train$Tipo.cucina=="Donuts"]<-"Other"
train$Tipo.cucina[train$Tipo.cucina=="Egyptian"]<-"African"
train$Tipo.cucina[train$Tipo.cucina=="Ethiopian"]<-"African"
train$Tipo.cucina[train$Tipo.cucina=="Filipino"]<-"Asian"
train$Tipo.cucina[train$Tipo.cucina=="Greek"]<-"Mediterranean"
train$Tipo.cucina[train$Tipo.cucina=="Hotdogs/Pretzels"]<-"Hotdogs"
train$Tipo.cucina[train$Tipo.cucina=="Hawaiian"]<-"American"
train$Tipo.cucina[train$Tipo.cucina=="Indonesian"]<-"Asian"
train$Tipo.cucina[train$Tipo.cucina=="Iranian"]<-"Asian"
train$Tipo.cucina[train$Tipo.cucina=="Korean"]<-"Asian"
train$Tipo.cucina[train$Tipo.cucina=="Moroccan"]<-"African"
train$Tipo.cucina[train$Tipo.cucina=="Nuts/Confectionary"]<-"Other"
train$Tipo.cucina[train$Tipo.cucina=="Pizza/Italian"]<-"Italian"
train$Tipo.cucina[train$Tipo.cucina=="Sandwiches"]<-"Sandwiches/Salads/Mixed Buffet"
train$Tipo.cucina[train$Tipo.cucina=="Southwestern"]<-"American"
train$Tipo.cucina[train$Tipo.cucina=="Tex-Mex"]<-"Mexican"
train$Tipo.cucina[train$Tipo.cucina=="Tapas"]<-"Mexican"
train$Tipo.cucina[train$Tipo.cucina=="Thai"]<-"Asian"
train$Tipo.cucina[train$Tipo.cucina=="Turkish"]<-"Eastern European"
train$Tipo.cucina[train$Tipo.cucina=="Vietnamese/Cambodian/Malaysia"]<-"Asian"
train$Tipo.cucina[train$Tipo.cucina=="Salads"]<-"Juice, Smoothies, Fruit Salads"


test$Tipo.cucina[test$Tipo.cucina=="Armenian"]<-"Asian"
test$Tipo.cucina[test$Tipo.cucina=="Afghan"]<-"Asian"
test$Tipo.cucina[test$Tipo.cucina=="Bangladeshi"]<-"Asian"
test$Tipo.cucina[test$Tipo.cucina=="Caribbean"]<-"American"
test$Tipo.cucina[test$Tipo.cucina=="Chinese/Cuban"]<-"Chinese"
test$Tipo.cucina[test$Tipo.cucina=="Chinese/Japanese"]<-"Chinese"
test$Tipo.cucina[test$Tipo.cucina=="Creole/Cajun"]<-"Creole"
test$Tipo.cucina[test$Tipo.cucina=="Czech"]<-"Eastern European"
test$Tipo.cucina[test$Tipo.cucina=="Donuts"]<-"Other"
test$Tipo.cucina[test$Tipo.cucina=="Egyptian"]<-"African"
test$Tipo.cucina[test$Tipo.cucina=="Ethiopian"]<-"African"
test$Tipo.cucina[test$Tipo.cucina=="Filipino"]<-"Asian"
test$Tipo.cucina[test$Tipo.cucina=="Greek"]<-"Mediterranean"
test$Tipo.cucina[test$Tipo.cucina=="Hotdogs/Pretzels"]<-"Hotdogs"
test$Tipo.cucina[test$Tipo.cucina=="Indonesian"]<-"Asian"
test$Tipo.cucina[test$Tipo.cucina=="Iranian"]<-"Asian"
test$Tipo.cucina[test$Tipo.cucina=="Korean"]<-"Asian"
test$Tipo.cucina[test$Tipo.cucina=="Moroccan"]<-"African"
test$Tipo.cucina[test$Tipo.cucina=="Pizza/Italian"]<-"Italian"
test$Tipo.cucina[test$Tipo.cucina=="Sandwiches"]<-"Sandwiches/Salads/Mixed Buffet"
test$Tipo.cucina[test$Tipo.cucina=="Tex-Mex"]<-"Mexican"
test$Tipo.cucina[test$Tipo.cucina=="Tapas"]<-"Mexican"
test$Tipo.cucina[test$Tipo.cucina=="Thai"]<-"Asian"
test$Tipo.cucina[test$Tipo.cucina=="Turkish"]<-"Eastern European"
test$Tipo.cucina[test$Tipo.cucina=="Vietnamese/Cambodian/Malaysia"]<-"Asian"
test$Tipo.cucina[test$Tipo.cucina=="Salads"]<-"Juice, Smoothies, Fruit Salads"



train$Tipo.cucina<-factor(train$Tipo.cucina)
test$Tipo.cucina<-factor(test$Tipo.cucina)

print("ok cucina")

#Correggo tipo ispezione

test$Tipo.ispezione[test$Tipo.ispezione=="Not Yet Graded"]<-"Administrative Miscellaneous / Initial Inspection"  #suppongo che non valutato avrà almeno un'ispezione...
test$Tipo.ispezione[test$Tipo.ispezione=="Smoke-Free Air Act / Limited Inspection"]<-"Smoke-Free Air Act / Compliance Inspection"
test$Tipo.ispezione[test$Tipo.ispezione=="Inter-Agency Task Force / Re-inspection"]<-"Inter-Agency Task Force / Initial Inspection"
test$Tipo.ispezione[test_old$Tipo.ispezione==""]<-"Administrative Miscellaneous / Initial Inspection"
test$Tipo.ispezione[test_old$Tipo.ispezione=="A"]<-"Administrative Miscellaneous / Initial Inspection"
test$Tipo.ispezione[test_old$Tipo.ispezione=="B"]<-"Administrative Miscellaneous / Initial Inspection"
test$Tipo.ispezione[test_old$Tipo.ispezione=="C"]<-"Calorie Posting / Re-inspection"
test$Tipo.ispezione[test_old$Tipo.ispezione=="P"]<-"Administrative Miscellaneous / Initial Inspection"
test$Tipo.ispezione[test_old$Tipo.ispezione=="Z"]<-"Administrative Miscellaneous / Initial Inspection"
test$Tipo.ispezione[is.na(test_old$Tipo.ispezione)]<-"Administrative Miscellaneous / Initial Inspection"
test$Tipo.ispezione<-factor(test$Tipo.ispezione)

print("ok ispezione")

#cerco "zone"
train$Zona <- NA
train$Codice.Postale[which.max(train$Codice.Postale)]
train$Codice.Postale[which.min(train$Codice.Postale)]

train$Zona[(train$Codice.Postale<10100)] <-"Q"
train$Zona[(train$Codice.Postale>=10100)&(train$Codice.Postale<10200)] <-"W"
train$Zona[(train$Codice.Postale>=10200)&(train$Codice.Postale<10300)] <-"E"
train$Zona[(train$Codice.Postale>=10300)&(train$Codice.Postale<10400)] <-"R"
train$Zona[(train$Codice.Postale>=10400)&(train$Codice.Postale<10500)] <-"T"
train$Zona[(train$Codice.Postale>=10500)&(train$Codice.Postale<10600)] <-"Y"
train$Zona[(train$Codice.Postale>=10600)&(train$Codice.Postale<10700)] <-"U"
train$Zona[(train$Codice.Postale>=10700)&(train$Codice.Postale<10800)] <-"I"
train$Zona[(train$Codice.Postale>=10800)&(train$Codice.Postale<10900)] <-"O"
train$Zona[(train$Codice.Postale>=10900)&(train$Codice.Postale<11000)] <-"P"
train$Zona[(train$Codice.Postale>=11000)&(train$Codice.Postale<11100)] <-"A"
train$Zona[(train$Codice.Postale>=11100)&(train$Codice.Postale<11200)] <-"S"
train$Zona[(train$Codice.Postale>=11200)&(train$Codice.Postale<11300)] <-"D"
train$Zona[(train$Codice.Postale>=11300)&(train$Codice.Postale<11400)] <-"F"
train$Zona[(train$Codice.Postale>=11400)&(train$Codice.Postale<11500)] <-"G"
train$Zona[(train$Codice.Postale>=11500)&(train$Codice.Postale<11600)] <-"H"
train$Zona[(train$Codice.Postale>=11600)] <-"J"

train$Zona <- factor(train$Zona)

test$Zona <- NA
test$Codice.Postale[which.max(test$Codice.Postale)]
test$Codice.Postale[which.min(test$Codice.Postale)]

test$Zona[(test$Codice.Postale<10100)] <-"Q"
test$Zona[(test$Codice.Postale>=10100)&(test$Codice.Postale<10200)] <-"W"
test$Zona[(test$Codice.Postale>=10200)&(test$Codice.Postale<10300)] <-"E"
test$Zona[(test$Codice.Postale>=10300)&(test$Codice.Postale<10400)] <-"R"
test$Zona[(test$Codice.Postale>=10400)&(test$Codice.Postale<10500)] <-"T"
test$Zona[(test$Codice.Postale>=10500)&(test$Codice.Postale<10600)] <-"Y"
test$Zona[(test$Codice.Postale>=10600)&(test$Codice.Postale<10700)] <-"U"
test$Zona[(test$Codice.Postale>=10700)&(test$Codice.Postale<10800)] <-"I"
test$Zona[(test$Codice.Postale>=10800)&(test$Codice.Postale<10900)] <-"O"
test$Zona[(test$Codice.Postale>=10900)&(test$Codice.Postale<11000)] <-"P"
test$Zona[(test$Codice.Postale>=11000)&(test$Codice.Postale<11100)] <-"A"
test$Zona[(test$Codice.Postale>=11100)&(test$Codice.Postale<11200)] <-"S"
test$Zona[(test$Codice.Postale>=11200)&(test$Codice.Postale<11300)] <-"D"
test$Zona[(test$Codice.Postale>=11300)&(test$Codice.Postale<11400)] <-"F"
test$Zona[(test$Codice.Postale>=11400)&(test$Codice.Postale<11500)] <-"G"
test$Zona[(test$Codice.Postale>=11500)&(test$Codice.Postale<11600)] <-"H"
test$Zona[(test$Codice.Postale>=11600)] <-"J"

test$Zona <- factor(test$Zona)

print("ok zona")

#cerco Quartiere in modo da togliere Missing

p_quartiere <-rpart(Quartiere ~ Zona + Codice.Postale, data=train[!train_old$Quartiere=="Missing",])
train$Quartiere[train_old$Quartiere=="Missing"] <- predict(p_quartiere, train[train_old$Quartiere=="Missing",], type="class")
test$Quartiere[test_old$Quartiere=="Missing"] <- predict(p_quartiere, test[test_old$Quartiere=="Missing",], type="class")
train$Quartiere <- factor(train$Quartiere)
test$Quartiere <- factor(test$Quartiere)

pdf(paste(path,"p_quartiere.pdf",sep=""))
fancyRpartPlot(p_quartiere)
dev.off()

print("ok quartiere")

#cerco area telefonica
train$Prefisso.telefono <- 0
train$Prefisso.telefono <- substring(train$Telefono,1,3)
train$Prefisso.telefono <- as.numeric(train$Prefisso.telefono)

test$Prefisso.telefono <- 0
test$Prefisso.telefono <- substring(test$Telefono,1,3)
test$Prefisso.telefono <- as.numeric(test$Prefisso.telefono)


p_prefisso <- rpart(Prefisso.telefono ~ Quartiere+Codice.Postale+Zona, data=train[!is.na(train$Prefisso.telefono),],method="anova",control = rpart.control(minsplit = 1000, cp = 0))
train$Prefisso.telefono[is.na(train$Prefisso.telefono)] <- predict(p_prefisso, train[is.na(train$Prefisso.telefono),])

print("ok prefisso")

print("train:")
str(train)
print("...")
print("...")
print("...")
print("test:")
str(test)

print("Dati pronti")
temp <- Sys.time()
print(temp-start)



#cerco variabili con peso maggiore con pochi alberi (esegui solo prima volta)
#my_forest <- randomForest(as.factor(Azione) ~ Criticità+Tipo.ispezione+Quartiere+Coefficiente.di.livello+Punteggio+Codice.Postale+Tipo.cucina+Zona+Prefisso.telefono, data=train, importance=TRUE, na.action = na.omit, ntree=10)


#randomforest
my_forest <- randomForest(as.factor(Azione) ~ Criticità+Tipo.ispezione+Quartiere+Coefficiente.di.livello+Punteggio+Codice.Postale+Tipo.cucina+Zona+Prefisso.telefono, data=train, importance=TRUE,na.action = na.omit, ntree=5000)

#how important?
pdf(paste(path,"forest_graph.pdf",sep=""))
varImpPlot(my_forest)
dev.off()

#varImpPlot(my_forest)

print("Foresta completata!")
print(Sys.time()-temp)
temp <- Sys.time()

#faccio previsione

my_prediction <- predict(my_forest, test, type = "class")

#mi riconduco alle classi richieste
my_prediction[my_prediction=="Establishment re-closed by DOHMH"] <- "Establishment closed."
my_prediction[my_prediction=="Establishment re-opened by DOHMH"] <- "No violations recorded after the inspection."
my_prediction <- factor(my_prediction)

test$Azione <- my_prediction

#metto 1 nel test
test_old$No.violations.recorded.after.the.inspection. <- 0
test_old$Violations.recorded.after.the.inspection. <- 0
test_old$Establishment.closed. <- 0
test_old$No.violations.recorded.after.the.inspection.[my_prediction=="No violations recorded after the inspection."]<-1
test_old$Violations.recorded.after.the.inspection.[my_prediction=="Violations recorded after the inspection."]<-1
test_old$Establishment.closed.[my_prediction=="Establishment closed."]<-1

my_solution <- data.frame(ID.sfida=test$ID.sfida, ID = test$ID, Azione=test$Azione, No.violations.recorded.after.the.inspection. = test_old$No.violations.recorded.after.the.inspection., Violations.recorded.after.the.inspection.=test_old$Violations.recorded.after.the.inspection., Establishment.closed.=test_old$Establishment.closed.)

print("fatta previsione")
print(Sys.time()-temp)
temp<-Sys.time()

print("scrivo file..")
#scrivo file
write.csv(test_old, file = paste(path,"submit.csv",sep=""), row.names = FALSE)
write.csv(my_solution, file = paste(path,"submit_easy.csv",sep=""), row.names = FALSE)
print(Sys.time()-temp)
postForm('https://maker.ifttt.com/trigger/uni2b/with/key/95ZnJdPvDZmBx8yfEy6WL', value1=Sys.time()-start) #invia email per avvisare che ha finito!
print("finito :-)")
print(Sys.time()-start)
print("...................................")