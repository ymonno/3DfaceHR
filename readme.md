# Remote Heart Rate Estimation Based on 3D Facial Landmarks
We provide the code for "Remote Heart Rate Estimation Based on 3D Facial Landmarks" presented in EMBC2020 <a href="http://www.ok.sc.e.titech.ac.jp/res/VitalSensing/3DfaceHR/index.html" target="_blank">[Project]</a>.

## Overview
This code estimates a person's heart rate (HR) based on 3D facial landmarks. We propose a novel face patch visibility check manner based on the face patch normal in the 3D space. We only use visible patches for blood volume pulse (BVP) estimation. The following figure is the step-by-step explanation of our visibility check.


<img src="images/fig2.png" > 


## Quick start using our sample data

1. Download our repository
 ` git close https://github.com/ymonno/3DfaceHR.git /path/to/direc ` 
2. Run the following Matlab commands to download our sample data
 ` cd /path/to/direc `<br>
 ` setupHRestimation() `
3. Run demo.m

*In our method, we used <a href="https://github.com/1adrianb/face-alignment" target="_blank">'the face alignment method presented in ICCV2017'</a> for 3D facial landmark detection. For this demo code, we provide the deected 3D facial landmarks data for our sample video.

## Setups for using your own data

You need to prepare facial 3D landmarks data before run main.m code.

1. Install [Anaconda](https://www.anaconda.com/)

2. Install face-alignment using conda <br>
    Run the following comands on the anaconda <br>
    ` conda create face_alignment `<br>
    ` conda activate face_alignment`<br>
    ` conda install -c 1adrianb face_alignment `

3. Run face-alignment
   1. Edit /path/to/imgages/ in the 20th row of ./run_face_alignment.py
   2. Move ./run_face_alignment.py to acaconda working directory
   3. Run ` run_face_alignment.py ` on the conda comand line


## Main Functions

### __- demo.m__
You can instantly run our whole code using our sample data and display a comparison between sequential HR results of the baseline method, the proposed method, and a reference contact PPG sensor visually as shown in Fig.3. Estimated HR at a certain time window is stored in the corresponding matfile.

<div align = "center">
<img src="images/fig3.png" width= 50%> 
</div>

### __-getSignals\_*.m__
Estimate BVP using our proposed method or compared methods.<br>
#### getSignals_3DLand_Tracking_VisibilityCheck.m 
angleThres = 75 [degrees]<br>
-> Estimate BVP with the proposed method. [3D Landmark + Tracking + Visibility check]  
angleThres = Inf [degrees]<br>
-> Estimate BVP with the compared  method. [3D Landmark + Tracking]  
#### getSignals_2DLand_Tracking_withOut_VisibilityCheck.m
angleThres = Inf [degrees]<br>
-> Estimate BVP with the baseline method. [2D Landmark + Tracking]  
#### getSignals_2DLand_fixed1stFrame.m
angleThres = Inf [degrees]<br>
-> Estimate BVP with the compared  method. [2D Landmark]

#### Input 
- videoFileName: Full or relative path to the video.
- startTime/endTime: BVP is estimated using the video within the time window [startTim endTime].
- angleThres: Angle threshold used in our visibility check. In the paper, we use 75 [degrees] for our proposed method.

#### Output
- bvpSignal: Estimated BVP signal
- frameRate: Framerate of the video
- time: Time-stamp of the BVP.
- cheekGridReliability: Logical matrix which represents whether a facial patch is reliable (1) or not (0).

### __- run_getSignals\_*.m__
Estimate BVP signals for the video with sliding windows. The estimated BVP is stored in .mat file.

#### Input
- folder: Relative or absolute path to the video folder. We assume that the name of the video is 'video.avi'.
- movingWindowWidth: Width of the window for the BVP estimation. We use 10 sec. in the paper.
- frameRate: Framerate of the input video.
- angleThres: Threshold of the angle between the camera plane and the facial patch. We use 75 [degrees] for our proposed method.
- movie2Use: Define which part of the video is used. If you want to use 5 sec. to 45 sec. of the video, please set as `movie2Use = [5 45]`. 

### __- gridCheekAreaOverlap.m__
This function divides cheek areas into facial patches as shown in Fig. 2(b). Each patch is represented by 4 vertices.
### Input
- Landmarks: Detected 3D facial landmarks.
- overLapRatio: Define how patches are overlaped each other. If overLapRatio = 0, the patches are not overlap. If overLapRatio = 0.4, 40% of the patch is overlaped. In the paper, we set as overLapRatio = 0.
- gridLengthRatio: Define the size of each facial patch. If you want to divide cheek region into 4-by-4 patches as shown in Fig. 2(b), you should set as gridLengthRatio = 0.25 and overLapRatio = 0.

### Output
- GridVertices: GridVertices contains the vertices of each facial patch. Each cell component corresponds to the facial patch. GridVertices{m,n} = [x_1, y_1, z_1; x_2, y_2, z_2; x_3, y_3, z_3; x_4, y_4, z_4]

### __- interDiv3d.m__
This function devides the edge of cheek region (Gray bold edge in Fig. 2(b)) based on 3D space distance.
#### Input 
- edgePts: 3D edge points. edgePts(m,:) represents 3D point [x, y, z].
- overLapRatio/gridLengthRatio: Same as __gridCheekAreaOverlap.m__.

#### Output
- beginIdx/endIdx: edgePts(beginIdx,:) = [x, y, z] which is the beginning point of the facial patch.

### __-  GetNormal.m__
#### Input
- Prand: Prand corresponds to GridVertices{m,n}.

#### Output
- Nvec: Normal vector of the facial patch shown as the black vector in Fig. 2(c). Nvec = [Nvec_x, Nvec_y, Nvec_z]


## Citation
"Remote Heart Rate Estimation Based on 3D Facial Landmarks"<br>
Yuichiro Maki, Yusuke Monno, Masayuki Tanaka, and Masatoshi Okutomi,<br>
International Conference of the IEEE Engineering in Medicine and Biology Society (EMBC2020), July 2020.

