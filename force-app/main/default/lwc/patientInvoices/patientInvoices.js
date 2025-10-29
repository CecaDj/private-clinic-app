import { LightningElement } from 'lwc';
import getPatientInvoices from '@salesforce/apex/InvoiceController.getPatientInvoices';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PatientInvoices extends LightningElement {
  invoices = [];
  isLoading = true;
  error;
  noInvoices = false;

  columns = [
    { label: 'Invoice #', fieldName: 'InvoiceNumber' },
    {
      label: 'Date',
      fieldName: 'Date',
      type: 'date',
      typeAttributes: { year: 'numeric', month: 'short', day: '2-digit' }
    },
    {
      label: 'Amount',
      fieldName: 'Amount',
      type: 'currency',
      typeAttributes: { currencyCode: 'USD' }
    },
    { label: 'Status', fieldName: 'Status', type: 'text' }, 
    {
    type: 'button',
    label: 'Pay',
    typeAttributes: {
      label: 'Pay',
      name: 'pay',
      variant: 'brand',
      disabled: { fieldName: 'disablePay' } 
    }
   }

  ];

  connectedCallback() {
    this.loadInvoices();
  }

  async loadInvoices() {
    this.isLoading = true;
    this.error = null;

    try {
      const raw = await getPatientInvoices();

      this.invoices = raw.map(inv => {
        const isPaid = inv.Status === 'Paid';
        const isCancelled = inv.Status === 'Cancelled';
        const canPay = !!inv.PaymentLink && !isPaid && !isCancelled;

        return {
          ...inv,
          disablePay: !canPay // Controls button visibility
        };
      });


      this.noInvoices = this.invoices.length === 0;
    } catch (e) {
      this.error = e?.body?.message || e.message;
    } finally {
      this.isLoading = false;
    }
  }

  handleRowAction(event) {
    const action = event.detail.action?.name;
    const row = event.detail.row;

    if (action === 'pay') {
      if (row?.PaymentLink) {
        window.open(row.PaymentLink, '_blank', 'noopener,noreferrer');
      } else {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error',
            message: 'Payment link not available.',
            variant: 'error'
          })
        );
      }
    }
  }
}
