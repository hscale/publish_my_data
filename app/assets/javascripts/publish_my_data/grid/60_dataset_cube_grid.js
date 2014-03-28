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

      if (queryStringHasInitialDimensions()) {
        var initialDimensions = getDimensionsFromParams();
        loadInitialDimensions(initialDimensions);
      } else {
        // we'll need to load in the default dimensions then
         $.ajax({
            url: "http://" +  siteDomain + "/data/" + datasetSlug + "/cube/recommended_dimensions.json",
            dataType: 'json',
            success: function(recommendedDimensions){
              loadInitialDimensions(recommendedDimensions);
            },
            error: function(jqXHR, _, _) {
              setGridError(jqXHR.status);
            }
          });
      }
    }

    /*

    The grid viewer will attempt to load initial settings from the query string failing this, it requests default dimensions via ajax.

    Example query string:

    http://127.0.0.1:3000/data/school-attainment?rows_dimension=http%3A%2F%2Flinked.glasgow.gov.uk%2Fdef%2FrefSCQFLevel&columns_dimension=http%3A%2F%2Fdata.opendatascotland.org%2Fdef%2Fstatistical-dimensions%2FrefPeriod&http%3A%2F%2Flinked.glasgow.gov.uk%2Fdef%2FrefQualificationsAwarded=http%3A%2F%2Flinked.glasgow.gov.uk%2Fdef%2Fconcept%2Fschools%2Fqualifications-awarded%2F5-or-more&http%3A%2F%2Flinked.glasgow.gov.uk%2Fdef%2FrefSchoolSet=http%3A%2F%2Flinked.glasgow.gov.uk%2Fid%2Furban-assets%2Fschools%2Fschool-set%2Fglasgow&http%3A%2F%2Flinked.glasgow.gov.uk%2Fdef%2FrefYearGroup=http%3A%2F%2Flinked.glasgow.gov.uk%2Fdef%2Fconcept%2Fschools%2Fyear-group%2Fs4

    or (same thing again, with friendlier formatting)

    http://127.0.0.1:3000/data/school-attainment?
    rows_dimension=http%3A%2F%2Flinked.glasgow.gov.uk%2Fdef%2FrefSCQFLevel
   &columns_dimension=http%3A%2F%2Fdata.opendatascotland.org%2Fdef%2Fstatistical-dimensions%2FrefPeriod
   &http%3A%2F%2Flinked.glasgow.gov.uk%2Fdef%2FrefQualificationsAwarded=http%3A%2F%2Flinked.glasgow.gov.uk%2Fdef%2Fconcept%2Fschools%2Fqualifications-awarded%2F5-or-more
   &http%3A%2F%2Flinked.glasgow.gov.uk%2Fdef%2FrefSchoolSet=http%3A%2F%2Flinked.glasgow.gov.uk%2Fid%2Furban-assets%2Fschools%2Fschool-set%2Fglasgow
   &http%3A%2F%2Flinked.glasgow.gov.uk%2Fdef%2FrefYearGroup=http%3A%2F%2Flinked.glasgow.gov.uk%2Fdef%2Fconcept%2Fschools%2Fyear-group%2Fs4

    */

    function getRowsDimensionFromParams(){
      return params.rows_dimension;
    }

    function getColsDimensionFromParams(){
      return params.columns_dimension;
    }

    function getLockedDimensionsFromParams(){
      var locked = {};
      for(var key in params){
        if (looksLikePredicate(key)){
          var predicate = decodeURIComponent(key);
          var val = decodeURIComponent(params[key]);
          locked[predicate] = val;
        }
      }
      return locked;
    }

    function looksLikePredicate(candidate){
      if (candidate === "rows_dimension") return false;
      if (candidate === "columns_dimension") return false
      return true; // TODO - assumes that we don't have any other query params probably better to actually look for something that begins http://
    }

    function getDimensionsFromParams(){
      var initalDimensions = {};
      initalDimensions["rows_dimension"] = decodeURIComponent(getRowsDimensionFromParams());
      initalDimensions["columns_dimension"] = decodeURIComponent(getColsDimensionFromParams());
      initalDimensions["locked_dimensions"] = getLockedDimensionsFromParams();
      return initalDimensions;
    }
    function queryStringHasInitialDimensions(){
      return(getColsDimensionFromParams() && getColsDimensionFromParams());
    }

    function loadInitialDimensions(initalDimensions){
      // for locked dims, just set the uris
      for ( var dim in initalDimensions.locked_dimensions ) {
        cubeGrid.setLockedDimensionValue( dim, initalDimensions.locked_dimensions[dim] )
      }
      // for the other dimensions, find the appropriate object
      var columnsDimension = cubeGrid.getDimensionWithUri(initalDimensions.columns_dimension);
      var rowsDimension = cubeGrid.getDimensionWithUri(initalDimensions.rows_dimension);

      cubeGrid.setColumnsDimension(columnsDimension);
      cubeGrid.setRowsDimension(rowsDimension);
      cubeGrid.showCSVDownloadLink();
    }

    function decomposeQueryString(){
      var params = {};
      var qs = window.location.search.substring(1);
      var qss = qs.split("&");
      for (var i=0;i<qss.length;i++) {
        var q = qss[i].split("=");
        params[q[0]]=q[1];
      }
      return params;
    }

    // set initial status
    setTitle('&nbsp;');
    setGridStatus('Initializing grid...', true);

    var params = decomposeQueryString();

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
