The repositoy Paper_EffectiveDepth has the code to analyze data and generate figures for the scientific paper entitled "An Effective Water Depth Correction for Pressure-Based Wave Statistics on Rough Bathymetry", currently in review for the Journal of Atmospheric and Oceanic Technology (JTECH).
At the top directory level, this GitHub repository has:
* data_proc/: a directory with Matlab code to analyze the data.
* figures/: a directory with Matlab code to generate the figures, along with the figures in the paper.
* paper_directory.m: a function that returns the paper directory path.
* run_all.m: a high-level script that runs all the code for the analysis and figures.


The data has been archived in Zenodo (doi: 10.5281/zenodo.13242438). To reproduce the analysis, save the data repository (a folder named data) in the same level as the content in the Paper_EffectiveDepth GitHub repository.
To reproduce the figures, you must also have [cmocean](https://github.com/chadagreene/cmocean) for a few colormaps.

For using the repository, **first edit the directory path in paper_directory.m** to reflect the appropriate paper repository path in your machine.
After editing paper_directory.m, you may run the full analysis with run_all.m. This script simply runs the other high-level scripts ~/data_proc/run_alldataprocessing.m and ~/figures/run_allfigures.m.

