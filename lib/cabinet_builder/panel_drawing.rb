module CabinetBuilder
  module CabinetPanelDrawing
    private

    def draw_panel(panel_klass:, points:, thickness:, extrusion:)
      create_panel(
        panel_klass: panel_klass,
        points: points,
        thickness: thickness,
        extrusion: extrusion
      )
    end

    def draw_named_panel(name:, points:, thickness:, extrusion:)
      create_panel(
        panel_klass: Panel,
        points: points,
        thickness: thickness,
        extrusion: extrusion,
        name: name
      )
    end

    def create_panel(panel_klass:, points:, thickness:, extrusion:, name: nil)
      panel = panel_klass.new(
        entities: @cabinet_entities,
        material: @material_color,
        thickness: thickness,
        name: name
      )

      panel.create_face(points)
      panel.pushpull(extrusion)
    end
  end
end
