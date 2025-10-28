public with sharing class AppointmentService {

    /**
     * Returns appointments visible to the current user:
     *  - If the user is a Doctor (linked via Doctor__c.User__c),
     *    returns only that doctor’s appointments.
     *  - Otherwise (Receptionist, Admin), returns all non-cancelled appointments.
     */
    public static List<Map<String, Object>> getAppointmentsForCurrentUser() {
        Id userId = UserInfo.getUserId();

        // Determine if current user is a Doctor
        List<Doctor__c> doctorList = [
            SELECT Id FROM Doctor__c WHERE User__c = :userId LIMIT 1
        ];
        Doctor__c doctor = doctorList.isEmpty() ? null : doctorList[0];

        List<Appointment__c> appointments;
        if (doctor != null) {
            appointments = [
                SELECT Id, Name, Status__c, Date__c, Start_Time__c, End_Time__c,
                       Doctor__r.Id, Doctor__r.Name,
                       Patient__r.Name, Treatment__r.Name
                FROM Appointment__c
                WHERE Doctor__c = :doctor.Id
                      AND Date__c != null
                      AND Status__c != 'Cancelled'
                ORDER BY Date__c, Start_Time__c
            ];
        } else {
            appointments = [
                SELECT Id, Name, Status__c, Date__c, Start_Time__c, End_Time__c,
                       Doctor__r.Id, Doctor__r.Name,
                       Patient__r.Name, Treatment__r.Name
                FROM Appointment__c
                WHERE Date__c != null
                      AND Status__c != 'Cancelled'
                ORDER BY Date__c, Start_Time__c
            ];
        }

        // Convert each record into a JSON-friendly map
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        for (Appointment__c a : appointments) {

            // Format start and end times as "HH:mm:ss" for FullCalendar
            String startTime = a.Start_Time__c != null ? String.valueOf(a.Start_Time__c).substring(0, 8) : null;
            String endTime   = a.End_Time__c   != null ? String.valueOf(a.End_Time__c).substring(0, 8)   : null;

            // Convert the date to "yyyy-MM-dd" format in GMT
            Datetime dt = Datetime.newInstanceGmt(a.Date__c, Time.newInstance(0, 0, 0, 0));
            String formattedDate = dt.formatGmt('yyyy-MM-dd');

            // Add to results list
            results.add(new Map<String, Object>{
                'Id'         => a.Id,
                'Date'       => a.Date__c != null ? formattedDate : null,
                'StartTime'  => startTime,
                'EndTime'    => endTime,
                'DoctorName' => a.Doctor__r != null ? a.Doctor__r.Name : null,
                'DoctorId'   => a.Doctor__r != null ? a.Doctor__r.Id   : null,
                'Patient'    => a.Patient__r != null ? a.Patient__r.Name : null,
                'Treatment'  => a.Treatment__r != null ? a.Treatment__r.Name : null
            });
        }

        return results;
    }

    // Returns both past and upcoming appointments for the logged-in patient
    public static Map<String, List<Appointment__c>> getAppointmentsForPatient() {
        Id patientId = PatientService.getMyPatientId();
        Date today = Date.today();

        List<Appointment__c> upcoming = [
            SELECT Id, Name, Date__c, Start_Time__c, Status__c,
                   Doctor__r.Name, Treatment__r.Name
            FROM Appointment__c
            WHERE Patient__c = :patientId
              AND Date__c >= :today
            ORDER BY Date__c ASC, Start_Time__c ASC
        ];

        List<Appointment__c> past = [
            SELECT Id, Name, Date__c, Start_Time__c, Status__c,
                   Doctor__r.Name, Treatment__r.Name
            FROM Appointment__c
            WHERE Patient__c = :patientId
              AND Date__c < :today
            ORDER BY Date__c DESC, Start_Time__c DESC
        ];

        return new Map<String, List<Appointment__c>>{
            'upcoming' => upcoming,
            'past'     => past
        };
    }

    // Cancels an appointment by setting its status to 'Cancelled'.
    public static void cancelAppointment(Id appointmentId) {
        if (appointmentId == null) {
            throw new AuraHandledException('Invalid appointment Id.');
        }

        Appointment__c appt = [
            SELECT Id, Patient__c, Status__c
            FROM Appointment__c
            WHERE Id = :appointmentId
            LIMIT 1
        ];

        if (appt.Status__c == 'Cancelled') {
            throw new AuraHandledException('This appointment is already cancelled.');
        }

        appt.Status__c = 'Cancelled';
        update appt;
    }

 
    // Books an appointment after verifying that Patient profile is complete
    public static String bookAppointment(Id doctorId, Id treatmentId, Date selectedDate, String startTimeAMPM) {

        if (doctorId == null || treatmentId == null || selectedDate == null || String.isBlank(startTimeAMPM)) {
            throw new AuraHandledException('Please select doctor, treatment, date, and time before booking.');
        }

        if (!PatientService.isPatientProfileComplete()) {
            throw new AuraHandledException('Please complete your profile before booking.');
        }

        Time t = TimeConversionHelper.convert(startTimeAMPM);
        Id patientId = PatientService.getMyPatientId();
        if (patientId == null) {
            throw new AuraHandledException('Patient record not found for current user.');
        }

        insert new Appointment__c(
            Doctor__c = doctorId,
            Treatment__c = treatmentId,
            Date__c = selectedDate,
            Start_Time__c = t,
            Patient__c = patientId,
            Status__c = 'Scheduled'
        );

        return 'Appointment booked successfully for ' + selectedDate.format() + ' at ' + startTimeAMPM + '.';
    }

}
