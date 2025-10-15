### Loading libraries
required_libraries <- c(
    "data.table",
    "dplyr",
    "optparse",
    "rlang")

for (lib in required_libraries) {
  suppressPackageStartupMessages(library(lib, character.only = TRUE, quietly = TRUE))
}

### Options
options(stringsAsFactors = FALSE)

### Command line options
option_list <- list(
    optparse::make_option(
        c("-m", "--metadata"),
        type = "character",
        default = NULL,
        help = "Path to the metadata file.",
        metavar = "character"),
    optparse::make_option(
        c("-o", "--output_file"),
        type = "character",
        default = NULL,
        help = "Path to the clean metadata file",
        metavar = "character")
)

opt_parser <- optparse::OptionParser(option_list = option_list)
opt <- optparse::parse_args(opt_parser)

## Initialize variable
METADATA_FILE <- opt$metadata
OUTPUT_FILE <- opt$output_file

## Code
metadata_df <- fread(METADATA_FILE)

metadata_df <- metadata_df %>%
  select(
    patient, sample_name, sample_type, tissue_type, tumor_site, pam50_subtype
  )

save(
  metadata_df,
  file = OUTPUT_FILE
)