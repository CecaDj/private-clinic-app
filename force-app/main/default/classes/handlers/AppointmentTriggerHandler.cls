public class AppointmentTriggerHandler {

    public static void beforeInsertOrUpdate(List<Appointment__c> newList, List<Appointment__c> oldList) {
        List<Appointment__c> appointmentsToValidate = getAppointmentsToValidate(newList, oldList);

        for (Appointment__c app : appointmentsToValidate) {
            // Prevent past or last-minute appointments
            validateNotPastOrLastMinute(app);

            // Update end time
            updateEndTime(app);

            // Check overlapping
            validateNoOverlap(app);

            // Check doctor's working schedule
            validateDoctorSchedule(app);
        }
    }

    private static List<Appointment__c> getAppointmentsToValidate(List<Appointment__c> newList, List<Appointment__c> oldList) {
        if (oldList == null) return newList;

        List<Appointment__c> result = new List<Appointment__c>();
        Map<Id, Appointment__c> oldMap = new Map<Id, Appointment__c>(oldList);
        for (Appointment__c app : newList) {
            Appointment__c oldApp = oldMap.get(app.Id);
            if (oldApp == null || 
                oldApp.Start_Time__c != app.Start_Time__c || 
                oldApp.Date__c != app.Date__c || 
                oldApp.Treatment__c != app.Treatment__c || 
                oldApp.Doctor__c != app.Doctor__c) {
                result.add(app);
            }
        }
        return result;
    }

    private static void validateNotPastOrLastMinute(Appointment__c app) {
        if (app.Date__c == null || app.Start_Time__c == null) return;
        if (app.Date__c <= Date.today()) {
            app.addError('The selected appointment is in the past or last minute. Please select a different date.');
        }
    }

    private static void updateEndTime(Appointment__c app) {
        if (app.Treatment__c == null) {
            app.addError('Please select a valid treatment before saving.');
            return;
        }

        Treatment__c treatment = [SELECT Duration__c FROM Treatment__c WHERE Id = :app.Treatment__c LIMIT 1];
        DateTime dt = DateTime.newInstance(app.Date__c, app.Start_Time__c);
        dt = dt.addMinutes((Integer)treatment.Duration__c);
        app.End_Time__c = dt.time();
    }

    private static void validateNoOverlap(Appointment__c app) {
        if (app.Doctor__c == null || app.Start_Time__c == null || app.End_Time__c == null || app.Date__c == null) return;

        List<Appointment__c> doctorApps = [
            SELECT Id, Start_Time__c, End_Time__c 
            FROM Appointment__c 
            WHERE Doctor__c = :app.Doctor__c 
            AND Date__c = :app.Date__c
        ];

        for (Appointment__c other : doctorApps) {
            if (other.Id == app.Id) continue;
            Boolean overlaps = app.Start_Time__c < other.End_Time__c && app.End_Time__c > other.Start_Time__c;
            if (overlaps) {
                app.addError('This appointment overlaps with another appointment for the same doctor.');
                return;
            }
        }
    }

    private static void validateDoctorSchedule(Appointment__c app) {
        if (app.Doctor__c == null || app.Date__c == null || app.Start_Time__c == null || app.End_Time__c == null) return;

        Doctor__c doctor = [
            SELECT Working_Days__c, Working_Hours_Start__c, Working_Hours_End__c 
            FROM Doctor__c WHERE Id = :app.Doctor__c LIMIT 1
        ];

        List<String> workingDays = doctor.Working_Days__c != null ? doctor.Working_Days__c.split(';') : new List<String>();
        String dayOfWeek = DateTime.newInstance(app.Date__c, app.Start_Time__c).format('EEEE');

        if (!workingDays.contains(dayOfWeek)) {
            app.addError('The selected date is outside the doctor’s working days.');
            return;
        }

        if (app.Start_Time__c < doctor.Working_Hours_Start__c || app.End_Time__c > doctor.Working_Hours_End__c) {
            app.addError('The selected time is outside the doctor’s working hours.');
        }
    }
}
