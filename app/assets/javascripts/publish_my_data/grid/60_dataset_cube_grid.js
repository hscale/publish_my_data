// object to setup a cube grid for a pmd dataset, and wire everything together.
(function ($) {

  function DatasetCubeGrid(siteDomain, datasetSlug, datasetTitle, elementSelector) {

    var pageSize = 25
        , cubeDimensions = null
        , cubeDimensionsControls = null
        ;

    function setGridStatus(status, busy) {
      $(".grid_status .status-value").empty();
      $(".grid_status .status-value").append(status);

      if (busy) {
        $(".grid_status img.busy").show();
      } else {
        $(".grid_status img.busy").hide();
      }
    }

    function setGridError(httpStatusCode) {
      $(".grid_status img.busy").hide();
      $(".grid_status .status-value").empty();
      if (httpStatusCode == 500 || httpStatusCode == 400) {
        $(".grid_status .status-value").append('<i class="icon-warning"></i> Error fetching data');
      } else if (httpStatusCode == 503) {
        $(".grid_status .status-value").append('<i class="icon-warning"></i> Query timed out');
      }
    }

    function setDimensionsStatus(status, busy){
      $(".dimensions-status .status-value").empty();
      $(".dimensions-status .status-value").append(status);

      if (busy) {
        $(".dimensions-status").show();
        $(".dimensions-status img.busy").show();
      } else {
        $(".dimensions-status").hide();
        $(".dimensions-status img.busy").hide();
      }
    }

    function showDimensionsControls() {
      $("#dimensions_controls form").show();
    }

    function showOptionsToggler() {
      $("#options-toggler").show();
    }

    function setTitle(title) {
      $("#cube_grid_title").empty();
      $("#cube_grid_title").append(title);
    }

    function calculateGridTitle() {
      var title = datasetTitle;
      var lockedDimensionLabels = cubeDimensionsControls.getLockedDimensionValueLabels();
      if ( lockedDimensionLabels.length > 0 ) {
        title += ' (';
        $.each(lockedDimensionLabels, function(i, label) {
          title += label;
          if ( lockedDimensionLabels.length-1 != i ){
            title += ", ";
          }
        });
        title += ')';
      }
      return title;
    }

    function wireUpCubeDimensionsEvents() {

      cubeDimensionsControls.onInitialized.subscribe(function (e,args) {

        showDimensionsControls();
        showOptionsToggler();
        setDimensionsStatus('', false);

        // once the controls are initialized...
        setTitle(calculateGridTitle()); // set initial title

        // wire up the ready/busy events
        cubeDimensionsControls.onReady.subscribe(function (e, args) {
          cubeDimensionsControls.enable();
          setDimensionsStatus('', false);

          // re-init grid
          cubeGrid.clear();
          cubeGrid.initGridWhenReady();

          // set locked dims
          $.each(cubeDimensionsControls.getLockedDimensionUris(), function(i, lockedDimUri) {
            var value = cubeDimensionsControls.getLockedDimensionValues()[i];
            cubeGrid.setLockedDimensionValue(lockedDimUri, value);
          });

          // set rows and cols
          cubeGrid.setRowsDimension(cubeDimensionsControls.getRowsDimension());
          cubeGrid.setColumnsDimension(cubeDimensionsControls.getColumnsDimension());

          cubeGrid.showCSVDownloadLink();
          setTitle(calculateGridTitle());
        });

        cubeDimensionsControls.onBusy.subscribe(function (e, args) {
          setTitle('&nbsp;');
          cubeGrid.hideCSVDownloadLink();
          setDimensionsStatus('Re-calculating options...', true);
          setGridStatus('Re-initializing grid...', true);
          cubeDimensionsControls.disable(); // disable the controls while they're busy.
        });

        // and enable the controls
        cubeDimensionsControls.enable();
      });

    }

    function setInitialGridStatus() {
      // unsubscribe
      cubeGrid.onCubeDimensionsReady.unsubscribe(setInitialGridStatus);

      $.ajax({
        url: "http://" +  siteDomain + "/data/" + datasetSlug + "/cube/recommended_dimensions.json",
        dataType: 'json',
        success: function(recommendedDimensions){

          // for locked dims, just set the uris
          for ( var dim in recommendedDimensions.locked_dimensions ) {
            cubeGrid.setLockedDimensionValue( dim, recommendedDimensions.locked_dimensions[dim] )
          }

          // for the other dimensions, find the appropriate object
          var columnsDimension = cubeGrid.getDimensionWithUri(recommendedDimensions.columns_dimension);
          var rowsDimension = cubeGrid.getDimensionWithUri(recommendedDimensions.rows_dimension);

          cubeGrid.setColumnsDimension(columnsDimension);
          cubeGrid.setRowsDimension(rowsDimension);
          cubeGrid.showCSVDownloadLink();
        },
        error: function(jqXHR, _, _) {
          setGridError(jqXHR.status);
        }
      });

    }

    // set initial status
    setTitle('&nbsp;');
    setGridStatus('Initializing grid...', true);

    var cubeGrid = new Swirrl.CubeGrid(elementSelector, siteDomain, datasetSlug, pageSize);

    cubeGrid.onAjaxError.subscribe(function (e, args) {
      setGridError(args.status);
    });

    // subscribe to grid events.
    cubeGrid.onGridReady.subscribe(function (e, args) {
      setGridStatus("", false); // was "Grid ready"
    });

    var gridInitializedHandler = function (e, args) {
      cubeDimensionsControls = new Swirrl.CubeDimensionsControls(cubeGrid, ".dimensions_controls");
      wireUpCubeDimensionsEvents();
      cubeDimensionsControls.init();
      cubeGrid.onGridInitialized.unsubscribe(gridInitializedHandler);// only do 1st time round.
    }

    cubeGrid.onGridInitialized.subscribe(gridInitializedHandler);

    cubeGrid.onGridGettingData.subscribe(function (e, args) {
      setGridStatus("Getting data...", true)
    });

    // tell the grid to get all it's dimensions (and set up init grid status when they're ready).
    cubeGrid.onCubeDimensionsReady.subscribe(setInitialGridStatus);
    cubeGrid.getAllDimensionsAsync();

  }


  $.extend(true, window, { Swirrl: { DatasetCubeGrid: DatasetCubeGrid }});
})(jQuery);