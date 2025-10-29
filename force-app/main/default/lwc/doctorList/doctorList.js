import { LightningElement } from 'lwc';
import getDoctors from '@salesforce/apex/DoctorController.getAllDoctors';

export default class DoctorList extends LightningElement {
  doctors = [];        
  loading = true;      
  showModal = false;   

  selectedDoctorId;
  selectedDoctorName;

  connectedCallback() {
    this.loadDoctors();
  }

  async loadDoctors() {
    try {
      const result = await getDoctors();

      // Map doctor records to display-friendly format
      this.doctors = result.map(doc => ({
        ...doc,
        displayDays: doc.Working_Days__c
          ? doc.Working_Days__c.replaceAll(';', ', ') // Format working days
          : '—',
        displayHours: this.formatTimeRange(
          doc.Working_Hours_Start__c,
          doc.Working_Hours_End__c
        )
      }));
    } catch (error) {
      console.error('Error loading doctors:', error);
    } finally {
      this.loading = false;
    }
  }

  // Format working hours into a time range string
  formatTimeRange(start, end) {
    if (!start || !end) return '—';
    return `${this.formatTime(start)} - ${this.formatTime(end)}`;
  }

  // Convert milliseconds to "hh:mm AM/PM"
  formatTime(value) {
    const totalMinutes = Math.floor(parseInt(value, 10) / 60000);
    const hours24 = Math.floor(totalMinutes / 60);
    const minutes = (totalMinutes % 60).toString().padStart(2, '0');

    const ampm = hours24 >= 12 ? 'PM' : 'AM';
    const h12 = hours24 % 12 === 0 ? 12 : hours24 % 12;

    return `${h12.toString().padStart(2, '0')}:${minutes} ${ampm}`;
  }

  openModal(event) {
    this.selectedDoctorId = event.currentTarget.dataset.id;
    this.selectedDoctorName = event.currentTarget.dataset.name;
    this.showModal = true;
  }

  closeModal() {
    this.showModal = false;
  }
}
