# NetEmulation #

NetEmulation is a freely available simulation package for computer interconnect networks focusing on optical technologies. Unlike other network simulators, NetEmulation is written in SystemVerilog which, although slow for simulation, allows modules to be synthesised to obtain speed/area/power estimates for the control plane and also can form the basis of FPGA-based network demonstrators.

This code was used to obtain the results in the following papers.  **If you use the code for academic research, please cite them as appropriate:**

(1)Shiyun Liu, Qixiang Cheng, Adrian Wonfor, Richard Penty, Ian White, Philip Watts, "A Low Latency Optical Top of Rack Switch for Data Centre Networks with Minimized Processor Energy Load ", Optical Fiber Communication Conference, San Francisco, California, March 2014. 

(2)Van Laer, A; Watts, PM; (2012) Design of a speculative network adapter for shared memory communications in 45 nm CMOS. In: IEEE Optical Interconnects Conference 2012.
	
(3)Watts, PM; Moore, SW; Moore, AW; (2012) Energy Implications of Photonic Networks With Speculative Transmission. JOURNAL OF OPTICAL COMMUNICATIONS AND NETWORKING , Vol. 4 (6), pp 503 - 513. 


Each folder contains a README.md file.  This is a file written in the markdown format that describes the contents of the folder.  This file should be maintained at the same time as the code so that discrepancies do not occur.  For more information consult the [wiki](https://github.com/DannyNicholls/NetEmulation/wiki)

## Sub Folders ##

### BEE3_top ###

>**DESCRIPTION :** Code specific to UCL group.  Files for synthesising code on the BEE3 cube FPGA in the connect lab  
**NOTES :** 

### ENoC ###

>**DESCRIPTION :** Electrical Network on Chip Code  
**NOTES :** 

### LIB ###

>**DESCRIPTION :** Library Files  
**NOTES :** Includes arbitrators, FIFOs etc.  Be careful when changing files as they may be used by multiple networks.

### NEMU ###

>**DESCRIPTION :** NetEmulation Code  
**NOTES :** 
