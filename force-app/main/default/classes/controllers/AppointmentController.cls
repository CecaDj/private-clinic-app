public with sharing class AppointmentController {

    /**
     * Returns appointment data formatted for the Clinic Calendar component.
     * - If a doctor is logged in → only that doctor’s appointments.
     * - Otherwise (receptionist, admin) → all appointments.
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getAppointments() {
        return AppointmentService.getAppointmentsForCurrentUser();
    }

    // Returns past and upcoming appointments for the logged-in patient
    @AuraEnabled(cacheable = true)
    public static Map<String, List<Appointment__c>> getAppointmentsForPatient() {
        return AppointmentService.getAppointmentsForPatient();
    }

    // Cancels an existing appointment for the logged-in patient
    @AuraEnabled
    public static void cancelAppointment(Id appointmentId) {
        AppointmentService.cancelAppointment(appointmentId);
    }

    @AuraEnabled
    public static String bookAppointment(Id doctorId, Id treatmentId, Date selectedDate, String startTimeHHmm) {
        return AppointmentService.bookAppointment(doctorId, treatmentId, selectedDate, startTimeHHmm);
    }
}