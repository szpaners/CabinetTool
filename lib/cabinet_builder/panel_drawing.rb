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

      assign_panel_tag(panel.group, name)
      panel.create_face(points)
      panel.pushpull(extrusion)
    end

    def assign_panel_tag(panel_group, panel_name)
      return unless panel_group

      panel_group.layer = panel_tag_for(panel_name)
    end

    def panel_tag_for(panel_name)
      suffix = panel_name.to_s.downcase.start_with?('front') ? 'front' : 'korpus'
      tag_name = "#{@nazwa_szafki}_#{suffix}"
      @model.layers[tag_name] || @model.layers.add(tag_name)
    end
  end
end
