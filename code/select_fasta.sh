#!/bin/sh

# Reference to get things working from the following resources:
	# http://itrylinux.com/use-sed-or-awk-to-remove-newline-breaks-from-fasta-file/
	# https://stackoverflow.com/questions/26144692/printing-a-sequence-from-a-fasta-file
	# https://stackoverflow.com/questions/7800482/in-bash-how-do-i-replace-r-from-a-variable-that-exist-in-a-file-written-using

# assign the data file to a variable and remove funky windows junk
otus=`cat data/process/select_otus | sed 's/\\r//g'`

# loop through and pull out each specific sequence from the rep otu file
for i in $otus;
do
	awk -v seq=$i -v RS='>' '$1 == seq {print RS $0}' data/process/Koren2012_RepSeqs.fasta >> data/process/temp.fasta	
done
# remove all the newlines except those with > before it
sed ':a;N;/^>/M!s/\n//;ta;P;D' data/process/temp.fasta > data/process/select_otus.fasta
# remove the temp fasta file
rm data/process/temp.fasta
