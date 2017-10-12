# Set local variables
REFS = data/references
PROC = data/process


# Download the Koren data set 

$(PROC)/Koren2012_Abundance.csv\
$(PROC)/Koren2012_Metadata.csv\
$(PROC)/Koren2012_RepSeqs.fasta : 
	wget -N https://s3-us-west-2.amazonaws.com/test-data-for-candidates/Koren2012/Koren2012data.tar.gz
	tar xvzf Koren2012data.tar.gz
	mv Koren2012_Abundance.csv $(PROC)/
	mv Koren2012_Metadata.csv $(PROC)/
	mv Koren2012_RepSeqs.fasta $(PROC)/
	rm Koren2012data.tar.gz






