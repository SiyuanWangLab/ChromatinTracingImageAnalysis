# ChromatinTracingImageAnalysis
This repository contains codes for chromatin tracing raw image analysis. Codes here were used to analyze the raw chromatin tracing images of the 27 TADs on human chromosome 22. See publicaton: Siyuan Wang, Jun-Han Su, Brian J. Beliveau, Bogdan Bintu, Jeffrey R. Moffitt, Chao-ting Wu, Xiaowei Zhuang, Spatial organization of chromatin domains and compartments in single chromosomes, Science, Vol. 353, Issue 6299, 598-602, DOI: 10.1126/science.aaf8084, 2016.

run_calib.m: This file calibrates the transformation matrix between the two fluorescent channels used in the chromatin tracing imaging. We used a 647-nm fluorescent channel and a 561-nm fluorescent channel to image two TADs at a time. Images from the two channels may not be perfectly aligned with each other. Thus before the chromatin tracing experiment, we imaged the same tetraspect beads in both channels to measure the spatial transformation betweeen the two channels, and later canceled this transformation from the chromatin tracing images in run_foci.m.

run_bead.m: This file measures the sample drift during the long-term chromatin tracing imaging procedure. We have fiducial bead markers imaged in the 488-nm channel during chromatin tracing. This file fits the 488-nm fluorescent beads' positions in sequential rounds of imaging and measures the drift of the bead positions during the procedure. The drift information is used in run_foci.m to correct the drift in chromatin trace abstraction.

run_foci.m: This file fits the center positions of the imaged TADs and export them.
