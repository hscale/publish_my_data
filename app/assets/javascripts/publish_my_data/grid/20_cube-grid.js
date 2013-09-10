(function ($) {

  // add key counting to old browsers.
  // https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Global_Objects/Object/keys
  if (!Object.keys) {
    Object.keys = (function () {
      var hasOwnProperty = Object.prototype.hasOwnProperty,
          hasDontEnumBug = !({toString: null}).propertyIsEnumerable('toString'),
          dontEnums = [
            'toString',
            'toLocaleString',
            'valueOf',
            'hasOwnProperty',
            'isPrototypeOf',
            'propertyIsEnumerable',
            'constructor'
          ],
          dontEnumsLength = dontEnums.length;

      return function (obj) {
        if (typeof obj !== 'object' && typeof obj !== 'function' || obj === null) throw new TypeError('Object.keys called on non-object');

        var result = [];

        for (var prop in obj) {
          if (hasOwnProperty.call(obj, prop)) result.push(prop);
        }

        if (hasDontEnumBug) {
          for (var i=0; i < dontEnumsLength; i++) {
            if (hasOwnProperty.call(obj, dontEnums[i])) result.push(dontEnums[i]);
          }
        }
        return result;
      }
    })()
  };

  // constructor
  function CubeGrid(elementSelector, siteDomain, datasetSlug, pageSize) {

    // some constants.
    //////////////////

    var SLICKGRIDOPTIONS = {
          enableCellNavigation: false
        , enableColumnReorder: false
        , syncColumnCellResize: true
        , rowHeight: 24
        }

      , ROWNUMBERSCOLUMNWIDTH = 60
      , FIRSTCOLUMNWIDTH = 280
      , COLUMNWIDTH = 200
      ;

    // object-level vars.
    //////////////////

    var loader = null
      , slickGrid = null
      , urlBase = "http://" +  siteDomain + "/data/" + datasetSlug + "/cube"
      , cubeDimensions = null // an array of cubeDimension objects.
      , rowsDimension = null
      , lockedDimensions = {}
      , columnsDimension = null
      , gridSize = null
      , gridColumns = null
      , orderByColumn = null // order by rows by default
      , orderDesc = false // order asc by default
      ;

    // events
    //////////////////

    var onCubeDimensionsReady = new Slick.Event()
      , onGridSizeReady = new Slick.Event()
      , onGridColumnsReady = new Slick.Event()
      , onGridGettingData = new Slick.Event()
      , onGridReady = new Slick.Event()
      , onGridInitialized = new Slick.Event()
      , onAjaxError = new Slick.Event()
      ;

    // some setup.
    ///////////////

    // we will construct the slick grid once we have enough information.

    function initGridWhenReady() {

      function readyHandler(e, args) {
        if (gridPrerequisitesReady()) {
          initGrid();

          // only do this once.
          onGridSizeReady.unsubscribe(readyHandler);
          onGridColumnsReady.unsubscribe(readyHandler);
        }
      }

      onGridSizeReady.subscribe(readyHandler);
      onGridColumnsReady.subscribe(readyHandler);
    }

    initGridWhenReady();

    // private funcs
    //////////////////

    function checkLockedDimensions() {

      if(cubeDimensions) {
        // there should be exactly 2 less locked dimensions than dimensions
        return !!((cubeDimensions.length -2) == Object.keys(lockedDimensions).length);
      } else {
        alert('no dimensions exist');
        return false;
      }
    }

    function gridPrerequisitesReady(){
      var ready = !!(gridSize && gridColumns && checkLockedDimensions());
      return ready;
    }

    function clear() {
      // clear out the display
      $(elementSelector).empty();

      // reset some stuff dimensions.
      rowsDimension = null
      lockedDimensions = {}
      columnsDimension = null
      gridSize = null
      gridColumns = null
      orderByColumn = null // order by rows by default
      orderDesc = false // order asc by default
    }

    function initGrid() {
      // when we've got grid size, columns, and the lockedDimensions we can construct the grid
      if(!checkLockedDimensions()) {
        alert('missing locked dimensions');
        return;
      }

      // construct the grid with a loader.
      loader = new Swirrl.DataLoader(gridSize, pageSize);
      slickGrid = new Slick.Grid(elementSelector, loader.data, gridColumns, SLICKGRIDOPTIONS);
      slickGrid.setSortColumn(rowsDimension.uri, true); // start it off being sorted by row dimension, asc

      // now subscribe to some events:
      ////////////////////////////////

      // high level busy and ready events:
      loader.onReady.subscribe(function() {
        onGridReady.notify();
      });

      loader.onBusy.subscribe(function() {
        onGridGettingData.notify();
      });

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
          loader.ensureData(slickGrid.getViewport().top, slickGrid.getViewport().bottom, dataLoaderFunction);
         }, 200); // 200ms delay.
      });

      // Sorting behaviour:
      slickGrid.onSort.subscribe(function (e, args) {

        // hack to avoid sorting when clicking on links in col headers
        // (by setting sort back to what it was before click).
        if ($(e.target).hasClass('cell-link')) {
          if(orderByColumn == null) {
            slickGrid.setSortColumn(rowsDimension.uri, (!orderDesc));
          } else {
            slickGrid.setSortColumn(orderByColumn, (!orderDesc));
          }
          return false;  // and do nothing else
        }

        // work out the column and order to sort by
        if (args.sortCol.field == rowsDimension.uri) {
          orderByColumn = null;
        } else {
          orderByColumn = args.sortCol.field;
        }
        orderDesc = args.sortAsc ? false : true;

        // tell the loader to re-get the data.
        loader.clear();
        slickGrid.setData(loader.data, true);
        loader.ensureData(slickGrid.getViewport().top, slickGrid.getViewport().bottom, dataLoaderFunction);
        showCSVDownloadLink();
      });

      // finally, ensure the loader has the right data,
      // to initialise the first 'page' of results
      //////////////////
      loader.ensureData(slickGrid.getViewport().top, slickGrid.getViewport().bottom, dataLoaderFunction);

      // and set that we're initialized
      onGridInitialized.notify();
    }

    // the function that the loader uses to get the data
    function dataLoaderFunction(page) {

      function processResponseData(responseData) {
        var start = new Date();

        var processedData = [];

        for( var i=0; i < responseData.length; i++ ) {
          var row = responseData[i];

          var processedRow = {};

          for (var key in row) {
            // for all keys except the row values or row labels...
            if (!(key == rowsDimension.uri || key == "rowlabel" ) ){
              var obsUri = row[key]["obs"];
              var obsVal = row[key]["val"];
              processedRow[key] = buildUriLink(obsUri, (obsVal || "").toString());
            }
          }

          // set the value of the row-dimension column
          var rowUri = row[rowsDimension.uri];
          var rowLabel = row["rowlabel"];
          processedRow[rowsDimension.uri] = buildUriLink(rowUri, (rowLabel || rowUri));

          processedData.push(processedRow);
        }
        return processedData;
      }

      var url = buildObservationsUrl('json', page);

      var req = $.ajax({
        dataType: 'json',
        url: url,
        success: function(responseData, _, jqXHR) {
          loader.setPageOfData(jqXHR.page, processResponseData(responseData));
        },
        error: function( jqXHR, _, _ ) {
          onAjaxError.notify({status: jqXHR.status});
        }
      });

      req.page = page; // add a page property onto the jqXHR obj

    }


    function buildUriLink(uri, text) {
      var url = uri;

      // if string doesn't start with this domain, use the resource= style
      if(url.indexOf('http://' + siteDomain) != 0) {
        url = 'http://' + siteDomain + '/resource?uri=' + encodeURIComponent(uri);
      }
      return "<a class='cell-link' target='_blank' href='" + url + "'>" + text + "</a>";
    }

    function getCubeDimensions() {
      return cubeDimensions;
    }

    function getDimensionWithUri(uri) {
      var dim = null;
      $.each(cubeDimensions, function(i, d) {
        if (d.uri == uri) {
          dim = d;
          return false;
        }
      });
      return dim;
    }

    // memoized lookup of all cube dimensions.
    function getAllDimensionsAsync(){

      if (!cubeDimensions) {
        cubeDimensions = []; //this is the object-level var.
        $.ajax({
          dataType: 'json',
          url: urlBase + "/dimensions.json",
          success: function(responseData, textStatus, jqXHR) {
            $.each(responseData, function(i, dimension) {
              cubeDimension = new Swirrl.CubeDimension(dimension.uri, dimension.label, urlBase);
              cubeDimension.onAjaxError.subscribe(function (e, args) {
                // bubble up ajax errors to the grid.
                onAjaxError.notify({status: jqXHR.status});
              });
              cubeDimensions.push(cubeDimension);
            });
            onCubeDimensionsReady.notify({cubeDimensions: cubeDimensions});
          },
          error: function( jqXHR, _, _ ) {
            onAjaxError.notify({status: jqXHR.status});
          }
        });
      } else {
        onCubeDimensionsReady.notify({cubeDimensions: cubeDimensions});
      }
    }


    function getSlickGrid() {
      return slickGrid;
    }

    // set the rows dimension to the cubeDimension object passed in.
    function setRowsDimension(cubeDimension) {
      rowsDimension = cubeDimension;

      var sizeReadyHandler = function(e, args) {
        // this is the Size of this dimension
        gridSize = args.size;
        onGridSizeReady.notify({gridSize: gridSize});
        rowsDimension.onSizeReady.unsubscribe(sizeReadyHandler); // only do it once.
      }

      rowsDimension.onSizeReady.subscribe(sizeReadyHandler);
      rowsDimension.getSizeAsync();
    }

    function getRowsDimension() {
      return rowsDimension;
    }

    function setGridColumns(cols) {

      function rawFormatter(row, cell, value, columnDef, dataContext) {
        return value;
      }

      // start with ids...
      gridColumns = [{id: '__row_num', field: '__row_num', name: '#', width: ROWNUMBERSCOLUMNWIDTH, cssClass: 'row-num' }];

      // and rows...
      gridColumns.push({id: rowsDimension.uri, name: buildUriLink(rowsDimension.uri, rowsDimension.label || rowsDimension.uri), field: rowsDimension.uri, width: FIRSTCOLUMNWIDTH, sortable:true, formatter: rawFormatter });

      // finally, all the columns.
      $.each(cols, function(i, col) {
        gridColumns.push({id: col.uri, name: buildUriLink(col.uri, col.label || col.uri), field: col.uri, width: COLUMNWIDTH, sortable:true, formatter: rawFormatter });
      });

      return gridColumns;
    }

    // set the columns dimension to the cubeDimension object passed in.
    function setColumnsDimension(cubeDimension) {
      columnsDimension = cubeDimension;

      var onValuesReadyHandler = function(e, args) {
        // this is the list of columns.
        var cols = args.values;
        setGridColumns(cols);
        onGridColumnsReady.notify({gridColumns: gridColumns});

        // unsubscribe: we only want to do this once.
        columnsDimension.onValuesReady.unsubscribe(onValuesReadyHandler);
      }

      columnsDimension.onValuesReady.subscribe(onValuesReadyHandler);
      columnsDimension.getValuesAsync();
    }

    function getColumnsDimension() {
      return columnsDimension;
    }

    function setLockedDimensionValue(dimensionUri, value) {
      lockedDimensions[dimensionUri] = value;
    }

    function getLockedDimensionValue(dimensionUri) {
      return lockedDimensions[dimensionUri];
    }

    // retuns an array of cubeDimension objects.
    function getLockedDimensionObjects() {
      var retVal = [];

      if (checkLockedDimensions()) {

        var retVal;
        for (var lockedDimensionUri in lockedDimensions) {
          // find the right cube Dimension
          $.each(cubeDimensions, function(i, cubeDim) {
            if(cubeDim.uri == lockedDimensionUri) {
              retVal.push(cubeDim);
            }
          });
        }
      }

      return retVal;
    }

    // if page passed as null, get whole result set.
    function buildObservationsUrl(format, page) {
      var url = urlBase + "/observations." + format;

      url += "?rows_dimension=" + encodeURIComponent(rowsDimension.uri);
      url += "&columns_dimension=" + encodeURIComponent(columnsDimension.uri);

      if (page!=null) { url += "&per_page=" + pageSize.toString(); }
      if (page!=null) { url += "&page=" + (page+1).toString(); } // we use 1-based pages on server
      if (orderDesc) { url += "&order_desc=true"; }
      if (orderByColumn) { url += "&order_by_column=" + encodeURIComponent(orderByColumn); }

      for (var lockedDimension in lockedDimensions) {
        var dimensionVal = lockedDimensions[lockedDimension];
        url += "&" + encodeURIComponent(lockedDimension) + "=" + encodeURIComponent(dimensionVal);
      }

      return url;
    }

    function showCSVDownloadLink() {
      // call hide first, so can call it repeatedly.
      hideCSVDownloadLink();

      var url = buildObservationsUrl('csv', null);

      $(".grid-footer i.icon-download").show();

      var theIcon = $("<i></i>");
      theIcon.addClass("icon-download");

      var theLink = $("<a></a>");
      theLink.addClass("download-csv");
      theLink.attr("href", url);

      theLink.append(theIcon);
      theLink.append(" Download results as CSV");

      $(".grid-footer .footer-content").append(theLink);
    }

    function hideCSVDownloadLink() {
      $(".grid-footer .footer-content a.download-csv").remove();
    }

    // public api.
    //////////////////
    return {

      // methods
      //////////////////
      "getSlickGrid": getSlickGrid
    , "clear": clear

    , "getAllDimensionsAsync": getAllDimensionsAsync // raises cubeDimensionsReady when cubeDimensions ready

    , "setRowsDimension": setRowsDimension
    , "getRowsDimension": getRowsDimension

    , "setColumnsDimension": setColumnsDimension
    , "getColumnsDimension": getColumnsDimension

    , "setLockedDimensionValue": setLockedDimensionValue
    , "getLockedDimensionValue": getLockedDimensionValue
    , "getLockedDimensionObjects": getLockedDimensionObjects

    , "checkLockedDimensions": checkLockedDimensions
    , "getCubeDimensions": getCubeDimensions
    , "getDimensionWithUri": getDimensionWithUri

    , "showCSVDownloadLink": showCSVDownloadLink
    , "hideCSVDownloadLink": hideCSVDownloadLink


    , "initGridWhenReady": initGridWhenReady // re-initialises grid from currently set dims when all the pre-reqs have arrived.

      // events
      //////////////////
    , "onCubeDimensionsReady": onCubeDimensionsReady
    , "onGridSizeReady": onGridSizeReady
    , "onGridColumnsReady": onGridColumnsReady

    , "onGridGettingData": onGridGettingData
    , "onGridReady": onGridReady
    , "onGridInitialized": onGridInitialized
    , "onAjaxError": onAjaxError
    }
  }

  // Swirrl.CubeGrid
  $.extend(true, window, { Swirrl: { CubeGrid: CubeGrid }});
})(jQuery)