#!/bin/bash

module use ~/MyModules
module load miniconda3/latest
source activate qiime2-2021.4

WRKDIR=${HOME}/BioinfWorkshop2021/Part2_Qiime_16S/
MAP=${HOME}/BioinfWorkshop2021/Part2_Qiime_16S/metadata/SraRunTable_full.txt

cd ~/BioinfWorkshop2020/Part2_Qiime_16S/results/

qiime feature-table summarize \
 --i-table table.qza \
 --o-visualization table.qzv \
 --m-sample-metadata-file ${MAP}

 qiime feature-table filter-samples \
  --i-table table.qza \
  --o-filtered-table table_1k.qza \
  --p-min-frequency 1000

qiime diversity alpha-rarefaction  --i-table table.qza  --o-visualization collector_curve.qzv  --p-max-depth 5000  --p-steps 20 --i-phylogeny tree_root.qza --m-metadata-file $MAP

qiime diversity core-metrics-phylogenetic \
   --i-table table_1k.qza \
   --i-phylogeny tree_root.qza \
   --output-dir core-div \
   --p-sampling-depth 2500 \
   --m-metadata-file ${MAP} \
   --p-n-jobs-or-threads 2

   qiime diversity alpha-group-significance \
    --i-alpha-diversity core-div/shannon_vector.qza \
    --o-visualization core-div/shannon_SampleType.qzv \
    --m-metadata-file ${MAP}

   qiime diversity alpha \
    --i-table core-div/rarefied_table.qza \
    --p-metric mcintosh_e \
    --o-alpha-diversity core-div/mcintosh_vector.qza

   qiime diversity alpha-group-significance \
    --i-alpha-diversity core-div/mcintosh_vector.qza \
    --o-visualization core-div/mcintosh_SampleType.qzv \
    --m-metadata-file ${MAP}
