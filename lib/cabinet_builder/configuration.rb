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
      @depth = read_config_value(config: config, key: :depth, default: CabinetDimensions::CABINET_DEPTH).to_f
      @panel_thickness = read_config_value(config: config, key: :panel_thickness, default: CabinetDimensions::PANEL_THICKNESS).to_f
      @back_thickness = read_config_value(config: config, key: :back_thickness, default: CabinetDimensions::PANEL_THICKNESS_BACK).to_f
    end

def setup_appearance(config)
  @nazwa_szafki = read_config_value(config: config, key: :nazwa_szafki, default: 'szafka').to_s.strip
  @nazwa_szafki = 'szafka' if @nazwa_szafki.empty?
  @color = read_config_value(config: config, key: :color, default: CabinetDimensions::DEFAULT_COLOR)
  @material_color = Sketchup::Color.new(@color)
  @filling = read_config_value(config: config, key: :filling, default: 'none')
  @shelf_count = read_config_value(config: config, key: :shelf_count, default: 0).to_i
  @front_thickness = read_config_value(config: config, key: :front_thickness, default: CabinetDimensions::FRONT_THICKNESS).to_f
end

def setup_front(config)
  front_enabled_value = read_config_value(config: config, key: :front_enabled, default: false)
  @front_enabled = front_enabled_value == true || front_enabled_value.to_s == 'true'
  @front_technological_gap = [read_config_value(config: config, key: :front_technological_gap, default: 0).to_f, 0].max
  @front_quantity = read_config_value(config: config, key: :front_quantity, default: 1).to_i
  @front_opening_direction = read_config_value(config: config, key: :front_opening_direction, default: 'prawo').to_s.downcase
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
