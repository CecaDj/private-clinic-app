public with sharing class DoctorService {
    
    public static List<Doctor__c> getAllDoctors() {
        return [
            SELECT Id, Name, Specialization__c, Working_Days__c,
                   Working_Hours_Start__c, Working_Hours_End__c
            FROM Doctor__c
            ORDER BY Name
        ];
    }
        
    //Returns available slots for a doctor based on a selected date and treatment duration
    public static List<String> getAvailableSlots(Id doctorId, Date selectedDate, Id treatmentId) {

        if (doctorId == null || selectedDate == null || treatmentId == null){
            throw new AuraHandledException('Please select a doctor, treatment, and date.');
        }

        Doctor__c doctor = [
            SELECT Working_Days__c, Working_Hours_Start__c, Working_Hours_End__c
            FROM Doctor__c
            WHERE Id = :doctorId
            LIMIT 1
        ];

        Treatment__c treatment = [
            SELECT Duration__c
            FROM Treatment__c
            WHERE Id = :treatmentId
            LIMIT 1
        ];
        Integer duration = (treatment.Duration__c == null) ? 30 : Integer.valueOf(treatment.Duration__c);

        // Determine the day of the week
        String dayName = DateTime.newInstance(selectedDate, Time.newInstance(0, 0, 0, 0))
            .format('EEEE', 'en_US');

        List<String> workingDays = String.isNotBlank(doctor.Working_Days__c)
            ? doctor.Working_Days__c.split(';')
            : new List<String>();

        if (!workingDays.contains(dayName)) {
            return new List<String>();
        }
        
        Time workStart = doctor.Working_Hours_Start__c;
        Time workEnd   = doctor.Working_Hours_End__c;

        // Fetch booked appointments for that day
        List<Appointment__c> booked = [
            SELECT Start_Time__c, End_Time__c
            FROM Appointment__c
            WHERE Doctor__c = :doctorId
            AND Date__c = :selectedDate
            AND Status__c != 'Cancelled'
            AND Start_Time__c != null
            AND End_Time__c != null
            ORDER BY Start_Time__c ASC
        ];

        // Build available slots
        List<String> available = new List<String>();
        Time currentStart = workStart;

        for (Appointment__c a : booked) {
            // Fill gaps before this appointment
            while (currentStart.addMinutes(duration) <= a.Start_Time__c) {
                available.add(TimeConversionHelper.convert(currentStart));
                currentStart = currentStart.addMinutes(duration);
            }

            // Skip the booked time entirely
            if (a.End_Time__c > currentStart) {
                currentStart = a.End_Time__c;
            }
        }

        // Add remaining slots after last appointment
        while (currentStart.addMinutes(duration) <= workEnd) {
            available.add(TimeConversionHelper.convert(currentStart));
            currentStart = currentStart.addMinutes(duration);
        }

        return available;
    }
}