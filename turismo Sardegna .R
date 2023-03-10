#turismo sardegna 

#Questo dataset contiene la capacità delle strutture ricettive della Regione Sardegna riferita all'anno 2021. La capacità ricettiva misura la consistenza in termini di numero delle strutture ricettive e relativi posti letto e camere. I dati sono suddivisi per comune, mese e tipologia di struttura. La fonte del dato è l'anagrafica del SIRED, il sistema informativo di raccolta ed elaborazione dati fornito dalla Regione Sardegna alle Province che lo gestiscono a livello territoriale. Il SIRED contiene i periodi di apertura delle strutture ricettive così come da queste comunicati. Sono comprese nel conteggio tutte le strutture (e relativi posti letto) che risultano aperte almeno un giorno nell'anno.

movimenti2021= read.csv("turismoSardegna/capacita_strutture_ricettive_mensile_2021.csv")

view(movimenti2021)
summary(movimenti2021)
str(movimenti2021) #comune, anno, mese, Tipologia, Stelle, numero strutture, letti camere 
movimenti2021$Comune= as.factor(movimenti2021$Comune)
movimenti2021$Tipologia= as.factor(movimenti2021$Tipologia)
movimenti2021$Stelle= as.factor(movimenti2021$Stelle)
sum(is.na(movimenti2021)) #non sono presenti valori mancanti


summary(movimenti2021$Comune)/nrow(movimenti2021)

provenienza = read_csv("turismoSardegna/movimenti_macrotipologia_2021 _provenienza.csv")
#Il dataset raccoglie gli arrivi (numero di clienti ospitati negli esercizi ricettivi nel periodo considerato) e le presenze (numero di notti trascorse dai clienti negli esercizi ricettivi nel periodo considerato) dei turisti in Sardegna. I dati sono relativi all'anno 2021, e sono suddivisi per mese, macro-tipologia della struttura ricettiva, provenienza del turista (regione italiana o stato straniero) e provincia di pernottamento. I dati derivano dalle comunicazioni a fini statistici, obbligatorie per legge, che le strutture ricettive fanno alla Regione Sardegna
str(provenienza) #anno, provincia, mese, macrotipologia, macroprovenienza, provenienza, arrivi, presenze (numero di notti trascorse dai clienti)
view(provenienza)


provenienza$provincia= as.factor(provenienza$provincia)
provenienza$macro_tipologia= as.factor(provenienza$macro_tipologia)
provenienza$macro_provenienza= as.factor(provenienza$macro_provenienza)
provenienza$provenienza= as.factor(provenienza$provenienza)
sum(is.na(provenienza)) #sono presenti 114 valori mancanti 

provenienza_cleaned = na.omit(provenienza)



library("lubridate")
library("tidyverse")

?lubridate
mesi <-month(movimenti2021$Mese, label= T)

mesi
summary(mesi)

#1

movimenti2021 %>% 
  mutate(MonthLabel= month(Mese, label= T)) %>%
  ggplot(aes(MonthLabel, Letti )) + 
  geom_boxplot(coef=3) +
  geom_jitter(width= 0.1, alpha =0.2)

#Il grafico mostra la variazione del numero di posti letti durante l'anno 2021





#2
tipologia_ <- movimenti2021 %>% 
  group_by(Tipologia) %>%
  summarise(Letti = sum(Letti))

tipologia_

tipologia <-tipologia_ %>% 
  mutate(proportion= Letti/sum(Letti)) %>%
  mutate(tipologia2= reorder(Tipologia, proportion))

tipologia %>%
  ggplot(aes(tipologia2, proportion))+ 
  geom_bar(stat = "identity")+
  coord_flip()+
  theme(axis.text.y = element_text(size = 8)) +
  xlab("")
# il numero di posti letto offerto dagli alberghi durante l'anno è quasi doppio rispetto 
# al numero di letti di allogi privati. Si può inoltre affermare che il numero di posti 
#letto Campeggio è equiparabile al numero di posti letto di alloggi privati

#3
comuni_<- movimenti2021 %>% 
  group_by(Comune) %>%
  summarise(Numero.Strutture = sum(Numero.Strutture))

comuni_


comuni <-comuni_ %>% 
  mutate(proportion= Numero.Strutture/sum(Numero.Strutture)) %>%
  mutate(comuniSardi= reorder(Comune, proportion))

comuni %>% 
  top_n(30) %>% 
  ggplot(aes(comuniSardi, proportion))+ 
  geom_bar(stat = "identity")+
  coord_flip()+
  theme(axis.text.y = element_text(size = 8)) +
  xlab("")


# Si posso osservare i primi 30 comuni con con maggiore capacità ricettiva in 
#termini di numero di strutture durante l'anno. 
#Alghero risulta il comune col maggior numero di strutture nel 2021, di poco superiore a Olbia.

movimenti2021$Numero.Strutture



