class InvoicesController < ApplicationController 
  #before_action :set_invoice, only: [:show, :edit, :upate, :destroy]
  
  def index
    @invoices = Invoice.all

    search_params = params[:search]
    unless search_params.blank?
      @search = InvoiceSearch.new(search_params)
      @invoices = @search.scope
    end

    respond_to do |format|
      format.html
      format.csv { render text: @invoices.to_csv }  
      format.xls #{ render text: @invoices.to_csv(col_sep: "\t") }  
    end  
  end

  def new
    @invoice = Invoice.new
  end

  def create
    @invoice = Invoice.new(invoice_params)
    if @invoice.save
      redirect_to invoices_path, notice: I18n.t('invoices.create.notice_create')
    else
      render :new
    end  
  end

  # GET /invoices/1
  def show 
    @invoice = Invoice.find(params[:id]) 
  end

  # GET /invoices/1/edit
  def edit
    @invoice = Invoice.find(params[:id]) 
  end

  def update
    @invoice = Invoice.find(params[:id]) 
    if @invoice.update_attributes(invoice_params)
      flash.now[:success] = I18n.t('invoices.update.success_update')
      render :show
    else
      render :edit
    end 
  end

  def destroy
    @invoice = Invoice.find(params[:id]) 
    if @invoice.destroy
      redirect_to invoices_url, notice: I18n.t('invoices.destroy.success_delete')
    else
      flash.now[:error] = I18n.t('invoices.distroy.error_delete')
    end  
  end

  def import
    #import = Invoice.import(params[:file])
    #if !import.nil? && import[:errors].present?
    #  redirect_to invoices_path, alert: import[:errors] 
    #else 
    #  redirect_to invoices_path, notice: I18n.t('invoices.import.notice_import')
    #end  

    invoice_import = InvoiceImport.load_imported_invoices(params[:file])
    if invoice_import.any? && invoice_import.is_a?(Hash)
      @errors = Array.new
      invoice_import.each do |key, value|
        if key.to_s.eql?("errors")
          @errors.push(value)
        else  
          @errors.push("#{key} " + value.join(', '))
        end  
      end
      redirect_to invoices_path, alert: @errors 
    else 
      redirect_to invoices_path, notice: I18n.t('invoices.import.notice_import')
    end  
  end

  private
    def invoice_params
      params.require(:invoice).permit(:customer, :salesperson, :date_of_an_invoice, 
        :deadline, :payment_term, :interest_in_arrears, :reference_number, :description)
    end  

end