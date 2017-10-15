#!/bin/sh

#set up directories and program file paths
rdp_classify=/mnt/c/Users/marc/OneDrive/rdp_classifier_2.12/dist/classifier.jar 
proc=data/process

# execute rdp classification
java -Xmx1g -jar $rdp_classify classify -c 0.5 -o $proc/select_fasta_classified.txt\
 -h $proc/select_hier.txt $proc/select_otus.fasta 


