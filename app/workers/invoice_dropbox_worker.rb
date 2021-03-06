require 'dropbox_sdk'

class InvoiceDropboxWorker
  include Sidekiq::Worker
  sidekiq_options queue: (ENV['ARCHIVE_QUEUE'] || 'reckoning-archive').to_sym

  def perform invoice_id
    invoice = Invoice.find invoice_id

    if invoice.present?
      client = ::DropboxClient.new(invoice.user.dropbox_token)

      if File.exists?(invoice.timesheet_path)
        client.put_file("#{invoice.customer.fullname}/#{invoice.project.name}/#{invoice.invoice_file}", open(invoice.pdf_path), true)
      end

      if File.exists?(invoice.timesheet_path)
        client.put_file("#{invoice.customer.fullname}/#{invoice.project.name}/#{invoice.timesheet_file}", open(invoice.timesheet_path), true)
      end
    end
  end
end
