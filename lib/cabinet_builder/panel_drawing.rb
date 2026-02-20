module CabinetBuilder
  module CabinetPanelDrawing
    private

    def draw_panel(panel_klass:, points:, thickness:, extrusion:, entities: @cabinet_entities)
      create_panel(
        panel_klass: panel_klass,
        points: points,
        thickness: thickness,
        extrusion: extrusion,
        entities: entities
      )
    end

    def draw_named_panel(name:, points:, thickness:, extrusion:, entities: @cabinet_entities)
      create_panel(
        panel_klass: Panel,
        points: points,
        thickness: thickness,
        extrusion: extrusion,
        name: name,
        entities: entities
      )
    end

    def create_panel(panel_klass:, points:, thickness:, extrusion:, name: nil, entities: @cabinet_entities)
      panel = panel_klass.new(
        entities: entities,
        material: @material_color,
        thickness: thickness,
        name: name
      )

      assign_panel_tag(panel.group, name)
      panel.create_face(points)
      panel.pushpull(extrusion)
      panel.group
    end

    def assign_panel_tag(panel_group, panel_name)
      return unless panel_group

      panel_group.layer = panel_tag_for(panel_name)
    end

    def panel_tag_for(panel_name)
      normalized_name = panel_name.to_s.downcase
      suffix = normalized_name.include?('front') ? 'front' : 'korpus'
      tag_name = "#{@nazwa_szafki}_#{suffix}"
      @model.layers[tag_name] || @model.layers.add(tag_name)
    end
  end
end
