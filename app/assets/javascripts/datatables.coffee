jQuery ->
  table = $("#invoices").dataTable
    dom: "<'row'<'col-sm-4'l><'col-sm-4 text-center'B><'col-sm-4'f>>tp",

    oLanguage: {
      sProcessing: "<img src='/assets/ajax-loader.gif'>"
    },
    bProcessing: true

    bServerSide: true
    sAjaxSource: $('#invoices').data('source')

    lengthMenu: [ [10, 25, 50, -1], [10, 25, 50, "All"] ]
    buttons: [
        {extend: 'excel', title: 'Invoices', className: 'btn-sm'},
        {extend: 'csv', title: 'Invoices', className: 'btn-sm'},
        {extend: 'pdf', title: 'Invoices', className: 'btn-sm'},
        {extend: 'print', title: 'Invoices', className: 'btn-sm'}
    ]

    columnDefs: [ {
      targets: 'no-sort',
      orderable: false
      }, {
      targets: 'align-center',
      className: 'text-center'
    } ]

  # Customers
  table = $("#customers").dataTable
    oLanguage: {
      sProcessing: "<img src='/assets/ajax-loader.gif'>"
    },
    bProcessing: true

    bServerSide: true
    sAjaxSource: $('#customers').data('source')

    columnDefs: [ {
      targets: 'no-sort',
      orderable: false
      }, {
      targets: 'align-center',
      className: 'text-center'
    } ]




