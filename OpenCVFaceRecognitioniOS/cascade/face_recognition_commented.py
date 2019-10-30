# Face Recognition

import cv2
import urllib
import numpy as np

face_cascade = cv2.CascadeClassifier('haarcascade_frontalcatface_extended.xml') # We load the cascade for the face.
eye_cascade = cv2.CascadeClassifier('haarcascade_fullbody.xml') # We load the cascade for the eyes.
smile_cascade = cv2.CascadeClassifier('haarcascade_smile.xml') # We load the cascade for the eyes.

profileface_cascade = cv2.CascadeClassifier('haarcascade_profileface.xml') # We load the cascade for


# Defining a function that will do the detections
def detect(gray, frame):
    faces = face_cascade.detectMultiScale(gray, 1.3, 5)
    for (x, y, w, h) in faces:
        cv2.rectangle(frame, (x, y), (x+w, y+h), (255, 0, 0), 2)
        roi_gray = gray[y:y+h, x:x+w]
        roi_color = frame[y:y+h, x:x+w]
        eyes = eye_cascade.detectMultiScale(roi_gray, 1.1, 22)
        for (ex, ey, ew, eh) in eyes:
            cv2.rectangle(roi_color, (ex, ey), (ex+ew, ey+eh), (0, 255, 0), 2)
        smiles = smile_cascade.detectMultiScale(roi_gray, 1.7, 22)
        for (sx, sy, sw, sh) in smiles:
            cv2.rectangle(roi_color, (sx, sy), (sx+sw, sy+sh), (0, 0, 255), 2)
            
        profileface = profileface_cascade.detectMultiScale(roi_gray, 1.7, 22)
        for (sx, sy, sw, sh) in profileface:
            cv2.rectangle(roi_gray, (sx, sy), (sx+sw, sy+sh), (0, 0, 255), 2)
    return frame


video_capture = cv2.VideoCapture(0) # We turn the webcam on.

#while True: # We repeat infinitely (until break):
#    _, frame = video_capture.read() # We get the last frame.
#    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY) # We do some colour transformations.
#    canvas = detect(gray, frame) # We get the output of our detect function.
#    cv2.imshow('Video', canvas) # We display the outputs.
#    if cv2.waitKey(1) & 0xFF == ord('q'): # If we type on the keyboard:
#        break # We stop the loop.

#video_capture.release() # We turn the webcam off.
#cv2.destroyAllWindows() # We destroy all the windows inside which the images were displayed.


#stream = urllib.request.urlopen('http://212.225.210.38:91/mjpg/video.mjpg')
stream = urllib.request.urlopen('http://95.43.211.105/mjpeg.cgi#.W2LdJCcOzhQ.link')                                

bytes = bytes()
while True:
    bytes += stream.read(1024)
    a = bytes.find(b'\xff\xd8')
    b = bytes.find(b'\xff\xd9')
    if a != -1 and b != -1:
        jpg = bytes[a:b+2]
        bytes = bytes[b+2:]
        i = cv2.imdecode(np.fromstring(jpg, dtype=np.uint8), cv2.IMREAD_COLOR)
        gray = cv2.cvtColor(i, cv2.COLOR_BGR2GRAY) # We do some colour transformations.
        canvas = detect(gray, i)
        cv2.imshow('i', canvas)
        if cv2.waitKey(1) == 27:
            exit(0)