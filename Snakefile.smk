## Start of snakefile
## snakemake --cores 1 -np ### For dry run
# For making a dag.pdf
# Install graphviz in a conda environment. Activate the conda environment. Run the following code:
# snakemake --dag | dot -Tpdf > dag.pdf


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

## Directories
# ["..."] should be listed in the config
DATA_DIR = config["data_dir"]
BASE_OUTPUT_DIR = config["output_dir"]
VARIABLE_TO_VISUALIZE = config["visualisation_var"]


METADATA = os.path.join(DATA_DIR, "{dataset}", "metadata.csv")
EXPRESSION = os.path.join(DATA_DIR, "{dataset}", "filtered_expression.tsv")

## Wildcards
DATASETS = config["dataset"]
FILTERED_METADATA_RDATA = os.path.join(BASE_OUTPUT_DIR, "{dataset}", "filtered_metadata.tsv")
PCA_PLOT_PDF = os.path.join(BASE_OUTPUT_DIR, "figures", "pca_plot_{dataset}.pdf")

rule all:
    input:
        expand(FILTERED_METADATA_RDATA, dataset = DATASETS), \
        expand(PCA_PLOT_PDF, dataset = DATASETS)

rule format_metadata:
    """
    Inputs
    ------
    METADATA:
        Path to raw metadata file containing sample info

    Outputs
    -------
    FILTERED_METADATA_RDATA
        File with the raw metadata filtered in RData format.
    """
    input:
        metadata = METADATA
    output:
        filtered_metadata = FILTERED_METADATA_RDATA
    message:
        "; filtering metadata on {input} ;"
    params:
        bin = config["bin"]
    shell:
        """
        Rscript {params.bin}/filter_metadata.R \
            -m {input.metadata} \
            -o {output.filtered_metadata} 
        """

rule perform_dimensionality_reduction:
    """
    This rule takes original input and reduces dimensionality of the expression data and plots this.

    Inputs
    ------
    FILTERED_METADATA_RDATA:
        Path to the filtered metadata file from the previous rule.
    FILTERED_EXPRESSION:
        Path to an expression file that you provide as a stand-alone input.

    Outputs
    -------
    PCA_PLOT_PDF:
        PCA for specified variable in pdf.

    Parameters
    -------
    VARIABLE_TO_VISUALIZE:
        Variable to visualize in the PCA.

    """
    input:
        metadata = FILTERED_METADATA_RDATA, \
        expression = EXPRESSION
    output:
        pca_plot_pdf = PCA_PLOT_PDF
    message:
        "; Running dimensionality reduction of expressions on {input} ;"
    params:
        bin = os.path.join(config["bin"]), \
        visualisation_var = VARIABLE_TO_VISUALIZE
    shell:
        """
        Rscript {params.bin}/perform_dimensionality_reduction.R \
            -e {input.expression} \
            -m {input.metadata} \
            -v {params.visualisation_var} \
            -o {output.pca_plot_pdf}
        """