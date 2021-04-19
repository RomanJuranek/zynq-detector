# Cascaded Stripe Memory Engines for Multi-Scale Object Detection in FPGA
Source codes and simulations for object detection in the image on the FPGA presented in the article:

MUSIL Petr, JURÁNEK Roman, MUSIL Martin a ZEMČÍK Pavel. [*Cascaded Stripe Memory Engines for Multi-Scale Object Detection in FPGA*](https://ieeexplore.ieee.org/document/8573854). IEEE Transactions on Circuits and Systems for Video Technology, 2020

```bibtex
@ARTICLE{8573854,
  author={P. {Musil} and R. {Juránek} and M. {Musil} and P. {Zemčík}},
  journal={IEEE Transactions on Circuits and Systems for Video Technology}, 
  title={Cascaded Stripe Memory Engines for Multi-Scale Object Detection in FPGA}, 
  year={2020},
  volume={30},
  number={1},
  pages={267-280},
  doi={10.1109/TCSVT.2018.2886476}
}
```

**Acknowledgment** Development of this software was funded by TACR project and V3C Center of Competence (TE01020415) and ECSEL FitOptiVis (No 783162).
 

## Abstract
Object detection in embedded systems is important for many contemporary applications that involve vision and scene analysis. In this paper, we propose a novel architecture for object detection implemented in FPGA, based on the Stripe Memory Engine (SME), and point out shortcomings of existing architectures. SME processes a stream of image data so that it stores a narrow stripe of the input image and its scaled versions and uses a detector unit which is efficiently pipelined across multiple image positions within the SME. We show how to process images with up to 4K resolution at high frame rates using cascades of SMEs. As a detector algorithm, the SMEs use boosted soft cascade with simple image features that require only pixel comparisons and look-up tables; therefore, they are well suitable for hardware implemenation. We describe the components of our architecture and compare it to several published works in several configurations. As an example, we implemented face detection and license plate detection applications that work with HD images (1280$\times$720 pixels) running at over 60 frames/s on Xilinx Zynq platform. We analyzed their power consumption, evaluated the accuracy of our detectors, and compared them to Haar Cascades from OpenCV that are often used by other authors. We show that our detectors offer better accuracy as well as performance at lower power consumption.

## Files
The design was written completely in VHDL with only few platform-dependent blocks (such as 36 kbit BRAM capacity); thus, it could be relatively easily adapted to various FPGAs, even from different vendor. 
* detectorIP.src --- structured source code of the detector
* detectorIP.xpr --- project file for Xilinx Vivado (tested on version 2016.4)
* detectorIP.v --- pre-synthesized detector component
* sim --- folder with simulation data. It contains a reference detector in C language, pre-trained configuration files for face detection, scripts for data preparation for simulation and display of simulation results