filter(movimenti2021) %>% 
  ggplot(aes(Camere, Numero.Strutture, color= Tipologia)) +
  geom_point() 

# Il numero di strutture di Alloggi privati e Bed and breakfast è notevolmente superiore al numero di Alberghi. 
# strutture private e Bed and breakfast mostrano inoltre un gran numero di camere paragonabile al numero di 
# camere della tipologia Albergo.

#4
summary(movimenti2021$Letti)
summary(movimenti2021$Camere)
summary(movimenti2021$Numero.Strutture)

filter(movimenti2021) %>% 
  arrange(desc( Camere))%>% 
  head(100) %>%
  ggplot(aes(Camere, Letti, color= Comune)) +
  geom_point()



# il grafico mostra i comuni che hanno il maggior numero di strutture ricettive 
#mostrando anche il numero di camere. 
#

arrivi_luogo_provenienza<- provenienza_cleaned %>% 
  group_by(provenienza) %>%
  summarise(arrivi = sum(arrivi))

arrivi_luogo_provenienza

arrivi_luogo_provenienza <-arrivi_luogo_provenienza%>% 
  mutate(proportion= arrivi/sum(arrivi)) %>%
  mutate (provenienza_turisti= reorder(provenienza, proportion))

arrivi_luogo_provenienza %>% 
  top_n(30) %>% 
  ggplot(aes(provenienza_turisti, proportion))+ 
  geom_bar(stat = "identity")+
  coord_flip()+
  theme(axis.text.y = element_text(size = 8)) +
  xlab("")

#Si può osservare che la maggior parte dei turisti proviene da Sardegna (oltre il 20%) e Lombardia. Si osserva che 
#i turisti stranieri provengono maggiormente da Germania, Francia e Svizzera. 
   

library("gridExtra")

# macro-provenienza

arrivi_provenienza<- provenienza_cleaned %>% 
  group_by(macro_provenienza) %>%
  summarise(arrivi = sum(arrivi))

arrivi_provenienza

macro_provenienza<- arrivi_provenienza%>% 
  mutate(proportion= arrivi/sum(arrivi)) %>%
  mutate(macro_provenienza = reorder(macro_provenienza, proportion))

macro_provenienza

macro_provenienza <- macro_provenienza %>%         
  ggplot(aes(macro_provenienza, proportion))+
  geom_bar(stat = "identity") +
  coord_flip()+
  theme(axis.text.y = element_text(size = 8)) +
  xlab("")

#tipologia

arrivi_tipologia<- provenienza_cleaned %>% 
  group_by(macro_tipologia)  %>% 
  summarise(arrivi = sum(arrivi))

arrivi_tipologia

macro_tipologia <- arrivi_tipologia %>% 
  mutate(proportion= arrivi/sum(arrivi)) %>%
  mutate(macro_tipologia = reorder(macro_tipologia, proportion)) 

macro_tipologia<-macro_tipologia %>%
  ggplot(aes(macro_tipologia, proportion))+
  geom_bar(stat = "identity") +
  coord_flip() +
  theme(axis.text.x = element_text(size = 8)) +
  xlab("")



# 
grid.arrange(macro_provenienza, macro_tipologia)

#La proporzione di turisti italiani è quasi doppia rispetto ai turisti stranieri
#Si può inoltre affermare che la maggior parte dei turisti preferiscono pernottare in una struttura recettiva Alberghiera.


arrivi_mese<- provenienza_cleaned %>% 
  group_by(mese)  %>% 
  summarise(arrivi = sum(arrivi))

arrivi_mese

arrivi_mese %>% 
  mutate(MonthLabel= month(mese, label= T)) %>%
  ggplot(aes(MonthLabel, arrivi))+
  geom_bar(stat = "identity")

# Il mese in cui le strutture recettive ricevono il maggior numero di turisti è 
# agosto, seguito da luglio, settembre e giugno. In seguito, si osserva ottobre 
# con oltre 200 mila arrivi, mentre nei restanti mesi gli arrivi non superano mai quota 100 mila.



provincia_provenienza<- provenienza_cleaned %>% 
  group_by(provenienza, provincia) %>%
  summarise(arrivi = sum(arrivi), presenze = sum(presenze )) 
 
  
filter(provincia_provenienza) %>% 
  ggplot(aes(presenze, arrivi, color= provincia)) +
  geom_point() 

# per quanto rigurada il pernottamento, i turisti raggruppati in base alla provenienza 
# e alla provincia di destinazione trascorrono un numero di notti 
# superire nella provincia di Sassari rispetto alle altre province.


filter(provincia_provenienza, provenienza != "Sardegna") %>%
  arrange(desc(presenze)) %>%
  head(300) %>%
  ggplot(aes(provincia, presenze)) + 
  geom_boxplot(coef=3) +
  geom_jitter(width= 0.1, alpha =0.2)

```
