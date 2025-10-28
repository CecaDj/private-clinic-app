import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMyPatientId from '@salesforce/apex/PatientController.getMyPatientId';
import isPatientProfileComplete from '@salesforce/apex/PatientController.isPatientProfileComplete';

import { getRecord } from 'lightning/uiRecordApi';
import FUNDING_FIELD from '@salesforce/schema/Patient__c.Funding_Type__c';

export default class PatientProfile extends LightningElement {

    patientId;
    showIncompleteBanner = false;
    isLoading = true;
    showInsuranceField = false;

    connectedCallback() {
        this.initializeProfile();
    }

    async initializeProfile() {
        this.isLoading = true;
        try {
            this.patientId = await getMyPatientId();

            if (!this.patientId) {
                this.showToast('Error', 'No patient record found for your user.', 'error');
                return;
            }

            const isComplete = await isPatientProfileComplete();
            this.showIncompleteBanner = !isComplete;

        } catch (error) {
            console.error('Error loading patient profile:', error);
            this.showToast('Error', 'Failed to load your profile.', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    // Automatically show/hide Insurance field based on existing record
    @wire(getRecord, { recordId: '$patientId', fields: [FUNDING_FIELD] })
    wiredPatient({ data }) {
        if (data) {
            const funding = data.fields.Funding_Type__c.value;
            this.showInsuranceField = (funding === 'Insured'); // null or Self-Funding → false
        }
    }

    // Handles when user changes Funding Type
    handleFundingChange(event) {
        this.showInsuranceField = (event.detail.value === 'Insured');
    }

    handleSuccess() {
        this.showToast('Success', 'Your profile was updated successfully.', 'success');
        this.showIncompleteBanner = false;
    }

    handleError(event) {
        console.error('Error updating profile:', event.detail);
        this.showToast('Error', 'Unable to save your profile.', 'error');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
