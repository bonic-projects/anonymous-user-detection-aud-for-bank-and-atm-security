import cv2
import face_recognition
import os
import numpy as np
import base64
import firebase_admin
from firebase_admin import credentials, db
import datetime
import threading
from ultralytics import YOLO

# Firebase Initialization
cred = credentials.Certificate("aud-bank-firebase-adminsdk-fbsvc-3abaedcae9.json")
firebase_admin.initialize_app(cred, {'databaseURL': 'https://aud-bank-default-rtdb.firebaseio.com'})

# Load YOLO Model
model = YOLO("best.pt")

# Define Camera Sources
ATM_CAMERA = "http://192.168.29.180/stream"  # ATM Camera - YOLO
LOCKER_CAMERA = "http://192.168.29.63/stream"  # Locker Camera - Face Recognition

# Path to Known Faces
KNOWN_FACES_DIR = r"D:\autobonics projects\aud\anonymous-user-detection-aud-for-bank-and-atm-security\images\known_faces"
known_faces = []
known_names = []

# Load Multiple Faces for Each Person
for person_name in os.listdir(KNOWN_FACES_DIR):
    person_folder = os.path.join(KNOWN_FACES_DIR, person_name)
    encodings = []

    for filename in os.listdir(person_folder):
        img_path = os.path.join(person_folder, filename)
        image = face_recognition.load_image_file(img_path)

        face_encodings = face_recognition.face_encodings(image)
        if face_encodings:  # Ensure a face was found
            encodings.append(face_encodings[0])

    if encodings:
        avg_encoding = np.mean(encodings, axis=0)
        known_faces.append(avg_encoding)
        known_names.append(person_name)

# Set initial status in Firebase
db.reference("threats/atm").set(False)
db.reference("threats/bank").set(False)

# Global variables for status tracking
atm_threat_detected = False
bank_threat_detected = False


# Process YOLO on ATM Camera
def process_atm_camera():
    global atm_threat_detected
    cap = cv2.VideoCapture(ATM_CAMERA)
    frame_count = 0  # Skip frames for faster processing

    while True:
        ret, frame = cap.read()
        if not ret:
            print("ATM Camera: Failed to capture frame")
            continue

        frame_count += 1
        if frame_count % 3 != 0:  # Process every 3rd frame
            continue

        frame_resized = cv2.resize(frame, (640, 480))  # Reduce frame size for faster processing
        results = model.predict(source=frame_resized, verbose=False, stream=True)  # Optimized YOLO inference
        detections = next(results).boxes if results else []

        new_threat = len(detections) > 0

        if new_threat != atm_threat_detected:
            atm_threat_detected = new_threat
            db.reference("threats/atm").set(atm_threat_detected)

            if atm_threat_detected:
                _, buffer = cv2.imencode('.jpg', frame, [int(cv2.IMWRITE_JPEG_QUALITY), 50])
                img_base64 = base64.b64encode(buffer).decode('utf-8')
                timestamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
                db.reference(f"images/atm_camera/{timestamp}").set({'image': img_base64})
                print("ATM Camera: Threat Detected, Image Uploaded")

        cv2.imshow("YOLO - ATM Camera", frame_resized)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()


# Process Face Recognition on Locker Camera
def process_locker_camera():
    global bank_threat_detected
    video_capture = cv2.VideoCapture(LOCKER_CAMERA)
    frame_count = 0  # Skip frames for faster processing

    while True:
        ret, frame = video_capture.read()
        if not ret:
            print("Locker Camera: Failed to capture frame")
            continue

        frame_count += 1
        if frame_count % 5 != 0:  # Process every 5th frame
            continue

        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        face_locations = face_recognition.face_locations(rgb_frame)
        face_encodings = face_recognition.face_encodings(rgb_frame, face_locations)

        new_threat = False  # Track if an unknown face is detected

        for face_encoding, face_location in zip(face_encodings, face_locations):
            matches = face_recognition.compare_faces(known_faces, face_encoding, tolerance=0.5)
            name = "Unknown"

            if True in matches:
                best_match_index = np.argmin(face_recognition.face_distance(known_faces, face_encoding))
                name = known_names[best_match_index]

            if name == "Unknown":
                new_threat = True  # Mark if unknown face is found

            # Draw bounding box and label
            top, right, bottom, left = face_location
            color = (0, 0, 255) if name == "Unknown" else (0, 255, 0)
            cv2.rectangle(frame, (left, top), (right, bottom), color, 2)
            cv2.putText(frame, name, (left, top - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.8, color, 2)

            # Upload only for unknown faces when there's a change in threat status
            if name == "Unknown" and new_threat != bank_threat_detected:
                _, buffer = cv2.imencode('.jpg', frame, [int(cv2.IMWRITE_JPEG_QUALITY), 50])
                img_base64 = base64.b64encode(buffer).decode('utf-8')

                timestamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
                db.reference(f"images/locker_camera/{timestamp}").set({'image': img_base64, 'name': name})
                print("Locker Camera: Unknown Face Detected, Image Uploaded")

        # Update Firebase status only if there's a change
        if new_threat != bank_threat_detected:
            bank_threat_detected = new_threat
            db.reference("threats/bank").set(bank_threat_detected)

        cv2.imshow("Face Recognition - Locker Camera", frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    video_capture.release()
    cv2.destroyAllWindows()


# Run Both Threads
atm_thread = threading.Thread(target=process_atm_camera, daemon=True)
locker_thread = threading.Thread(target=process_locker_camera, daemon=True)

atm_thread.start()
locker_thread.start()

atm_thread.join()
locker_thread.join()
