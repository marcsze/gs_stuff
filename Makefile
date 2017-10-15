# Set local variables
REFS = data/references
PROC = data/process
TABLES = data/process/tables
FIGS = results/figures

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

# Run the NMDS generation code
$(TABLES)/nmds_data.csv : $(PROC)/Koren2012_Metadata.csv\
			$(PROC)/Koren2012_Abundance.csv\
			code/run_nmds.R
	R -e "source('code/run_nmds.R')"

# Run the RF model generation code
$(TABLES)/probability_scores.csv\
$(TABLES)/imp_otus_to_model.csv : $(PROC)/Koren2012_Metadata.csv\
			$(PROC)/Koren2012_Abundance.csv code/run_model.R
	 R -e "source('code/run_model.R')"

# Run the taxonomic classification code
$(PROC)/select_otus\
$(PROC)/select_otus.fasta\
$(PROC)/select_fasta_classified.txt : $(TABLES)/imp_otus_to_model.csv\
			$(PROC)/Koren2012_RepSeqs.fasta code/run_get_imp_otu_list.R\
			code/select_fasta.sh code/run_rdp.sh
	 R -e "source('code/run_get_imp_otu_list.R')"
	 bash code/select_fasta.sh
	 bash code/run_rdp.sh

# Run the wilcoxson test on the RF probabilities
results/tables/wilcox_comparisons.csv : $(PROC)/probability_scores.csv\
			code/run_wilcoxson_test.R
	 R -e "source('code/run_wilcoxson_test.R')"

# Create the first figure to be used (NMDS)
$(FIGS)/nmds_figure.tiff : $(TABLES)/nmds_data.csv\
			$(PROC)/Koren2012_Metadata.csv code/make_fig3.R
	 R -e "source('code/make_fig3.R')"

# Create Probability Graph from RF model
$(FIGS)/prbability_figure.tiff : $(PROC)/probability_scores.csv code/make_fig1.R
	 R -e "source('code/make_fig1.R')"

# Create Top 30 OTUs to RF Model Figure ranked by MDA
$(FIGS)/imp_otu_figure.tiff : $(TABLES)/imp_otus_to_model.csv\
			$(PROC)/select_fasta_classified.txt code/make_fig2.R
	 R -e "source('code/make_fig2.R')"

# Create the html report file
report/interview_report.html : $(FIGS)/nmds_figure.tiff\
			$(FIGS)/prbability_figure.tiff $(FIGS)/imp_otu_figure.tiff\
			results/tables/wilcox_comparisons.csv\
			report/interview_report.Rmd
	 R -e "source('code/run_render_report.R')"






