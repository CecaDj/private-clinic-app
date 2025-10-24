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
}