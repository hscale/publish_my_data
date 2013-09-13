(function ($) {

  // object to marshall communication between the grid and all the dimension controls
  function CubeDimensionsControls(cubeGrid, containerSelector) {

    // private vars
    var rowsDimensionDropdown = null
      , columnsDimenesionDropdown = null
      , lockedDimensionValuesDropdowns = []
      , lockedDimensionLabelControls = []
      , initialized = false
      ;

    // events
    var onReady = new Slick.Event();
    var onBusy = new Slick.Event();
    var onInitialized = new Slick.Event();

    // private functions
    /////////////////////

    function init() {

      onBusy.notify();

      // make sure we've got all the dimensions we need. We assume that the cube has retrieved it's dimensions before starting here.
      if (!checkDimensions() ){
        return false;
      }

      //  drop downs for the row and col dimensions.
      createRowsDimensionDropdown();
      createColumnsDimensionDropdown();
      createLockedDimensionsDropdownsAnync();
    }

    function createRowsDimensionDropdown() {
      rowsDimensionDropdown = new Swirrl.CubeDimensionDropdown(cubeGrid.getCubeDimensions(), 'rows-dimension-dropdown');
      $('#rows-dimension-container').append(rowsDimensionDropdown.jQueryElement);
      rowsDimensionDropdown.setValue(cubeGrid.getRowsDimension().uri);
      rowsDimensionDropdown.disable(); // create as disabled
      wireUpDimensionDropDownChanged(rowsDimensionDropdown);
    }

    function createColumnsDimensionDropdown() {
      columnsDimensionDropdown = new Swirrl.CubeDimensionDropdown(cubeGrid.getCubeDimensions(), 'columns-dimension-dropdown');
      $('#columns-dimension-container').append(columnsDimensionDropdown.jQueryElement);
      columnsDimensionDropdown.setValue(cubeGrid.getColumnsDimension().uri);
      columnsDimensionDropdown.disable(); // create as disabled
      wireUpDimensionDropDownChanged(columnsDimensionDropdown);
    }

    function createLockedDimensionsDropdownsAnync() {
      // make drop downs for the locked dimensions
      var lockedDimensionsSelector = containerSelector + " .locked-dimensions";
      var dimensionsReady = 0;

      var lockedDimObjects = cubeGrid.getLockedDimensionObjects();

      if (lockedDimObjects.length == 0) {
        // nothing to do.
        onReady.notify();
        if(!initialized) {onInitialized.notify();}
      } else {
        $(lockedDimensionsSelector).empty(); // clear out the div, ready for action.
      }


      $.each(lockedDimObjects, function(i, lockedDim) {

        var valuesReadyHandler = function (e, args) {
          // unsubscribe: we only want to do this setup once
          lockedDim.onValuesReady.unsubscribe(valuesReadyHandler);

          // 1. the label
          ////////////////////
          var field = $('<div class="field"></div>');
          $(lockedDimensionsSelector).append(field);

          // 1. the label for this dimension
          //////////////////
          var cubeDimLabel = new Swirrl.CubeDimensionLabel(cubeGrid.getCubeDimensions(), 'locked-dimension-label' + i.toString() + '-label');
          cubeDimLabel.setValue(lockedDim.uri);
          field.append(cubeDimLabel.jQueryElement);
          lockedDimensionLabelControls.push(cubeDimLabel);

          // 2. the values for this dimension
          ////////////////////
          var valuesDropdown = new Swirrl.CubeDimensionDropdown(args.values, 'locked-dimension-dropdown' + i.toString() + '-value');
          var valuesPicker = $('<div class="locked-dimension picker"></div>');
          valuesPicker.append(valuesDropdown.jQueryElement);
          field.append(valuesPicker);
          valuesDropdown.setValue(cubeGrid.getLockedDimensionValue(lockedDim.uri));
          valuesDropdown.disable(); // create as disbaled

          // add it to our collection
          lockedDimensionValuesDropdowns.push(valuesDropdown);

          // use the special locked dimension wirer-upper for the locked dims.
          wireUpLockedDimensionValuesChanged(valuesDropdown);

          dimensionsReady++;

          // Have we finished? we've got all of em.
          if (dimensionsReady == cubeGrid.getLockedDimensionObjects().length) {
            onReady.notify();
            if(!initialized) {onInitialized.notify();}
          }

        } // end handler func

        lockedDim.onValuesReady.subscribe(valuesReadyHandler);
        lockedDim.getValuesAsync();

      });
    }

    function disable() {
      $.each(getAllDropdowns(), function(i, dd) {
        dd.disable();
      });
    }

    function enable() {
      $.each(getAllDropdowns(), function(i, dd) {
        dd.enable();
      });
    }

    function getRowsDimension() {
      var rowsDimensionUri = rowsDimensionDropdown.getValue();
      return findCubeDimensionWithUri(rowsDimensionUri);
    }

    function getColumnsDimension() {
      var columnsDimensionUri = columnsDimensionDropdown.getValue();
      return findCubeDimensionWithUri(columnsDimensionUri);
    }

    function getLockedDimensionUris() {
      return $.map(lockedDimensionLabelControls, function(labControl, i) {
        return labControl.getValue();
      });
    }

    function getLockedDimensionValues() {
      return $.map( lockedDimensionValuesDropdowns, function(dd, i) {
        return dd.getValue();
      });
    }

    function getLockedDimensionValueLabels() {
      return $.map( lockedDimensionValuesDropdowns, function(dd, i) {
        return dd.getLabel();
      });
    }

    function checkDimensions() {

      if (!cubeGrid.getCubeDimensions()) {
        alert("You can't initialise the cube dimension controls unless the cube's dimensions have been initialised");
        return false;
      }

      if (!cubeGrid.getRowsDimension) {
        alert("You can't initialise the cube dimension controls unless the cube's rowsDimensions has been set");
        return false;
      }

      if (!cubeGrid.getColumnsDimension) {
        alert("You can't initialise the cube dimension controls unless the cube's columnsDimensions has been set");
        return false;
      }

      if(!cubeGrid.checkLockedDimensions()) {
        alert('missing locked dimensions');
        return false;
      }

      return true;
    }

    function getAllDropdowns() {
      var dropdowns = [];
      if(rowsDimensionDropdown){ dropdowns = dropdowns.concat(rowsDimensionDropdown); }
      if(rowsDimensionDropdown){ dropdowns = dropdowns.concat(columnsDimensionDropdown); }
      dropdowns = dropdowns.concat(lockedDimensionValuesDropdowns);
      return dropdowns;
    }


    function findControlWithValue(value, excludeControlWithId) {

      var allDropDowns = getAllDropdowns();
      var allControls = allDropDowns.concat(lockedDimensionLabelControls);
      var theControl = null;

      $.each(allControls, function(i, con) {

        if(con.getValue() == value && con.elementId != excludeControlWithId) {
          theControl = con;
          return false;
        }
      });
      return theControl;
    }

    function findUnusedDimensionUri() {
      var allDimensionControls = getAllDropdowns();
      var allDimensions = cubeGrid.getCubeDimensions();

      var allDimensionUris = $.map(allDimensions, function(dim, i) {
        return dim.uri;
      });

      var usedDimensionUris = [];
      var unusedDimension = null;

      $.each(getAllDropdowns(), function(i, dd) {
        usedDimensionUris.push(dd.getValue());
      });

      $.each(lockedDimensionLabelControls, function(i, labCon) {
        usedDimensionUris.push(labCon.getValue());
      });

      $.grep(allDimensionUris, function(el) {
        if (jQuery.inArray(el, usedDimensionUris) == -1) unusedDimension = el;
      });

      // there should be at most one unused dimension
      return unusedDimension;
    }

    function findCubeDimensionWithUri(uri) {
      var dim = null;

      $.each( cubeGrid.getCubeDimensions(), function (i, cubeDim) {
        if(uri == cubeDim.uri) {
          dim = cubeDim;
          return false;
        }
      });

      return dim;
    }

    function wireUpDimensionDropDownChanged(dropdown) {

      $(dropdown.jQueryElement).change(function(e) {

        onBusy.notify();

        var newValue = $(this).val(); // what's the new value of this dropdown?
        var prevControl = findControlWithValue(newValue, $(this).attr('id')); // now find where the new value was used (excluding this control)
        var unusedDimensionUri = findUnusedDimensionUri(); // what dimension uri is now unused?

        // Update the other controls accordingly...

        if(prevControl) {
          var previouslyLocked = ($.inArray( prevControl.getValue(), getLockedDimensionUris()) >= 0);

          // was it previously used as a locked dim?
          if (previouslyLocked) {
            prevControl.setValue(unusedDimensionUri);
            updateLockedDimensionValuesDropDown(prevControl); // this will raise notify when it's ready
          } else {
            prevControl.setValue(unusedDimensionUri);
            onReady.notify();
          }
        }

      });
    }


    function updateLockedDimensionValuesDropDown(labelControl) {

      // find the associated values drop down
      var valuesDropdownJQ = labelControl.jQueryElement;
      var valuesDropdownId = valuesDropdownJQ.closest('div.field').find('select').attr('id');

      valuesDropDownControl = null;
      $.each( lockedDimensionValuesDropdowns, function(i, valuedd) {
        if (valuedd.elementId == valuesDropdownId) {
          valuesDropDownControl = valuedd;
        }
      });

      var lockedDimensionUri = labelControl.getValue(); // the new value.

      // find the dimension object with the uri
      var lockedDimension = findCubeDimensionWithUri(lockedDimensionUri);

      var onValuesReadyHandler = function (e, args) {
        valuesDropDownControl.populateOptions(args.values);
        onReady.notify();
        lockedDimension.onValuesReady.unsubscribe(onValuesReadyHandler); // only respond once.
      }

      // update the options when the values arrive.
      lockedDimension.onValuesReady.subscribe(onValuesReadyHandler);
      lockedDimension.getValuesAsync();

    }


    function wireUpLockedDimensionValuesChanged(valuesDropdown) {
      $(valuesDropdown.jQueryElement).change(function(e) {
        onBusy.notify();
        onReady.notify();
      });
    }

  return {

      // methods
      "init": init // perform initialization
    , "getRowsDimension": getRowsDimension // returns a cube dimension object
    , "getColumnsDimension": getColumnsDimension // returns a cube dimension object
    , "getLockedDimensionUris": getLockedDimensionUris
    , "getLockedDimensionValues": getLockedDimensionValues
    , "getLockedDimensionValueLabels": getLockedDimensionValueLabels
    , "enable": enable
    , "disable": disable

      // events
    , "onBusy": onBusy
    , "onReady": onReady // contains the new values.
    , "onInitialized": onInitialized
    };
  }


  $.extend(true, window, { Swirrl: { CubeDimensionsControls: CubeDimensionsControls }});
})(jQuery);