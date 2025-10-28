// Schedule GenerateInvoicesBatch at 2:00 AM daily
System.schedule('Generate Invoices Nightly', '0 0 2 * * ?', new GenerateInvoicesScheduler());

// Schedule DownloadInvoicesBatch at 2:30 AM daily
System.schedule('Download Invoices Nightly', '0 30 2 * * ?', new DownloadInvoicesScheduler());

// Schedule InvoicePaymentLinkBatch every day at midnight
System.schedule('Invoice Payment Link Nightly', '0 0 0 * * ?', new InvoicePaymentLinkScheduler());