library(stringr)
library(dplyr)

#The whole pcap file is approx. 33gb 
#We extracted 4.29 gb from that file, 5.005337 million packet observations
#We looked at the first 500,000 obs
pcap <- read.csv('/Users/julinazhang/Desktop/Capstone Project : DS 6001/pcap portion sample', header=TRUE)
pcap_portion <- pcap

#packet attributes: time (arrival time in terms of how many second
#passed since the start of packet collection), 
#source ip, destination ip, protocol type, length, source port, destination port, tcp flags

#grab relevant connection
within_network <- grep('128.143.[1-9]+.[1-9]+',pcap_portion$Source) #within UVa network
within_cav_network <- grep('137.54.[1-9]+.[1-9]+', pcap_portion$Source) #cavalier network

pcap_portion <- rbind(pcap_portion[within_network,], pcap_portion[within_cav_network])
pcap_portion <- data.frame(pcap_portion)
#259078

#looked at basic summary statistics 

################################################################################################

#unique ip counts
unique(pcap_portion$Source)
#2457
unique(pcap_portion$Destination)
#7166


#Duration
time <- max(pcap_portion$Time) - min(pcap_portion$Time)
time
#duration: 103.9736

#unique protocol
unique(pcap_portion$Protocol)
#59

#mean length
mean(pcap_portion$Length)
#703.5365

#source ip table
sourceip_count <- table(pcap_portion$Source)
sourceip_sorted <- sort(sourceip_count, decreasing = TRUE)
head(sourceip_sorted, 10)


# 128.143.83.171  128.143.62.161  128.143.235.53 128.143.109.123  128.143.22.145  128.143.22.101 
# 28713           19123           12179            9895            7580            7439 
# 128.143.24.118  128.143.122.15  128.143.94.179   128.143.42.33 
# 7078            6670            4748            4307 



#destination ip table
destip_count <- table(pcap_portion$Destination)
destip_sorted <- sort(destip_count, decreasing = TRUE)
head(destip_sorted, 10)

# 172.217.2.206 131.247.250.90   17.248.134.9   17.132.28.29 213.159.210.43   17.132.19.27   54.210.85.13 
# 13656           9892           9031           5260           5070           4826           4617 
# 173.194.7.42 143.215.203.33  129.24.124.76 
# 4580           4436           4307 


##############################################################################

#combine source ip and destination ip to be our key
for(i in 1:nrow(pcap_portion)){
  pcap_portion$key[i] <- paste(as.character(pcap_portion$Source[i]), as.character(pcap_portion$Destination[i]), sep = '_')
}

unique_key <- unique(pcap_portion$key)
#11448 unique connections

#count how many times each key appears --> Kerry's isolation forest algorithm
by_key_protol <- group_by(pcap_portion, key, Protocol)
temp <- summarise(by_key_protol, freq = n(), mean_length = mean(Length))
write.table(temp, file="new_key_protocol", row.names=F, col.names=T, sep=",")




##############################################################################


##############################################################################
#                           Word Cloud                                       #  
##############################################################################

library('tm')
library('wordcloud')
library(SnowballC)

jeopCorpus <- Corpus(VectorSource(pcap_portion$Protocol))
wordcloud(jeopCorpus, max.words = 100, random.order = FALSE, random.color = TRUE)









##############################################################################

##############################################################################
#                         Extra Stuff                                        #  
##############################################################################

key_freq <-  summarize(group_by_(pcap_portion, by = c('key','Protocol'), count = n()))
key_length_mean <- summarize(group_by_(pcap_portion, by = c('key', 'Protocol')))



#less frequent-occuring connection
#ex: one-time instances --> singletons  (threshold is set to 1 for now; may need to change the threshold)
one_time_instances <- key_summary[key_summary$count == 1,]
nrow(one_time_instances)  # 1592



##############################################################################

#why do we want to extract less frequent occuring instances?
#our intuition is that frequent-occuring connections do not pose a threat to the netowrk;
#otherwise, it would have been detected
#those that do not occur often should receive more attention

#we would continously update the set of one-time instances with new packet observations
#if the frequency count of a connection is greater than the threshold after the update, we would remove that
#connection from the set



##############################################################################
#we also looked at the protocols

#type of protocol --> 67 protocols
unique(pcap$Protocol) 

# [1] UDP         ESP         TLSv1.2     TCP         DTLSv1.0    HTTP        SSH         Chargen     SMTP        TLSv1       SSL         QUIC       
# [13] IPv4        ICMP        CFLOW       DNS         VNC         SSLv2       ADP         ISAKMP      TELNET      NBNS        Syslog      CLDAP      

# [25] SSLv3       GVSP        NTP         RTMP        RTCP        PPP Comp    HTTP/XML    TPKT        TLSv1.1     OCSP        CUPS        SSHv2      
# [37] Auto-RP     STUN        ICMPv6      ECHO        AFP         MPTCP       GRE         H.225.0     SSDP        DB-LSP-DISC BJNP        EIGRP      
# [49] DSI         OpenVPN     XMPP/XML    IMF         UDPENCAP    SNMP        KRB5        GTP         BROWSER     BACnet-APDU LDAP       

protocol_freq <- table(pcap$Protocol)
protocol_freq
protocol_sorted <- sort(protocol_freq, decreasing = TRUE)
head(protocol_sorted, 10) #TCP appears the most, unsurprisingly
# TCP    QUIC TLSv1.2     UDP    HTTP     SSH     ESP    Chargen    IPv4     DNS 
# 60569   13663    8338    4127    3369    1491    1380    1146     873     814 




##############################################################################
#does different protocol have different mean lengths?
length_summary <- summarise(group_by_(pcap_portion, by = 'Protocol'), length_mean = mean(Length), length_sd = sd(Length))





