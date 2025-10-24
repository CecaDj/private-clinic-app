import { LightningElement, track } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import FULLCALENDAR from '@salesforce/resourceUrl/FullCalendar';
import getAppointments from '@salesforce/apex/AppointmentController.getAppointments';

export default class ClinicCalendar extends LightningElement {
    fullCalendarInitialized = false;
    calendar;
    appointments = [];

    doctorOptions = [];
    selectedDoctor = '';

    renderedCallback() {
        if (this.fullCalendarInitialized) return;
        this.fullCalendarInitialized = true;

        Promise.all([
            loadScript(this, FULLCALENDAR + '/FullCalendar/main.js'),
            loadStyle(this, FULLCALENDAR + '/FullCalendar/main.css')
        ])
        .then(() => {
            this.initCalendar();
        })
        .catch(error => {
            console.error('Error loading FullCalendar:', error);
        });
    }

    async initCalendar() {
        const calendarEl = this.template.querySelector('.calendar-container');

        try {
            const data = await getAppointments();
            this.appointments = data.map(a => ({
                id: a.Id,
                title: `${a.Patient} - ${a.Treatment}`,
                start: `${a.Date}T${a.StartTime}`,
                end: `${a.Date}T${a.EndTime}`,
                doctorName: a.DoctorName,
                doctorId: a.DoctorId
            }));

            // Build doctor filter list
            const doctorMap = new Map(this.appointments.map(a => [a.doctorId, a.doctorName]));
            const doctors = Array.from(doctorMap, ([id, name]) => ({ label: name, value: id }));

            if (doctors.length > 1) {
                this.doctorOptions = doctors;
            } else if (doctors.length === 1) {
                this.selectedDoctor = doctors[0].value;
                this.doctorOptions = null; 
            }

            // Init FullCalendar
            this.calendar = new FullCalendar.Calendar(calendarEl, {
                themeSystem: 'standard',
                initialView: 'dayGridMonth',
                height: 'auto',
                headerToolbar: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'dayGridMonth,timeGridWeek,timeGridDay,listWeek'
                },
                events: this.selectedDoctor
                    ? this.appointments.filter(e => e.doctorId === this.selectedDoctor)
                    : this.appointments,
                navLinks: true,
                slotMinTime: '07:00:00',
                slotMaxTime: '20:00:00',
                eventClick: (info) => {
                    info.jsEvent.preventDefault();
                    window.open(`/lightning/r/Appointment__c/${info.event.id}/view`, '_blank');
                }
            });

            this.calendar.render();
        } catch (error) {
            console.error('Error fetching appointments:', error);
        }
    }

    handleDoctorChange(event) {
        this.selectedDoctor = event.detail.value;

        const filtered = this.selectedDoctor
            ? this.appointments.filter(a => a.doctorId === this.selectedDoctor)
            : this.appointments;

        if (this.calendar) {
            this.calendar.removeAllEvents();
            this.calendar.addEventSource(filtered);
        }
    }
}
