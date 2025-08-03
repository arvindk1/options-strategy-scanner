import os

import firebase_admin
from firebase_admin import credentials, firestore

_db = None

def get_firestore_client():
    global _db
    if _db:
        return _db
    cred_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
    if cred_path:
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
    else:
        firebase_admin.initialize_app()
    _db = firestore.client()
    return _db
