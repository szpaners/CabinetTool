# Klasa do budowania szafki
module CabinetBuilder
  class Cabinet
    CABINET_DICT = 'cabinet_tool'.freeze

    attr_reader :group, :entities

    def initialize(config = {})
      @model = Sketchup.active_model
      @entities = @model.active_entities
      @group = @entities.add_group
      @cabinet_entities = @group.entities
      @width = read_config_value(config: config, key: :width, default: CabinetDimensions::CABINET_WIDTH).to_f
      @height = read_config_value(config: config, key: :height, default: CabinetDimensions::CABINET_HEIGHT).to_f
      @depth = read_config_value(config: config, key: :depth, default: CabinetDimensions::CABINET_DEPTH).to_f
      @panel_thickness = read_config_value(config: config, key: :panel_thickness, default: CabinetDimensions::PANEL_THICKNESS).to_f
      @back_thickness = read_config_value(config: config, key: :back_thickness, default: CabinetDimensions::PANEL_THICKNESS_BACK).to_f
      @color = read_config_value(config: config, key: :color, default: CabinetDimensions::DEFAULT_COLOR)
      @material_color = Sketchup::Color.new(@color)
      @filling = read_config_value(config: config, key: :filling, default: 'none')
      @shelf_count = read_config_value(config: config, key: :shelf_count, default: 0).to_i
      @blend_left_value = read_config_value(config: config, key: :blend_left_value, default: 0).to_f
      @blend_right_value = read_config_value(config: config, key: :blend_right_value, default: 0).to_f
      @blend_left_depth_value = read_config_value(config: config, key: :blend_left_depth_value, default: 0).to_f
      @blend_right_depth_value = read_config_value(config: config, key: :blend_right_depth_value, default: 0).to_f
    end

    def draw_bottom_panel
      points = horizontal_rectangle(x_min: 0, x_max: @width, y_min: 0, y_max: @depth - @back_thickness, z: 0)
      draw_panel(panel_klass: BottomPanel, points: points, thickness: @panel_thickness, extrusion: -@panel_thickness)
    end

    def draw_top_panel
      top_z = @height - @panel_thickness
      points = horizontal_rectangle(x_min: 0, x_max: @width, y_min: 0, y_max: @depth - @back_thickness, z: top_z)
      draw_panel(panel_klass: TopPanel, points: points, thickness: @panel_thickness, extrusion: @panel_thickness)
    end

    def draw_left_panel
      points = vertical_side_rectangle(x: @panel_thickness)
      draw_panel(panel_klass: LeftPanel, points: points, thickness: @panel_thickness, extrusion: @panel_thickness)
    end

    def draw_right_panel
      points = vertical_side_rectangle(x: @width)
      draw_panel(panel_klass: RightPanel, points: points, thickness: @panel_thickness, extrusion: @panel_thickness)
    end

    def draw_back_panel
      points = [
        [0, @depth, 0],
        [@width, @depth, 0],
        [@width, @depth, @height],
        [0, @depth, @height]
      ]
      draw_panel(panel_klass: BackPanel, points: points, thickness: @back_thickness, extrusion: @back_thickness)
    end

    def draw_shelves
      return if @shelf_count <= 0

      internal_height = @height - (2 * @panel_thickness)
      total_shelves_thickness = @shelf_count * @panel_thickness
      free_openings_height = internal_height - total_shelves_thickness
      opening_height = free_openings_height / (@shelf_count + 1)

      return if opening_height < 0

      @shelf_count.times do |i|
        shelf_z = @panel_thickness + ((i + 1) * opening_height) + (i * @panel_thickness)
        points = horizontal_rectangle(x_min: @panel_thickness, x_max: @width - @panel_thickness, y_min: 0, y_max: @depth - @back_thickness, z: shelf_z)

        draw_named_panel(name: "Shelf #{i + 1}", points: points, thickness: @panel_thickness, extrusion: @panel_thickness)
      end
    end

    def draw_blend_left
      return unless @blend_left_value > 0

      max_depth = @blend_left_depth_value > 0 ? @blend_left_depth_value : @depth - @back_thickness
      points = [
        [0, 0, 0],
        [0, 0, @height],
        [0, max_depth, @height],
        [0, max_depth, 0]
      ]

      draw_named_panel(name: 'Blend Left', points: points, thickness: @blend_left_value, extrusion: @blend_left_value)
    end

    def draw_blend_right
      return unless @blend_right_value > 0

      x = @width + @blend_right_value
      max_depth = @blend_right_depth_value > 0 ? @blend_right_depth_value : @depth - @back_thickness
      points = [
        [x, 0, 0],
        [x, 0, @height],
        [x, max_depth, @height],
        [x, max_depth, 0]
      ]

      draw_named_panel(name: 'Blend Right', points: points, thickness: @blend_right_value, extrusion: @blend_right_value)
    end

    def draw_cabinet
      draw_bottom_panel
      draw_top_panel
      draw_left_panel
      draw_right_panel
      draw_back_panel
      draw_shelves
      draw_blend_left
      draw_blend_right
      save_metadata

      @group
    end

    def self.draw_cabinet(params = {})
      Cabinet.new(params).draw_cabinet
    end

    def self.read_params_from_group(group)
      return nil unless group

      blend_left_value_mm = read_blend_value_mm(group, { mm: 'blend_left_value_mm', legacy: 'blend_left_value' })
      blend_right_value_mm = read_blend_value_mm(group, { mm: 'blend_right_value_mm', legacy: 'blend_right_value' })
      blend_left_depth_value_mm = read_blend_value_mm(group, { mm: 'blend_left_depth_value_mm', legacy: 'blend_left_depth_value' })
      blend_right_depth_value_mm = read_blend_value_mm(group, { mm: 'blend_right_depth_value_mm', legacy: 'blend_right_depth_value' })

      {
        'width' => group.get_attribute(CABINET_DICT, 'width_mm', CabinetDimensions::CABINET_WIDTH.to_mm),
        'height' => group.get_attribute(CABINET_DICT, 'height_mm', CabinetDimensions::CABINET_HEIGHT.to_mm),
        'depth' => group.get_attribute(CABINET_DICT, 'depth_mm', CabinetDimensions::CABINET_DEPTH.to_mm),
        'panel_thickness' => group.get_attribute(CABINET_DICT, 'panel_thickness_mm', CabinetDimensions::PANEL_THICKNESS.to_mm),
        'back_thickness' => group.get_attribute(CABINET_DICT, 'back_thickness_mm', CabinetDimensions::PANEL_THICKNESS_BACK.to_mm),
        'color' => group.get_attribute(CABINET_DICT, 'color', CabinetDimensions::DEFAULT_COLOR),
        'filling' => group.get_attribute(CABINET_DICT, 'filling', 'none'),
        'shelf_count' => group.get_attribute(CABINET_DICT, 'shelf_count', 0),
        'blend_left_value' => blend_left_value_mm,
        'blend_right_value' => blend_right_value_mm,
        'blend_left_depth_value' => blend_left_depth_value_mm,
        'blend_right_depth_value' => blend_right_depth_value_mm
      }
    end

    def self.find_selected_cabinet_group
      model = Sketchup.active_model
      return nil unless model

      model.selection.each do |entity|
        group = find_cabinet_group_for_entity(entity)
        return group if group
      end

      nil
    end

    def self.find_cabinet_group_for_entity(entity)
      current = entity
      until current.nil?
        if current.is_a?(Sketchup::Group) && current.get_attribute(CABINET_DICT, 'is_cabinet', false)
          return current
        end

        current = current.respond_to?(:parent) ? current.parent : nil
      end

      nil
    end

    private

    def read_config_value(config:, key:, default:)
      config.fetch(key.to_s, config.fetch(key, default))
    end

    def horizontal_rectangle(coords)
      [
        [coords[:x_min], coords[:y_min], coords[:z]],
        [coords[:x_max], coords[:y_min], coords[:z]],
        [coords[:x_max], coords[:y_max], coords[:z]],
        [coords[:x_min], coords[:y_max], coords[:z]]
      ]
    end

    def vertical_side_rectangle(coords)
      x = coords[:x]
      [
        [x, 0, @panel_thickness],
        [x, 0, @height - @panel_thickness],
        [x, @depth - @back_thickness, @height - @panel_thickness],
        [x, @depth - @back_thickness, @panel_thickness]
      ]
    end

    def draw_panel(config)
      panel = config[:panel_klass].new(
        entities: @cabinet_entities,
        material: @material_color,
        thickness: config[:thickness]
      )
      panel.create_face(config[:points])
      panel.pushpull(config[:extrusion])
    end

    def draw_named_panel(config)
      panel = Panel.new(
        entities: @cabinet_entities,
        name: config[:name],
        material: @material_color,
        thickness: config[:thickness]
      )
      panel.create_face(config[:points])
      panel.pushpull(config[:extrusion])
    end

    def self.read_blend_value_mm(group, keys)
      mm_value = group.get_attribute(CABINET_DICT, keys[:mm], nil)
      return mm_value if mm_value

      legacy_value = group.get_attribute(CABINET_DICT, keys[:legacy], 0)
      legacy_value.to_l.to_mm
    end

    def save_metadata
      @group.set_attribute(CABINET_DICT, 'is_cabinet', true)
      @group.set_attribute(CABINET_DICT, 'width_mm', @width.to_l.to_mm)
      @group.set_attribute(CABINET_DICT, 'height_mm', @height.to_l.to_mm)
      @group.set_attribute(CABINET_DICT, 'depth_mm', @depth.to_l.to_mm)
      @group.set_attribute(CABINET_DICT, 'panel_thickness_mm', @panel_thickness.to_l.to_mm)
      @group.set_attribute(CABINET_DICT, 'back_thickness_mm', @back_thickness.to_l.to_mm)
      @group.set_attribute(CABINET_DICT, 'color', @color)
      @group.set_attribute(CABINET_DICT, 'filling', @filling)
      @group.set_attribute(CABINET_DICT, 'shelf_count', @shelf_count)
      @group.set_attribute(CABINET_DICT, 'blend_left_value_mm', @blend_left_value.to_l.to_mm)
      @group.set_attribute(CABINET_DICT, 'blend_right_value_mm', @blend_right_value.to_l.to_mm)
      @group.set_attribute(CABINET_DICT, 'blend_left_depth_value_mm', @blend_left_depth_value.to_l.to_mm)
      @group.set_attribute(CABINET_DICT, 'blend_right_depth_value_mm', @blend_right_depth_value.to_l.to_mm)
    end
  end
end
