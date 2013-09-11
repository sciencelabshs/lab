define(function() {

  var SelectBoxView = require('common/views/select-box-view'),
      NumericOutputView = require('common/views/numeric-output-view'),
      sensorDefinitions = require('sensor/applet/sensor-definitions');

  return function(model, modelUrl) {

    var sensorTypeView = new SelectBoxView({
      id: 'sensor-type-view',
      options: [{
        value: null,
        text: "Select type of sensor...",
        selected: model.properties.sensorType == null,
        disabled: true
      }].concat(Object.keys(sensorDefinitions).map(function(key) {
        return {
          value: key,
          text: sensorDefinitions[key].sensorName,
          selected: key === model.properties.sensorType,
          disabled: false
        };
      })),
      onChange: function(option) {
        model.properties.sensorType = option.value;
      }
    });

    // TODO use the formatter from the property description. Right now, it automatically adds
    // units to the returned string (which we don't want here).
    var format = d3.format('.2f');
    var sensorReadingView;
    var lastHeight = null;

    return  {
      $el: $("<div id='model-container' class='container' style='font-size: 0.7em'/>"),

      bindModel: function(newModel, newModelUrl) {
        modelUrl = newModelUrl || modelUrl;
        model = newModel || model;
      },

      getHeightForWidth: function(width, fontSizeChanged) {
        if (fontSizeChanged || lastHeight == null) {
          lastHeight = 2 * parseInt(this.$el.parent().css('font-size'), 10);
        }
        return lastHeight;
      },

      // called once we're in the DOM
      setup: function() {

        this.$el.empty();

        sensorReadingView = new NumericOutputView({
          id: 'sensor-value-view',
          label: "Reading: ",
          units: model.getPropertyDescription('sensorReading').getUnitAbbreviation()
        });

        var $selectBox = sensorTypeView.render(this.$el),
            $zeroButton = $("<div><button>Zero</button></div>"),
            $sensorReading = sensorReadingView.render();

        $selectBox.addClass('interactive-pulldown component component-spacing');
        $zeroButton.addClass('interactive-button component component-spacing');
        $sensorReading.addClass('numeric-output component horizontal component-spacing');

        this.$el.css('zIndex', 4);
        this.$el.append($selectBox);
        this.$el.append($sensorReading);
        this.$el.append($zeroButton);
      },

      showInitializationProgress: function() {
        var $progressbar;

        if (!this.$progressbarContainer) {
          $progressbar = $('<div/>')
            .attr('id', 'sensor-progressbar');

          this.$progressbarContainer = $('<div/>')
            .attr('id', 'sensor-progressbar-container')
            .css('bottom', $('body').height() / 2 + 75 + $('#responsive-content').offset().top)
            .append('<div class="label">Loading sensor...</div>')
            .append($progressbar)
            .appendTo('#responsive-content');

          $progressbar.progressbar({ value: false });
        }

        this.$progressbarContainer.show();
      },

      hideInitializationProgress: function() {
        this.$progressbarContainer.hide();
      },

      resize: function() {},

      repaint: function() {},

      updateUnits: function(units) {
        sensorReadingView.updateUnits(units);
      },

      update: function() {
        sensorReadingView.update(format(model.properties.sensorReading));
      }
    };
  };
});
