These bash scripts can serve as *templates* for full job submission. They are both just the commands as we worked through them with test dataset in class. 

NOTE that both have them you will need to add your own directories/uNID as noted in places with "<_>".

### File Descriptions:
1. [PreProcess_16S.sh](https://github.com/wzacs1/BioinfWorkshop/blob/master/batch_job_templates/PreProcess_16S.sh) 
This script has commands for full dataset and should run well as it is once you've added your directories. It has options for the 2020.2 QIIME2 conda env that we installed. Also are listed commands for loading and using the 2019 version installed by CHPC. You will need to remove the comment characters from those lines if you want to use them, and remove or comment out the 2020.2 commands. There is often version incompatibity between qiime2 artifacts made in different versions, so reading the shared files from one version into the other may not work well.

2. [PreProcess_RNAseq.sh](https://github.com/wzacs1/BioinfWorkshop/blob/master/batch_job_templates/PreProcess_RNAseq.sh)
This script has commands as listed for the test dataset. You'll need to change the directory references and the input files to copy if you want to run the full dataset. The full "BiopsyOnly" input path is provided in script and on walkthrough pages.


