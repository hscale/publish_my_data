// object to setup a grid for sparql results
(function ($) {

  // ctor
  function SparqlResultsGrid(encodedQuery) {

    var SLICKGRIDOPTIONS = {
        enableCellNavigation: false
      , enableColumnReorder: false
      , syncColumnCellResize: true
      , rowHeight: 24
      , enableTextSelectionOnCells: true
      }
    , ROWNUMBERSCOLUMNWIDTH = 55
    , COLUMNWIDTH = 270
    , PAGESIZE = 20
    , INITIALTOTALCOUNT = 500
    , TOTALCOUNTMARGIN = 200
    , TOTALCOUNTEXTENDAMOUNT = 200

    var totalCount = INITIALTOTALCOUNT;
    var columns = null;
    var loader = new Swirrl.DataLoader(totalCount, PAGESIZE);
    var slickGrid = new Slick.Grid('#results-grid.data-grid', loader.data, [], SLICKGRIDOPTIONS);

    $(document).on("click", ".slick-cell", function() {
      $(this).selectText();
    });

    // These are thte same methods as in the cube grid. Refactor??
    function setGridStatus(status, busy) {
      $(".grid-status .status-value").empty();
      $(".grid-status .status-value").append(status);

      if (busy) {
        $(".grid-status img.busy").show();
      } else {
        $(".grid-status img.busy").hide();
      }
    }

    function setGridError(httpStatusCode) {
      $(".grid-status img.busy").hide();
      $(".grid-status .status-value").empty();
      if (httpStatusCode == 500 || httpStatusCode == 400) {
        $(".grid-status .status-value").append('<i class="icon-warning"></i> Error fetching data');
      } else if (httpStatusCode == 503) {
        $(".grid-status .status-value").append('<i class="icon-warning"></i> Query timed out');
      }
    }

    function setColumns(responseData) {
      var vars = responseData["head"]["vars"];
      columns = [{id: '__row_num', field: '__row_num', name: '#', width: ROWNUMBERSCOLUMNWIDTH, cssClass: 'row-num' }];
      $.each(vars, function(i, col) {
        columns.push({id: col, name: col, field: col, width: COLUMNWIDTH});
      });
      slickGrid.setColumns(columns);
    }

    function loaderFunction(pageIndex) {

      function processResponseData(responseData) {
        // set the columns onto the grid if we haven't already
        if(!columns) { setColumns(responseData); }

        var rowsData = [];
        var results = responseData["results"]["bindings"];

        // go through the results, and make rows data.
        for (var i = 0; i < results.length; i++) {
          var resultsRow = null;
          resultsRow = {};
          for (var col in results[i]) {
            resultsRow[col] = results[i][col]["value"];
          }
          rowsData.push(resultsRow);
        }
        return rowsData;
      };

      var theUrl = "/sparql.json?query=" + encodedQuery +
        "&page=" + (pageIndex+1).toString() + // we use one-based pagination on the server.
        "&per_page=" + PAGESIZE.toString();

      setGridStatus('Getting data...', true);
      req = $.ajax({
        url: theUrl,
        dataType: 'json',
        success: function(responseData, _, jqXHR) {
          loader.setPageOfData(jqXHR.page, processResponseData(responseData));
          setGridStatus('Grid Ready.');
        },
        error: function( jqXHR, _, _ ) {
          setGridError(jqXHR.status);
        }
      });
      req.page = pageIndex; // add a page property onto the jqXHR obj
    }

    // initialisation...

    // when a bunch of rows are loaded,
    // re-render them.
    loader.onDataLoaded.subscribe(function (e, args) {
      for (var i = args.from; i <= args.to; i++) {
        slickGrid.invalidateRow(i); // causes the appropriate rows to redraw.
      }
      slickGrid.updateRowCount(); // uses data.length
      slickGrid.render();
    });

    // When the viewport changes, ensure the loader has the relevent data.
    // (when scrolling stops for 200ms)
    var viewportChangedTimer;

    slickGrid.onViewportChanged.subscribe(function (e, args) {
      clearTimeout(viewportChangedTimer);
      viewportChangedTimer = setTimeout( function() {

        // extend the grid if near the bottom
        if( slickGrid.getViewport().bottom > (totalCount - TOTALCOUNTMARGIN) ) {
          totalCount = totalCount + TOTALCOUNTEXTENDAMOUNT;
          loader.updateTotalCount( totalCount );
        }

        loader.ensureData(slickGrid.getViewport().top, slickGrid.getViewport().bottom, loaderFunction);
       }, 200); // 200ms delay.
    });

    loader.ensureData(slickGrid.getViewport().top, slickGrid.getViewport().bottom, loaderFunction);
  }

  $.extend(true, window, { Swirrl: { SparqlResultsGrid: SparqlResultsGrid }});
})(jQuery);