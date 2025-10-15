### Loading libraries
required_libraries <- c(
    "data.table",
    "dplyr",
    "optparse",
    "rlang",
    "ggplot2")

for (lib in required_libraries) {
  suppressPackageStartupMessages(
    library(lib, character.only = TRUE,
            quietly = TRUE))
}

### Options
options(stringsAsFactors = FALSE)

### Command line options
option_list <- list(

    optparse::make_option(
        c("-e", "--expression"),
        type = "character",
        default = NULL,
        help = "Path to the expression file.",
        metavar = "character"),
    optparse::make_option(
        c("-m", "--metadata"),
        type = "character",
        default = NULL,
        help = "Path to the clean metadata RData file.",
        metavar = "character"),
    optparse::make_option(
        c("-v", "--visualization_var"),
        type = "character",
        default = NULL,
        help = "Variable to visualize, one of the column names of the metadata",
        metavar = "character"),
    optparse::make_option(
        c("-o", "--output_file"),
        type = "character",
        default = NULL,
        help = "Path to the output pdf file",
        metavar = "character")
)

opt_parser <- optparse::OptionParser(option_list = option_list)
opt <- optparse::parse_args(opt_parser)

## Initialize variable
METADATA_FILE <- opt$metadata
EXPRESSION_FILE <- opt$expression
VARIABLE <- opt$visualization_var
OUTPUT_FILE <- opt$output_file


## Debug
# EXPRESSION_FILE <- "data/dataset1/filtered_expression.tsv"
# METADATA_FILE <- "results_old/snakemake_results/filtered_metadata.RData"
# OUTPUT_FILE <- "test.pdf"
# VARIABLE <- "sample_type"


## Functions
source("workflow/bin/perform_dimensionality_reduction_fn.R")

## Dimensionality reduction
expression_df <- read_indegree(EXPRESSION_FILE)
metadata_df <- get(load(METADATA_FILE))
metadata_df <- match_metadata_order_with_df(metadata_df, expression_df)

expression_df <- expression_df[!rowSums(expression_df) == 0,]

pca <- do_pca(expression_df)
pcaplot <- plot_12_discrete(pca, metadata_df, VARIABLE)

## Exporting
pdf(OUTPUT_FILE)
pcaplot
dev.off()
