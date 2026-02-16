module CabinetBuilder
  module CabinetGeometry
    private

    def horizontal_rectangle(x_min:, x_max:, y_min:, y_max:, z:)
      [
        [x_min, y_min, z],
        [x_max, y_min, z],
        [x_max, y_max, z],
        [x_min, y_max, z]
      ]
    end

    def vertical_side_rectangle(x:)
      [
        [x, 0, @panel_thickness],
        [x, 0, @height],
        [x, @internal_depth, @height],
        [x, @internal_depth, @panel_thickness]
      ]
    end
  end
end
