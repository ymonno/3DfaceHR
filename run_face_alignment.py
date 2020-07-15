import face_alignment
from skimage import io
import numpy as np
import scipy.io
import os

def run_face_alignment(folderName):
    
    fa = face_alignment.FaceAlignment(face_alignment.LandmarksType._3D, flip_input=False)    
    preds = fa.get_landmarks_from_directory(folderName)
    preds_short = {}
    
    for thiskey in preds.keys():
        preds_short[os.path.basename(thiskey)] = preds[thiskey]
        try:
            scipy.io.savemat(thiskey + ".mat", {'Landmarks':preds[thiskey]})
        except:
            print(thiskey)
        
folderName = 'path/to/images'
print(folderName)
run_face_alignment(folderName)