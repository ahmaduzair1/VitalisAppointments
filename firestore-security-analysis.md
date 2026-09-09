# Firestore data model (prototype)

Collections used by Vitalis:

## users/{uid}
Owner + hospital admin (`admin@vitalis.app` with verified email).
Fields: uid, name, email, role (always patient from client), phone, photoUrl, allergies, conditions, notificationsEnabled, createdAt.

## doctors/{id}
Authenticated read. Admin write.
Fields: name, specialty, location, experience, rating, reviews, patients, fee, image, availableToday, about.

## appointments/{id}
Create: signed-in patient, patientId == auth.uid.
Read: owner or admin.
Update: owner may cancel upcoming or mark unpaid -> paid. Admin may complete/cancel/mark paid.
Fields: patientId, patientName, doctorId, doctorName, doctorImage, doctorSpecialty, location, date, time, fee, status, paymentStatus, paymentMethod, createdAt, paidAt?

Queries:
- appointments where patientId == uid (client-side sort)
- appointments all (admin)
- notifications where userId == uid (client-side sort)
- doctors collection snapshots

## notifications/{id}
Create: self or admin. Read: owner or admin. Update: isRead only.
