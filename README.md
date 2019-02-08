# Overview

RuRaKe is a project that aimed to add geographical information to the existing corpus of Estonian dialects (CED) and to digitize the 125 dialect maps in Andrus Saareste's "Väike eesti murdeatlas" (*Small atlas of Estonian dialects*, 1955). It's continuation project "Digiressursid ja ruumiandmed keeleteaduses" (*Digital Resources and Spatial Data in Linguistics*) in the years 2015-2017 focused on digitizing the 66 maps in Saareste's "Eesti murdeatlas" (*Atlas of Estonian Dialects*, 1938/1941) and the manuscript maps kept in the archives of the University of Uppsala.

# Corpus correction documentation
The subfolder *Corpus-correction-documentation* contains an attribute tabel and a log file. *CED-header-info* includes entries of CED that have geographical information (the longitude and latitude of informants residence) already attached to them. *CED-header-geoinfo-correction- log* records the changes made to the CED attribute table.

# Manuscript maps
The subfolder *Saareste-käsikirjalised* contains the documentation of the scanned manuscript maps. *Saareste_käsikirjalised_puhas.xlsx* contains the documentation in Estonian on one sheet and in English on the other sheet. The csv-files are copies of the same sheets. The maps themselves can be found [here](http://rurake.keeleressursid.ee/index.php/andrus-saarestes-unpublished-dialect-maps/).

# Atlas of Estonian Dialects, 1938/1941
The subfolder *Saareste-murdeatlas* contains the documentation and shapefiles of Saareste's "Eesti murdeatlas" (SMA).

# Small atlas of Estonian dialects, 1955
The subfolder *Saareste-vaike-murdeatlas* contains the documentation and a few examples of the process of digitizing the "Väike eesti murdeatlas" (VMA) as well as shapefiles of the maps in the folder *Shapefiles*. *Atlase-geoinfo* contains among others the attribute table that was the basis for creating the base layer Shapefile *kogumispunktid_utf8_97*. The Shapefile includes all the data collection points of VMA joined with the attribute table of nowadays settlements and parish information. The subfolder also contains the log file (*Saareste-VMA- logifail*) and the data insertion scheme (*Saareste-VMA-sisestusskeem*). 

# Scripts
This subfolder contains Python scripts for CED data manipulation and collection as well as the scripts for (semi)automatic task to correct CED mistakes and insconsistencies. Some example data is added to test the scripts.

# Shiny-applications
Finally, this folder contains commented example scripts for interactive applications made with RStudio's package *Shiny*.
