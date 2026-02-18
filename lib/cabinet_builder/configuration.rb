module CabinetBuilder
  module CabinetConfiguration
    private

    def setup_context
      @model = Sketchup.active_model
      @entities = @model.active_entities
      @group = @entities.add_group
      @cabinet_entities = @group.entities
    end

    def setup_dimensions(config)
      @width = read_config_value(config: config, key: :width, default: CabinetDimensions::CABINET_WIDTH).to_f
      @height_total = read_config_value(config: config, key: :height, default: CabinetDimensions::CABINET_HEIGHT).to_f
      @height = @height_total
      @depth_total = read_config_value(config: config, key: :depth, default: CabinetDimensions::CABINET_DEPTH).to_f
      @depth = @depth_total
      @panel_thickness = read_config_value(config: config, key: :panel_thickness, default: CabinetDimensions::PANEL_THICKNESS).to_f
      @back_thickness = read_config_value(config: config, key: :back_thickness, default: CabinetDimensions::PANEL_THICKNESS_BACK).to_f
    end

def setup_appearance(config)
  @cabinet_type = read_config_value(config: config, key: :cabinet_type, default: 'kitchen').to_s.downcase
  @cabinet_type = 'kitchen' unless %w[kitchen wardrobe].include?(@cabinet_type)
  @nazwa_szafki = read_config_value(config: config, key: :nazwa_szafki, default: 'szafka').to_s.strip
  @nazwa_szafki = 'szafka' if @nazwa_szafki.empty?
  @color = read_config_value(config: config, key: :color, default: CabinetDimensions::DEFAULT_COLOR)
  @material_color = Sketchup::Color.new(@color)
  @filling = read_config_value(config: config, key: :filling, default: 'none')
  @shelf_count = read_config_value(config: config, key: :shelf_count, default: 0).to_i
  @drawer_count = read_config_value(config: config, key: :drawer_count, default: 0).to_i
  drawers_asymmetric_value = read_config_value(config: config, key: :drawers_asymmetric, default: false)
  @drawers_asymmetric = drawers_asymmetric_value == true || drawers_asymmetric_value.to_s == 'true'
  @first_drawer_height = read_config_value(config: config, key: :first_drawer_height, default: 0).to_f
  @front_thickness = read_config_value(config: config, key: :front_thickness, default: CabinetDimensions::FRONT_THICKNESS).to_f

  return unless @cabinet_type == 'wardrobe'

  @filling = 'none'
  @shelf_count = 0
  @drawer_count = 0
  @drawers_asymmetric = false
  @first_drawer_height = 0
end

def setup_front(config)
  front_enabled_value = read_config_value(config: config, key: :front_enabled, default: false)
  @front_enabled = front_enabled_value == true || front_enabled_value.to_s == 'true'
  @front_technological_gap = [read_config_value(config: config, key: :front_technological_gap, default: 0).to_f, 0].max
  @front_quantity = read_config_value(config: config, key: :front_quantity, default: 1).to_i
  @front_type = read_config_value(config: config, key: :front_type, default: 'flat').to_s.downcase
  @front_type = 'frame' if @front_type == 'rama'
  @front_type = 'lamella' if %w[ryflowany grooved lamelowany].include?(@front_type)
  @front_type = 'flat' unless %w[flat frame lamella].include?(@front_type)
  @frame_width = [read_config_value(config: config, key: :frame_width, default: 20).to_f, 0].max
  frame_inner_thickness = read_config_value(config: config, key: :frame_inner_thickness, default: nil)
  frame_inner_thickness = read_config_value(config: config, key: :frame_inner_depth, default: 2) if frame_inner_thickness.nil?
  @frame_inner_thickness = [frame_inner_thickness.to_f, 0].max
  @groove_width = [read_config_value(config: config, key: :groove_width, default: 12).to_f, 0].max
  @groove_spacing = [read_config_value(config: config, key: :groove_spacing, default: 8).to_f, 0].max
  @groove_depth = [read_config_value(config: config, key: :groove_depth, default: 3).to_f, 0].max
  @front_opening_direction = read_config_value(config: config, key: :front_opening_direction, default: 'prawo').to_s.downcase
  @front_handle = read_config_value(config: config, key: :front_handle, default: 'J').to_s

  kitchen_base_enabled = read_config_value(config: config, key: :kitchen_base_enabled, default: false)
  @kitchen_base_enabled = kitchen_base_enabled == true || kitchen_base_enabled.to_s == 'true'
  @connector_width = [read_config_value(config: config, key: :connector_width, default: 100).to_f, 0].max
  @kitchen_base_enabled = false if @cabinet_type == 'wardrobe'
end

    def setup_blends(config)
      @blend_left_value = read_config_value(config: config, key: :blend_left_value, default: 0).to_f
      @blend_right_value = read_config_value(config: config, key: :blend_right_value, default: 0).to_f
      @blend_left_depth_value = read_config_value(config: config, key: :blend_left_depth_value, default: 0).to_f
      @blend_right_depth_value = read_config_value(config: config, key: :blend_right_depth_value, default: 0).to_f
    end

    def setup_cokols(config)
      @cokol_dolny_value = read_config_value(config: config, key: :cokol_dolny_value, default: 0).to_f
      @cokol_gorny_value = read_config_value(config: config, key: :cokol_gorny_value, default: 0).to_f
      @cokol_dolny_offset_value = [read_config_value(config: config, key: :cokol_dolny_offset_value, default: 0).to_f, 0].max
      @cokol_gorny_offset_value = [read_config_value(config: config, key: :cokol_gorny_offset_value, default: 0).to_f, 0].max

      # Wysokość podawana przez użytkownika to wysokość całkowita szafki,
      # zawierająca oba cokoły. Pozostałe panele rysujemy dla wysokości korpusu.
      @height = [@height_total - @cokol_dolny_value - @cokol_gorny_value, 0].max
    end

    def read_config_value(config:, key:, default:)
      config.fetch(key.to_s, config.fetch(key, default))
    end
  end
end
