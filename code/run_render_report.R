# Script to render the overall report
# Marc Sze


# Load needed library
library("knitr")
library("rmarkdown")

# Render the final pdfs
render('report/interview_report.Rmd', clean = FALSE)


