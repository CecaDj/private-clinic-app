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

            // 🕓 Format start and end times as "HH:mm:ss" for FullCalendar
            String startTime = a.Start_Time__c != null ? String.valueOf(a.Start_Time__c).substring(0, 8) : null;
            String endTime   = a.End_Time__c   != null ? String.valueOf(a.End_Time__c).substring(0, 8)   : null;

            // 📅 Convert the date to "yyyy-MM-dd" format in GMT
            Datetime dt = Datetime.newInstanceGmt(a.Date__c, Time.newInstance(0, 0, 0, 0));
            String formattedDate = dt.formatGmt('yyyy-MM-dd');

            // 🧩 Add to results list
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
}
