import { LightningElement } from 'lwc';
import getPatientAppointments from '@salesforce/apex/AppointmentController.getAppointmentsForPatient';
import cancelAppointment from '@salesforce/apex/AppointmentController.cancelAppointment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';

export default class PatientAppointments extends LightningElement {

    upcoming = [];
    past = [];
    isLoading = true;

    connectedCallback() {
        this.loadData();
    }

    async loadData() {
        this.isLoading = true;
        try {
            const appointments = await getPatientAppointments();
            this.upcoming = this.formatAppointments(appointments.upcoming);
            this.past = this.formatAppointments(appointments.past);
        } catch (error) {
            this.showToast('Error', 'Failed to load appointments.', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    // Normalize appointments for UI
    formatAppointments(list) {
        return list.map(appt => ({
            ...appt,
            displayDate: this.formatDate(appt.Date__c),
            displayTime: this.formatTime(appt.Start_Time__c),
            showCancelButton: appt.Status__c !== 'Cancelled'
        }));
    }

    formatDate(rawDate) {
        if (!rawDate) return '';
        return new Date(rawDate).toLocaleDateString('en-US', {
            month: 'long', day: 'numeric', year: 'numeric'
        });
    }

    formatTime(rawTime) {
        if (!rawTime) return '';
        try {
            const ms = Number(rawTime);
            if (!isNaN(ms)) {
                const d = new Date(ms);
                return d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: true });
            }
            return rawTime;
        } catch {
            return String(rawTime);
        }
    }

    // Cancel Appointment Handler
    async handleCancel(event) {
        const appointmentId = event.target.dataset.id;

        const confirmed = await LightningConfirm.open({
            message: 'Are you sure you want to cancel this appointment?',
            theme: 'warning'
        });

        if (!confirmed) return;

        this.isLoading = true;
        try {
            await cancelAppointment({ appointmentId });
            this.showToast('Success', 'Appointment cancelled successfully.', 'success');
            await this.loadData(); // Refresh data
        } catch (error) {
            this.showToast('Error', error?.body?.message || 'Failed to cancel appointment.', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
