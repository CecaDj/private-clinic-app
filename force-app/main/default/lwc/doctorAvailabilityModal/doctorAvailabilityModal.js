import { LightningElement, api } from 'lwc';
import getAllTreatments from '@salesforce/apex/TreatmentController.getAllTreatments';
import getAvailableSlots from '@salesforce/apex/DoctorController.getAvailableSlots';
import bookAppointment from '@salesforce/apex/AppointmentController.bookAppointment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DoctorAvailabilityModal extends LightningElement {
  @api doctorId;
  @api doctorName;

  treatments = []; 
  slots = []; 
  selectedTreatmentId; 
  selectedDate; 
  selectedSlot; 
  showConfirm = false; 

  connectedCallback() {
    this.loadTreatments();
  }

  async loadTreatments() {
    try {
      const result = await getAllTreatments();
      // Convert list into label/value pairs for lightning-combobox
      this.treatments = result.map(t => ({ label: t.Name, value: t.Id }));
    } catch (e) {
      this.showToast('Error', 'Could not load treatments', 'error');
    }
  }

  handleTreatmentChange(e) {
    this.selectedTreatmentId = e.detail.value;
  }

  handleDateChange(e) {
    this.selectedDate = e.target.value;
  }

  // Disable "Check Availability" button until both date and treatment selected
  get disableCheck() {
    return !(this.selectedTreatmentId && this.selectedDate);
  }

  async fetchSlots() {
    this.slots = [];
    try {
      const res = await getAvailableSlots({
        doctorId: this.doctorId,
        selectedDate: this.selectedDate,
        treatmentId: this.selectedTreatmentId
      });
      this.slots = res || [];
      if (!this.slots.length) {
        this.showToast('No Slots', 'No available slots for this date.', 'warning');
      }
    } catch (e) {
      this.showToast('Error', e?.body?.message || e?.message, 'error');
    }
  }

  // Highlight the selected slot
  selectSlot(event) {
    this.selectedSlot = event.currentTarget.dataset.slot;

    // Unselect all other slots
    this.template.querySelectorAll('.slot').forEach(slot => {
      slot.classList.remove('selected');
    });

    // Highlight the clicked slot
    event.currentTarget.classList.add('selected');
  }

  // Trigger confirmation modal before booking
  handleBookClick() {
    if (!this.selectedSlot) {
      this.showToast('Error', 'Please select a slot first.', 'error');
      return;
    }
    this.showConfirm = true;
  }

  // Close confirmation modal
  closeConfirm() {
    this.showConfirm = false;
  }

  // Confirm booking and call Apex to create Appointment__c record
  async confirmBooking() {
    try {
      const msg = await bookAppointment({
        doctorId: this.doctorId,
        treatmentId: this.selectedTreatmentId,
        selectedDate: this.selectedDate,
        startTimeHHmm: this.selectedSlot
      });
      this.showToast('Success', msg, 'success');
      // Reset state
      this.showConfirm = false;
      this.slots = [];
      this.selectedSlot = null;
    } catch (e) {
      this.showToast('Error', e?.body?.message || e?.message, 'error');
    }
  }

  // Close entire modal
  close() {
    this.dispatchEvent(new CustomEvent('closemodal'));
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}
