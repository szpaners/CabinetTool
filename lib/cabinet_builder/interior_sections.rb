module CabinetBuilder
  module CabinetInteriorSections
    SECTION_FILL_TYPES = %w[none drawers shelves rod].freeze
    ROD_DIAMETER = 25.mm
    SECTION_EPSILON = 0.001.mm

    InteriorSection = Struct.new(:id, :height, :y_bottom, :filling, :params, keyword_init: true)

    private

    def setup_interior_sections(config)
      @interior_sections = []
      @interior_sections_fill_remaining = truthy?(read_config_value(config: config, key: :interior_sections_fill_remaining, default: true))
      return unless @cabinet_type == 'wardrobe'

      raw_sections = read_config_value(config: config, key: :interior_sections, default: [])
      @interior_sections = build_interior_sections(raw_sections)
    end

    def build_interior_sections(raw_sections)
      section_hashes = normalize_section_hashes(raw_sections)
      return [] if section_hashes.empty?

      available_height = interior_niche_height
      current_bottom = 0.mm
      sections = []

      section_hashes.each_with_index do |section_hash, index|
        section_height = to_length(section_hash['height'])
        raise ArgumentError, "Sekcja #{index + 1}: wysokość musi być > 0." if section_height <= 0

        if current_bottom + section_height > available_height + SECTION_EPSILON
          raise ArgumentError, "Sekcja #{index + 1}: suma wysokości sekcji przekracza wysokość wnęki."
        end

        section_id = normalized_section_id(section_hash['id'], index + 1)
        filling = normalize_section_filling(section_hash['filling'])
        params = normalize_section_params(filling: filling, raw_params: section_hash['params'] || {})

        sections << InteriorSection.new(
          id: section_id,
          height: section_height,
          y_bottom: current_bottom,
          filling: filling,
          params: params
        )

        current_bottom += section_height
      end

      remaining_height = available_height - current_bottom
      if @interior_sections_fill_remaining && remaining_height > SECTION_EPSILON
        sections << InteriorSection.new(
          id: sections.length + 1,
          height: remaining_height,
          y_bottom: current_bottom,
          filling: 'none',
          params: {}
        )
      elsif remaining_height < -SECTION_EPSILON
        raise ArgumentError, 'Suma sekcji przekracza wysokość wnęki.'
      end

      sections
    end

    def normalize_section_hashes(raw_sections)
      return [] unless raw_sections.respond_to?(:map)

      raw_sections.map do |section|
        next unless section.is_a?(Hash)

        section.transform_keys(&:to_s)
      end.compact
    end

    def normalize_section_filling(raw_filling)
      filling = raw_filling.to_s.downcase
      SECTION_FILL_TYPES.include?(filling) ? filling : 'none'
    end

    def normalize_section_params(filling:, raw_params:)
      params = raw_params.is_a?(Hash) ? raw_params.transform_keys(&:to_s) : {}
      top_panel = truthy?(params['top_panel'])

      case filling
      when 'drawers'
        drawer_count = params.fetch('drawer_count', 0).to_i
        raise ArgumentError, 'Sekcja typu szuflady wymaga liczby szuflad >= 1.' if drawer_count < 1

        { 'drawer_count' => drawer_count, 'top_panel' => top_panel }
      when 'shelves'
        shelf_count = params.fetch('shelf_count', 0).to_i
        raise ArgumentError, 'Sekcja typu półki wymaga liczby półek >= 1.' if shelf_count < 1

        { 'shelf_count' => shelf_count, 'top_panel' => top_panel }
      when 'rod'
        rod_offset = to_length(params.fetch('rod_offset', 0))
        raise ArgumentError, 'Sekcja typu drążek wymaga offsetu >= 0.' if rod_offset.negative?

        { 'rod_offset' => rod_offset, 'top_panel' => top_panel }
      else
        { 'top_panel' => top_panel }
      end
    end

    def normalized_section_id(raw_id, fallback_id)
      parsed_id = raw_id.to_i
      parsed_id.positive? ? parsed_id : fallback_id
    end

    def draw_interior_sections
      return if @interior_sections.empty?

      @interior_sections.each do |section|
        section_group = @cabinet_entities.add_group
        section_group.name = "Section #{section.id}"
        assign_panel_tag(section_group, 'Section')

        draw_section_content(section_group.entities, section)
      end
    end

    def draw_section_content(section_entities, section)
      section_bottom = interior_niche_bottom + section.y_bottom
      section_top = section_bottom + section.height

      case section.filling
      when 'drawers'
        draw_section_drawers(section_entities, section, section_bottom)
      when 'shelves'
        draw_section_shelves(section_entities, section, section_bottom, section_top)
      when 'rod'
        draw_section_rod(section_entities, section, section_bottom, section_top)
      end

      draw_section_top_panel(section_entities, section, section_top) if truthy?(section.params['top_panel'])
    end

    def draw_section_top_panel(section_entities, section, section_top)
      x_min = @panel_thickness
      x_max = @width - @panel_thickness
      return if x_max <= x_min

      panel_z = section_top - @panel_thickness
      return if panel_z < interior_niche_bottom - SECTION_EPSILON

      points = horizontal_rectangle(
        x_min: x_min,
        x_max: x_max,
        y_min: 0,
        y_max: @internal_depth,
        z: panel_z
      )

      draw_named_panel(
        name: "Section #{section.id} Top Panel",
        points: points,
        thickness: @panel_thickness,
        extrusion: @panel_thickness,
        entities: section_entities
      )
    end

    def draw_section_drawers(section_entities, section, section_bottom)
      drawer_count = section.params.fetch('drawer_count', 0)
      return if drawer_count < 1

      drawer_height = section.height / drawer_count.to_f
      return if drawer_height <= 0

      drawer_width = @width - (2 * @panel_thickness)
      return if drawer_width <= 0

      x_min = @panel_thickness
      y = -@front_thickness

      drawer_count.times do |index|
        z_bottom = section_bottom + (index * drawer_height)
        z_top = z_bottom + drawer_height

        points = [
          [x_min, y, z_bottom],
          [x_min + drawer_width, y, z_bottom],
          [x_min + drawer_width, y, z_top],
          [x_min, y, z_top]
        ]

        draw_named_panel(
          name: "Section #{section.id} Drawer #{index + 1}",
          points: points,
          thickness: @front_thickness,
          extrusion: -@front_thickness,
          entities: section_entities
        )
      end
    end

    def draw_section_shelves(section_entities, section, section_bottom, section_top)
      shelf_count = section.params.fetch('shelf_count', 0)
      return if shelf_count < 1

      x_min = @panel_thickness
      x_max = @width - @panel_thickness
      return if x_max <= x_min

      shelf_count.times do |index|
        shelf_mid = section_bottom + ((index + 1) * section.height / (shelf_count + 1).to_f)
        shelf_z = shelf_mid - (@panel_thickness / 2.0)
        shelf_z = [shelf_z, section_bottom].max
        shelf_z = [shelf_z, section_top - @panel_thickness].min

        next if shelf_z < section_bottom - SECTION_EPSILON
        next if shelf_z + @panel_thickness > section_top + SECTION_EPSILON

        points = horizontal_rectangle(
          x_min: x_min,
          x_max: x_max,
          y_min: 0,
          y_max: @internal_depth,
          z: shelf_z
        )

        draw_named_panel(
          name: "Section #{section.id} Shelf #{index + 1}",
          points: points,
          thickness: @panel_thickness,
          extrusion: @panel_thickness,
          entities: section_entities
        )
      end
    end

    def draw_section_rod(section_entities, section, section_bottom, section_top)
      x_min = @panel_thickness
      x_max = @width - @panel_thickness
      return if x_max <= x_min

      y_center = @internal_depth / 2.0
      rod_radius = ROD_DIAMETER / 2.0
      rod_y_min = [y_center - rod_radius, 0].max
      rod_y_max = [y_center + rod_radius, @internal_depth].min
      return if rod_y_max <= rod_y_min

      rod_offset = section.params.fetch('rod_offset', section.height / 2.0)
      raise ArgumentError, "Sekcja #{section.id}: drążek poza granicą sekcji." if rod_offset > section.height + SECTION_EPSILON

      rod_center_z = section_bottom + rod_offset
      rod_z_min = rod_center_z - rod_radius
      rod_z_max = rod_center_z + rod_radius

      if rod_z_min < section_bottom - SECTION_EPSILON || rod_z_max > section_top + SECTION_EPSILON
        raise ArgumentError, "Sekcja #{section.id}: drążek poza granicą sekcji."
      end

      rod_group = section_entities.add_group
      rod_group.name = "Section #{section.id} Rod"
      assign_panel_tag(rod_group, 'Section Rod')

      rod_face = rod_group.entities.add_face(
        [x_min, rod_y_min, rod_z_min],
        [x_min, rod_y_max, rod_z_min],
        [x_min, rod_y_max, rod_z_max],
        [x_min, rod_y_min, rod_z_max]
      )
      return unless rod_face

      rod_face.material = @material_color
      rod_face.back_material = @material_color
      rod_face.pushpull(x_max - x_min)
    end

    def interior_niche_height
      [@height - (2 * @panel_thickness), 0].max
    end

    def interior_niche_bottom
      @panel_thickness
    end

    def to_length(raw_value)
      raw_value.to_f.round.mm
    end

    def truthy?(value)
      value == true || value.to_s == 'true'
    end
  end
end
