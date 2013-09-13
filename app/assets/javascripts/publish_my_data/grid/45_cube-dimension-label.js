(function ($) {

  // posisble values needs to be an array of objects which respond to uri and label.
  function CubeDimensionLabel(possibleValues, elementId) {

    // private vars
    ///////////////
    var jQueryElement = null
      ,  uri = null
      ;

    init();

    function init() {
      // create the element
      jQueryElement = $("<label></label>");
      jQueryElement.attr('id', elementId);
    }

    function setValue(value) {

      uri = value;

      var label = null;
      $.each(possibleValues, function(i, pv) {
        if (pv.uri == uri) {
          label = (pv.label || pv.uri);
          return false;
        }
      });

      jQueryElement.text(label);
    }

    function getValue() {
      return uri;
    }

    function getSelectedLabel() {
      return jQueryElement.text();
    }

    // public api.
    //////////////////
    return {
      // properties
      "elementId": elementId
    , "jQueryElement": jQueryElement

      // methods
    , "setValue": setValue
    , "getValue": getValue
    , "getLabel": getSelectedLabel
    }
  }
  // Swirrl.DimensionLabel
  $.extend(true, window, { Swirrl: { CubeDimensionLabel: CubeDimensionLabel }});
})(jQuery);