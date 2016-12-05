library(stringr)
library(dplyr)

#The whole pcap file is approx. 33gb 
#We extracted 4 gb from that file, approximately 5 million packet observations
#We looked at the first 100,000 obs
pcap <- read.csv('/Users/julinazhang/Desktop/Capstone Project : DS 6001/pcap portion sample', header=TRUE)


#deal with a portion of it for now
pcap_portion <- pcap[1:100000,]

#packet attributes: time (second passed since the start of packet collection), 
#source ip, destination ip, protocol type, length, source port, destination port, tcp flags


#looked at basic summary statistics 

################################################################################################

#source ip count
unique(pcap_portion$Source)  
#14387 different source ip addresses 

sourceip_count <- table(pcap_portion$Source)
sourceip_sorted <- sort(sourceip_count, decreasing = TRUE)
head(sourceip_sorted, 10)

# 128.143.83.171  128.143.62.161  128.143.235.53 128.143.109.123   172.217.2.206  109.247.140.91  128.143.22.101   128.143.228.5  128.143.122.15 
# 7707            3346            2333            2187            1891            1730            1501            1356            1261 
# 
# 128.143.22.145 
# 1174 

#addresses that start with 128.143: within the uva network
#172.217.2.206: google search page
#109.247.140.91: located in Norway

time <- max(pcap_portion$Time) - min(pcap_portion$Time)
time
#100000 packet captures for 101.602 seconds


##############################################################################

#destination ip count
destip_count <- table(pcap_portion$Destination)
destip_sorted <- sort(destip_count, decreasing = TRUE)
head(destip_sorted, 10)
# 128.143.83.171   172.217.2.206  131.247.250.90    173.194.7.42  128.143.62.161  128.143.204.31    17.248.134.9  128.143.235.53  128.143.22.145 
# 4720            2758            2187            2174            2126            1730            1718            1486            1222 
# 
# 128.143.109.123 
# 1128 

#top destip: 1. uva, 2. google, 3. University of South Florida
#https://db-ip.com/all/17.248.134
#17.248.134.0 - 17.248.134.255 is an IP address range owned by Apple Inc.
#17.248.134.9: the ip address for Apple 
#possible reason for occuring so frequent: mac users sending error reports to Apple


pcap_portion$Protocol
##############################################################################

#focus of our study: data going out of the UVa network
#so we are analyzing packets that have source ip starting with 128.143

#grab source ips that start with 128.143
within_network <- grep('128.143.[1-9]+.[1-9]+',pcap_portion$Source)
within_cav_network <- grep('137.54.[1-9]+.[1-9]+', pcap_portion$Source)

pcap_portion <- rbind(pcap_portion[within_network,], pcap_portion[within_cav_network])
pcap_portion <- data.frame(pcap_portion)
#52130 observations; a little over half of all the observations


#combine source ip and destination ip to be our key
for(i in 1:nrow(pcap_portion)){
  pcap_portion$key[i] <- paste(as.character(pcap_portion$Source[i]), as.character(pcap_portion$Destination[i]), sep = '_')
  
}

unique(pcap_portion$key)
#3407 unique observations


#count how many times each key appears --> Kerry's isolation forest algorithm
by_key_protol <- group_by(pcap_portion, key, Protocol)
temp <- summarise(by_key_protol, freq = n(), mean_length = mean(Length))
write.table(temp, file="key_protocol", row.names=F, col.names=T, sep=",")


library('tm')
library('wordcloud')
library(SnowballC)

jeopCorpus <- Corpus(VectorSource(pcap_portion$Protocol))
wordcloud(jeopCorpus, max.words = 100, random.order = FALSE, random.color = TRUE)




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





