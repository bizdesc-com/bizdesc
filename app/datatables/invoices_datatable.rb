class InvoicesDatatable
  delegate :params, :link_to, :content_tag, :current_account, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Invoice.count,
      iTotalDisplayRecords: invoices.total_entries,
      aaData: data
    }
  end

  private
    def data
      invoices.map do |invoice|
        name = nil
        if invoice.sale.name
          name = invoice.sale.name
        elsif invoice.project.name
          name = invoice.project.name
        end

        running_total = 0
        invoice.items.each do |item|
          running_total += item.total
        end

        status_label_class = ''
        if invoice.status.eql?('PAID')
          status_label_class = 'label label-success'
        elsif invoice.status.eql?('PENDING')
          status_label_class = 'label label-warning'
        elsif invoice.status.eql?('OVERDUE')
          status_label_class = 'label label-danger'
        end

        [
          invoice.id,

          name,

          invoice.customer.name,
          invoice.user.first_name,
          invoice.date_of_an_invoice.strftime("%d/%m/%Y"),

          number_to_currency(running_total),

          content_tag(:span, invoice.status, class: status_label_class),

          link_to(content_tag(:i, " View", class: 'fa fa-eye'), invoice, class: 'btn btn-info btn-xs')
        ]
      end
    end

    def invoices
      @invoices ||= fetch_invoices
    end

    def fetch_invoices
      invoices = Invoice.order("#{sort_column} #{sort_direction}")
      invoices = invoices.page(page).per_page(per_page)
      if params[:sSearch].present?
        invoices = Invoice.joins(:customer).where("name like :search or email like :search", search: "%#{params[:sSearch]}")
      end
      invoices
    end

    def page
      params[:iDisplayStart].to_i/per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
    end

    def sort_column
      columns = %w[id first_name date_of_an_invoice deadline running_total status_type invoice]
      columns[params[:iSortCol_0].to_i]
    end

    def sort_direction
      params[:sSortDir_0] == "desc" ? "desc" : "asc"
    end
end