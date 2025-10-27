public with sharing class InvoicePdfDto {

    public Date issueDate;
    public Date dueDate;
    public String invoiceNumber;
    public String patient;
    public String patientAddress;
    public String treatment;
    public String description;
    public String price;

    public static InvoicePdfDto parse(Invoice__c inv) {
        InvoicePdfDto dto = new InvoicePdfDto();
        dto.issueDate = inv.Issue_Date__c;
        dto.dueDate = inv.Due_Date__c;
        dto.invoiceNumber = inv.Name;
        dto.patient = inv.Patient__r.Name;
        dto.patientAddress = inv.Patient__r.Address__c;
        dto.treatment = inv.Appointment__r.Treatment__r.Name;
        dto.description = inv.Appointment__r.Treatment__r.Description__c;
        dto.price = String.valueOf(inv.Total_Amount__c);
        return dto;
    }
}