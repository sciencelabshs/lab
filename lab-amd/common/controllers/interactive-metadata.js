/*global define: false */

define(function() {

  return {
    /**
      Interactive top-level properties:
    */
    interactive: {
      title: {
        required: true
      },

      publicationStatus: {
        defaultValue: "public"
      },

      subtitle: {
        defaultValue: ""
      },

      about: {
        defaultValue: ""
      },

      fontScale: {
        defaultValue: 1
      },

      models: {
        // List of model definitions. Its definition is below ('model').
        required: true
      },

      parameters: {
        // List of custom parameters.
        defaultValue: []
      },

      outputs: {
        // List of outputs.
        defaultValue: []
      },

      filteredOutputs: {
        // List of filtered outputs.
        defaultValue: []
      },

      exports: {
        required: false
      },

      components: {
        // List of the interactive components. Their definitions are below ('button', 'checkbox' etc.).
        defaultValue: []
      },

      layout: {
        // Layout definition.
        defaultValue: {}
      },

      template: {
        // Layout template definition.
        defaultValue: "simple"
      }
    },

    model: {
      // Definition of a model.
      // Can include either a URL to model definition or model options hash..
      id: {
        required: true
      },
      url: {
        conflictsWith: ["model"]
      },
      model: {
        conflictsWith: ["url"]
      },
      // Optional "onLoad" script.
      onLoad: {},
      // Optional hash of options overwriting model options.
      viewOptions: {},
      modelOptions: {},
      // Parameters, outputs and filtered outputs can be also specified per model.
      parameters: {},
      outputs: {},
      filteredOutputs: {}
    },

    parameter: {
      name: {
        required: true
      },
      initialValue: {
        required: true
      },
      // Optional "onChange" script.
      onChange: {},
      // Optional description.
      label: {},
      unitType: {},
      unitName: {},
      unitPluralName: {},
      unitAbbreviation: {}
    },

    output: {
      name: {
        required: true
      },
      value: {
        required: true
      },
      // Optional description.
      label: {},
      unitType: {},
      unitName: {},
      unitPluralName: {},
      unitAbbreviation: {}
    },

    filteredOutput: {
      name: {
        required: true
      },
      property: {
        required: true
      },
      type: {
        // For now, only "RunningAverage" is supported.
        required: true
      },
      period: {
        // Smoothing time period in ps.
        // e.g. 2500
        required: true
      },
      // Optional description.
      label: {},
      unitType: {},
      unitName: {},
      unitPluralName: {},
      unitAbbreviation: {}
    },

    exports: {
      perRun: {
        required: false,
        defaultValue: []
      },
      perTick: {
        required: true
      }
    },

    /**
      Interactive components:
    */
    text: {
      id: {
        required: true
      },
      type: {
        required: true
      },
      onClick: {
        // Script executed on user click, optional.
      },
      text: {
        // Text content.
        defaultValue: ""
      },
      width: {
        defaultValue: "auto"
      },
      height: {
        defaultValue: "auto"
      }
    },

    image: {
      id: {
        required: true
      },
      type: {
        required: true
      },
      src: {
        // Absolute path should start with http(s)://
        // Relative path is relative to model URL.
        defaultValue: ""
      },
      width: {
        defaultValue: "auto"
      },
      height: {
        defaultValue: "auto"
      },
      onClick: {
        // Script executed on user click, optional.
      },
    },

    div: {
      id: {
        required: true
      },
      type: {
        required: true
      },
      width: {
        defaultValue: "auto"
      },
      height: {
        defaultValue: "auto"
      },
      onClick: {
        // Script executed on user click, optional.
      },
      classes: {
        defaultValue: []
      },
      tooltip: {
        // Optional tooltip text
      }
    },

    button: {
      id: {
        required: true
      },
      type: {
        required: true
      },
      action: {
        required: true
      },
      text: {
        defaultValue: ""
      },
      width: {
        defaultValue: ""
      },
      height: {
        defaultValue: ""
      }
    },

    checkbox: {
      id: {
        required: true
      },
      type: {
        required: true
      },
      text: {
        defaultValue: ""
      },
      textOn: {
        defaultValue: "right"
      },
      width: {
        defaultValue: "auto"
      },
      height: {
        defaultValue: "auto"
      },
      property: {
        conflictsWith: ["initialValue"]
      },
      onClick: {
        // Script executed on user click, optional.
      },
      initialValue: {
        // Note that 'initialValue' makes sense only for checkboxes without property binding.
        // Do not use checkbox as setter.
        conflictsWith: ["property"]
      }
    },

    slider: {
      id: {
        required: true
      },
      type: {
        required: true
      },
      min: {
        required: true
      },
      max: {
        required: true
      },
      steps: {
        required: true
      },
      title: {
        defaultValue: ""
      },
      labels: {
        // Label is specified by the following object:
        // {
        //   "value": [value, e.g. 100],
        //   "label": [label, e.g. "High"]
        // }
        defaultValue: []
      },
      width: {
        defaultValue: "auto"
      },
      height: {
        defaultValue: "auto"
      },
      displayValue: {},
      // Use "property" OR "action" + "initialValue".
      property: {
        // If you use property binding, do not mix it with action scripts and initial values.
        conflictsWith: ["initialValue", "action"]
      },
      action: {
        conflictsWith: ["property"]
      },
      initialValue: {
        // Do not use slider as a property setter.
        // There are better ways to do it, e.g.:
        // "onLoad" scripts (and set({ }) call inside), "modelOptions", etc.
        conflictsWith: ["property"]
      }
    },

    pulldown: {
      id: {
        required: true
      },
      type: {
        required: true
      },
      label: {
        defaultValue: ""
      },
      labelOn: {
        // Other option is "left".
        defaultValue: "top"
      },
      options: {
        defaultValue: []
      },
      property: {
        // Pulldown can be also connected to a model property.
        // In such case, options should define "value", not "action".
      }
    },

    pulldownOption: {
      text: {
        defaultValue: ""
      },
      action: {
        // Use it when pulldown is not bound to any model property.
        conflictsWith: ["value"]
      },
      value: {
        // Use it when pulldown is bound to some model property.
        conflictsWith: ["action"]
      },
      selected: {
        // Use it when pulldown is not bound to any model property.
        // When "property" is used for pulldown, it will determine
        // selection.
        conflictsWith: ["value"]
      },
      disabled: {},
      loadModel: {}
    },

    radio: {
      id: {
        required: true
      },
      type: {
        required: true
      },
      orientation: {
        defaultValue: "vertical"
      },
      label: {
        defaultValue: ""
      },
      labelOn: {
        // Other option is "left".
        defaultValue: "top"
      },
      options: {
        defaultValue: []
      },
      property: {
        // Radio can be also connected to a model property.
        // In such case, options should define "value", not "action".
      }
    },

    radioOption: {
      text: {
        defaultValue: ""
      },
      action: {
        // Use it when radio is not bound to any model property.
        conflictsWith: ["value"]
      },
      value: {
        // Use it when radio is bound to some model property.
        conflictsWith: ["action"]
      },
      selected: {
        // Use it when radio is not bound to any model property.
        // When "property" is used for radio, it will determine
        // selection.
        conflictsWith: ["value"]
      },
      disabled: {},
      loadModel: {}
    },

    numericOutput: {
      id: {
        required: true
      },
      type: {
        required: true
      },
      label: {
        defaultValue: ""
      },
      units: {
        defaultValue: ""
      },
      orientation: {
        defaultValue: "horizontal"
      },
      width: {
        defaultValue: "auto"
      },
      height: {
        defaultValue: "auto"
      },
      property: {},
      displayValue: {}
    },

    thermometer: {
      id: {
        required: true
      },
      type: {
        required: true
      },
      min: {
        required: true
      },
      max: {
        required: true
      },
      width: {
        // It controls width of the thermometer graphics!
        // It won't affect label, e.g. making it truncated
        // as width is only "2.5em".
        defaultValue: "2.5em"
      },
      height: {
        // Height of the whole thermometer with reading.
        defaultValue: "100%"
      },
      labelIsReading: {
        defaultValue: false
      },
      reading: {
        defaultValue: {
          units: "K",
          offset: 0,
          scale: 1,
          digits: 0
        }
      },
      labels: {
        // Label is specified by the following object:
        // {
        //   "value": [value, e.g. 100],
        //   "label": [label, e.g. "High"]
        // }
        defaultValue: []
      }
    },

    graph: {
      id: {
        required: true
      },
      type: {
        required: true
      },
      realTime: {
        defaultValue: true
      },
      fontScaleRelativeToParent: {
        defaultValue: true
      },
      properties: {
        defaultValue: []
      },
      title: {
        defaultValue: "Graph"
      },
      width: {
        defaultValue: "100%"
      },
      height: {
        defaultValue: "100%"
      },
      xlabel: {
        defaultValue: "Model Time (ps)"
      },
      xmin: {
        defaultValue: 0
      },
      xmax: {
        defaultValue: 20
      },
      ylabel: {
        defaultValue: ""
      },
      ymin: {
        defaultValue: 0
      },
      ymax: {
        defaultValue: 10
      },
      xTickCount: {
        defaultValue: 10
      },
      yTickCount: {
        defaultValue: 10
      },
      xscaleExponent: {
        defaultValue: 0.5
      },
      yscaleExponent: {
        defaultValue: 0.5
      },
      xFormatter: {
        defaultValue: "3.2r"
      },
      yFormatter: {
        defaultValue: "3.2r"
      },
      lines: {
        defaultValue: true
      },
      bars: {
        defaultValue: false
      }
    },

    barGraph: {
      id: {
        required: true
      },
      type: {
        required: true
      },
      property: {
        required: true
      },
      width: {
        defaultValue: "100%"
      },
      height: {
        defaultValue: "100%"
      },
      options: {
        defaultValue: {
          // Min value displayed.
          minValue:  0,
          // Max value displayed.
          maxValue:  10,
          // Graph title.
          title:     "",
          // Color of the main bar.
          barColor:  "green",
          // Color of the area behind the bar.
          fillColor: "white",
          // Color of axis, labels, title.
          textColor: "#555",
          // Number of ticks displayed on the axis.
          // This value is *only* a suggestion. The most clean
          // and human-readable values are used.
          ticks:          10,
          // Number of subdivisions between major ticks.
          tickSubdivide: 1,
          // Enables or disables displaying of numerical labels.
          displayLabels: true,
          // Format of labels.
          // See the specification of this format:
          // https://github.com/mbostock/d3/wiki/Formatting#wiki-d3_format
          // or:
          // http://docs.python.org/release/3.1.3/library/string.html#formatspec
          labelFormat: "0.1f"
        }
      }
    }
  };
});