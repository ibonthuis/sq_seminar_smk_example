## Start of snakefile
## snakemake --cores 1 -np ### For dry run

## Libraries
import os 
import sys
import glob
from pathlib import Path
import time

## Config
global CONFIG_PATH
CONFIG_PATH = "config.yaml"
configfile: CONFIG_PATH


## Containers


## Directories
# ["..."] should be listed in the config
DATA_DIR = config["data_dir"]
BASE_OUTPUT_DIR = config["output_dir"]
METADATA_FILE_NAME = config["metadata_name"]
EXPRESSION_FILE_NAME = config["expression_name"]
DATASET_TYPE = config["dataset"]


# # Start uncommenting
# ## Input files ##
# RAW_METADATA = os.path.join(DATA_DIR, METADATA_FILE_NAME)
# FILTERED_EXPRESSION = os.path.join(DATA_DIR, EXPRESSION_FILE_NAME)

# ## Other inputs ##
# VARIABLE_TO_VISUALIZE = config["visualisation_var"]

# ## Output files ##
# FILTERED_METADATA_RDATA = os.path.join(BASE_OUTPUT_DIR, "filtered_metadata.RData")

# ## Output figures ##
# PCA_PLOT_PDF = os.path.join(BASE_OUTPUT_DIR, "PCA_{visualisation_var}_pc12.pdf") # In the R script it's written as follows:  pdf(pcaplot, file.path(OUTPUT_DIR, paste0("PCA", VARIABLE, "pc12.pdf")))

# # ## Rule ALL ##
# # # THIS RULE IS ESSENTIAL: Define which files you want as an output, the structure is like this:
# # # rule all:
# # #     input:

# rule all:
#     input:
#         FILTERED_METADATA_RDATA, \
#         expand(PCA_PLOT_PDF, visualisation_var = VARIABLE_TO_VISUALIZE)
# # Stop uncommenting



# Start uncommenting
# When running with wild cards:
## Input files ##
RAW_METADATA = os.path.join(DATA_DIR, "{dataset_type}", METADATA_FILE_NAME)
FILTERED_EXPRESSION = os.path.join(DATA_DIR, "{dataset_type}", EXPRESSION_FILE_NAME)

## Other inputs ##
VARIABLE_TO_VISUALIZE = config["visualisation_var"]

## Output files ##
FILTERED_METADATA_RDATA = os.path.join(BASE_OUTPUT_DIR, "{dataset_type}", "filtered_metadata.RData")

## Output figures ##
PCA_PLOT_PDF = os.path.join(BASE_OUTPUT_DIR, "{dataset_type}", "PCA_{visualisation_var}_pc12.pdf") 

## Rule ALL ##
rule all:
    input:
        expand(FILTERED_METADATA_RDATA, dataset_type = DATASET_TYPE), \
        expand(PCA_PLOT_PDF, dataset_type = DATASET_TYPE, visualisation_var = VARIABLE_TO_VISUALIZE)
# Stop uncommenting



## Rules ##

rule format_metadata:
    """
    Inputs
    ------
    RAW_METADATA

    Outputs
    -------
    FILTERED_METADATA

    """
    input:
        raw_metadata = RAW_METADATA
    output:
        FILTERED_METADATA_RDATA
    message:
        "; filtering metadata on {input} ;"
    params:
        bin = config["bin"], \
       # output_dir = os.path.join(BASE_OUTPUT_DIR)
        output_dir = os.path.join(BASE_OUTPUT_DIR, "{dataset_type}")
    shell:
        """
        Rscript {params.bin}/filter_metadata.R \
            -m {input.raw_metadata} \
            -o {params.output_dir} 
        """

rule perform_dimensionality_reduction:
    """
    This rule takes original input and reduces dimensionality of the indegree data and plots this.

    Inputs
    ------
    INPUT_METADATA:
        Path to the metadata file containing sample information.
   
    Outputs
    -------
    PCA_PLOT_PDF:
        PCA for specified variable in pdf

    """
    input:
        metadata = FILTERED_METADATA_RDATA, \
        expression = FILTERED_EXPRESSION
    output:
        PCA_PLOT_PDF
    message:
        "; Running dimensionality reduction of indegrees on {input} ;"
    params:
        bin = os.path.join(config["bin"]), \
      #  output_dir = os.path.join(BASE_OUTPUT_DIR), \ 
        output_dir = os.path.join(BASE_OUTPUT_DIR, "{dataset_type}"), \
        visualisation_var = VARIABLE_TO_VISUALIZE
    shell:
        """
        Rscript {params.bin}/perform_dimensionality_reduction.R \
            -e {input.expression} \
            -m {input.metadata} \
            -v {params.visualisation_var} \
            -o {params.output_dir}
        """