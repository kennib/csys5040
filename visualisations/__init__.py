from mesa.visualization.ModularVisualization import VisualizationElement


class CustomNetworkModule(VisualizationElement):
    local_includes = ["visualisations/CustomNetworkModule_d3.js"]
    package_includes = ["d3.min.js"]

    def __init__(self, portrayal_method, canvas_height=500, canvas_width=500, library='sigma'):
        library_types = ['sigma', 'd3']
        if library not in library_types:
            raise ValueError("Invalid javascript library type. Expected one of: %s" % library_types)

        self.portrayal_method = portrayal_method
        self.canvas_height = canvas_height
        self.canvas_width = canvas_width
        new_element = f'new CustomNetworkModule({self.canvas_width}, {self.canvas_height})'
        self.js_code = "elements.push(" + new_element + ");"

    def render(self, model):
        return self.portrayal_method(model.G)
