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
        if truthy?(params['split_enabled'])
          params['split_left'] = normalize_split_side_config(
            side_name: "#{index + 1} lewa",
            section_height: section_height,
            raw_config: params['split_left'],
            fallback_filling: filling,
            fallback_params: params
          )
          params['split_right'] = normalize_split_side_config(
            side_name: "#{index + 1} prawa",
            section_height: section_height,
            raw_config: params['split_right'],
            fallback_filling: filling,
            fallback_params: params
          )
        end

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

      split_enabled = truthy?(params['split_enabled'])
      split_first_width = params['split_first_width']
      split_first_width = nil if split_first_width.nil? || split_first_width.to_s.strip.empty?
      split_first_width = to_length(split_first_width) unless split_first_width.nil?

      split_left_width = params['split_left_width']
      split_left_width = nil if split_left_width.nil? || split_left_width.to_s.strip.empty?
      split_left_width = to_length(split_left_width) unless split_left_width.nil?

      split_right_width = params['split_right_width']
      split_right_width = nil if split_right_width.nil? || split_right_width.to_s.strip.empty?
      split_right_width = to_length(split_right_width) unless split_right_width.nil?

      common_params = {
        'top_panel' => top_panel,
        'split_enabled' => split_enabled,
        'split_first_width' => split_first_width,
        'split_left_width' => split_left_width,
        'split_right_width' => split_right_width
      }

      merged_params = case filling
                      when 'drawers'
                        drawer_count = params.fetch('drawer_count', 0).to_i
                        raise ArgumentError, 'Sekcja typu szuflady wymaga liczby szuflad >= 1.' if drawer_count < 1

                        drawer_front_reduction = to_length(params.fetch('drawer_front_reduction', params.fetch('drawer_front_height', 0)))
                        raise ArgumentError, 'Pomniejszenie frontu musi być >= 0.' if drawer_front_reduction.negative?

                        drawer_width_reduction = to_length(params.fetch('drawer_width_reduction', 40))
                        raise ArgumentError, 'Zwężenie szuflady musi być >= 0.' if drawer_width_reduction.negative?

                        drawer_box_height_offset = to_length(params.fetch('drawer_box_height_offset', 40))
                        raise ArgumentError, 'Obniżenie boków szuflady musi być >= 0.' if drawer_box_height_offset.negative?

                        common_params.merge(
                          'drawer_count' => drawer_count,
                          'drawer_front_reduction' => drawer_front_reduction,
                          'drawer_width_reduction' => drawer_width_reduction,
                          'drawer_box_height_offset' => drawer_box_height_offset
                        )
                      when 'shelves'
                        shelf_count = params.fetch('shelf_count', 0).to_i
                        raise ArgumentError, 'Sekcja typu półki wymaga liczby półek >= 1.' if shelf_count < 1

                        common_params.merge('shelf_count' => shelf_count)
                      when 'rod'
                        rod_offset = to_length(params.fetch('rod_offset', 0))
                        raise ArgumentError, 'Sekcja typu drążek wymaga offsetu >= 0.' if rod_offset.negative?

                        common_params.merge('rod_offset' => rod_offset)
                      else
                        common_params
                      end

      return merged_params unless split_enabled

      merged_params.merge(
        'split_left' => normalize_split_side_config(
          side_name: 'lewa',
          section_height: nil,
          raw_config: params['split_left'],
          fallback_filling: filling,
          fallback_params: merged_params
        ),
        'split_right' => normalize_split_side_config(
          side_name: 'prawa',
          section_height: nil,
          raw_config: params['split_right'],
          fallback_filling: filling,
          fallback_params: merged_params
        )
      )
    end

    def normalize_split_side_config(side_name:, section_height:, raw_config:, fallback_filling:, fallback_params:)
      config = raw_config.is_a?(Hash) ? raw_config.transform_keys(&:to_s) : {}
      filling = normalize_section_filling(config['filling'] || fallback_filling)
      param_value = config['param']

      case filling
      when 'drawers'
        drawer_count = param_value.nil? ? fallback_params.fetch('drawer_count', 3) : param_value.to_i
        raise ArgumentError, "Sekcja #{side_name}: liczba szuflad musi być >= 1." if drawer_count < 1

        drawer_front_reduction = to_length(config.fetch('drawer_front_reduction', config.fetch('drawer_front_height', fallback_params.fetch('drawer_front_reduction', fallback_params.fetch('drawer_front_height', 0.mm)))))
        raise ArgumentError, "Sekcja #{side_name}: pomniejszenie frontu musi być >= 0." if drawer_front_reduction.negative?

        drawer_width_reduction = to_length(config.fetch('drawer_width_reduction', fallback_params.fetch('drawer_width_reduction', 40.mm)))
        raise ArgumentError, "Sekcja #{side_name}: zwężenie szuflady musi być >= 0." if drawer_width_reduction.negative?

        drawer_box_height_offset = to_length(config.fetch('drawer_box_height_offset', fallback_params.fetch('drawer_box_height_offset', 40.mm)))
        raise ArgumentError, "Sekcja #{side_name}: obniżenie boków szuflady musi być >= 0." if drawer_box_height_offset.negative?

        {
          'filling' => 'drawers',
          'param' => drawer_count,
          'drawer_front_reduction' => drawer_front_reduction,
          'drawer_width_reduction' => drawer_width_reduction,
          'drawer_box_height_offset' => drawer_box_height_offset
        }
      when 'shelves'
        shelf_count = param_value.nil? ? fallback_params.fetch('shelf_count', 4) : param_value.to_i
        raise ArgumentError, "Sekcja #{side_name}: liczba półek musi być >= 1." if shelf_count < 1

        {
          'filling' => 'shelves',
          'param' => shelf_count
        }
      when 'rod'
        rod_offset = param_value.nil? ? fallback_params.fetch('rod_offset', 200.mm) : to_length(param_value)
        if section_height && rod_offset > section_height + SECTION_EPSILON
          raise ArgumentError, "Sekcja #{side_name}: drążek poza granicą sekcji."
        end
        raise ArgumentError, "Sekcja #{side_name}: offset drążka musi być >= 0." if rod_offset.negative?

        {
          'filling' => 'rod',
          'param' => rod_offset
        }
      else
        {
          'filling' => 'none',
          'param' => 0
        }
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

      sub_sections = section_width_ranges(section)
      if sub_sections.length == 2
        draw_section_divider(section_entities, section, section_bottom, section_top, sub_sections.first[:x_max])
      end

      split_configs = section_split_configs(section)

      sub_sections.each_with_index do |sub_section, sub_index|
        sub_name = sub_section[:label]
        sub_config = split_configs[sub_index] || { 'filling' => section.filling, 'param' => nil }

        case sub_config['filling']
        when 'drawers'
          draw_section_drawers(section_entities, section, section_bottom, sub_section[:x_min], sub_section[:x_max], sub_name, sub_config)
        when 'shelves'
          draw_section_shelves(section_entities, section, section_bottom, section_top, sub_section[:x_min], sub_section[:x_max], sub_name, sub_config['param'])
        when 'rod'
          draw_section_rod(section_entities, section, section_bottom, section_top, sub_section[:x_min], sub_section[:x_max], sub_name, sub_config['param'])
        end
      end

      draw_section_top_panel(section_entities, section, section_top) if truthy?(section.params['top_panel'])
    end

    def section_split_configs(section)
      return [{ 'filling' => section.filling, 'param' => nil }] unless truthy?(section.params['split_enabled'])

      left = section.params['split_left']
      right = section.params['split_right']
      return [{ 'filling' => section.filling, 'param' => nil }, { 'filling' => section.filling, 'param' => nil }] if left.nil? || right.nil?

      [left, right]
    end

    def section_width_ranges(section)
      x_min = @panel_thickness
      x_max = @width - @panel_thickness
      return [] if x_max <= x_min

      split_enabled = truthy?(section.params['split_enabled'])
      return [{ label: nil, x_min: x_min, x_max: x_max }] unless split_enabled

      clear_width = x_max - x_min
      inner_available = clear_width - @panel_thickness
      raise ArgumentError, "Sekcja #{section.id}: za mało miejsca na podział sekcji." if inner_available <= 0

      left_width_external = section.params['split_left_width']
      right_width_external = section.params['split_right_width']
      first_width_external = section.params['split_first_width']

      left_ratio = if !left_width_external.nil?
                     raise ArgumentError, "Sekcja #{section.id}: szerokość lewej sekcji musi być > 0." if left_width_external <= 0
                     raise ArgumentError, "Sekcja #{section.id}: szerokość lewej sekcji musi być < szerokości szafy." if left_width_external >= @width
                     left_width_external / @width.to_f
                   elsif !right_width_external.nil?
                     raise ArgumentError, "Sekcja #{section.id}: szerokość prawej sekcji musi być > 0." if right_width_external <= 0
                     raise ArgumentError, "Sekcja #{section.id}: szerokość prawej sekcji musi być < szerokości szafy." if right_width_external >= @width
                     (@width - right_width_external) / @width.to_f
                   elsif !first_width_external.nil?
                     raise ArgumentError, "Sekcja #{section.id}: szerokość pierwszej sekcji musi być > 0." if first_width_external <= 0
                     raise ArgumentError, "Sekcja #{section.id}: szerokość pierwszej sekcji musi być < szerokości szafy." if first_width_external >= @width
                     first_width_external / @width.to_f
                   else
                     0.5
                   end

      left_clear_width = inner_available * left_ratio
      right_clear_width = inner_available - left_clear_width
      raise ArgumentError, "Sekcja #{section.id}: podział sekcji daje niedodatnią szerokość." if left_clear_width <= SECTION_EPSILON || right_clear_width <= SECTION_EPSILON

      divider_center_x = x_min + left_clear_width
      [
        { label: 'L', x_min: x_min, x_max: divider_center_x },
        { label: 'P', x_min: divider_center_x + @panel_thickness, x_max: x_max }
      ]
    end

    def draw_section_divider(section_entities, section, section_bottom, section_top, divider_x)
      divider_top = truthy?(section.params['top_panel']) ? section_top - @panel_thickness : section_top
      return if divider_top <= section_bottom + SECTION_EPSILON

      points = [
        [divider_x, 0, section_bottom],
        [divider_x, @internal_depth, section_bottom],
        [divider_x, @internal_depth, divider_top],
        [divider_x, 0, divider_top]
      ]

      draw_named_panel(
        name: "Section #{section.id} Divider",
        points: points,
        thickness: @panel_thickness,
        extrusion: @panel_thickness,
        entities: section_entities
      )
    end

    def draw_section_top_panel(section_entities, section, section_top)
      x_min = @panel_thickness
      x_max = @width - @panel_thickness
      return if x_max <= x_min

      panel_z = section_top
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

    def draw_section_drawers(section_entities, section, section_bottom, x_min, x_max, sub_name = nil, side_config = nil)
      drawer_count = (side_config && side_config['param']) ? side_config['param'].to_i : section.params.fetch('drawer_count', 0).to_i
      return if drawer_count < 1
      has_top_panel = truthy?(section.params['top_panel'])

      section_front_height = section.height
      puts section_front_height.to_i.to_mm
      compartment_height = section_front_height / drawer_count.to_f
      return if compartment_height <= 0

      drawer_front_reduction = side_config && (side_config['drawer_front_reduction'] || side_config['drawer_front_height']) ? (side_config['drawer_front_reduction'] || side_config['drawer_front_height']) : (section.params['drawer_front_reduction'] || section.params.fetch('drawer_front_height', 0))
      drawer_front_reduction = 0 if drawer_front_reduction.negative?

      drawer_width_reduction = side_config && side_config['drawer_width_reduction'] ? side_config['drawer_width_reduction'] : section.params.fetch('drawer_width_reduction', 40.mm)

      section_clear_width = x_max - x_min
      drawer_width = section_clear_width - drawer_width_reduction
      return if drawer_width <= 0

      drawer_x_min = x_min + ((section_clear_width - drawer_width) / 2.0)

      y = @panel_thickness
      front_height = [compartment_height - drawer_front_reduction, compartment_height].min
      return if front_height <= 0

      drawer_box_height_offset = side_config && side_config['drawer_box_height_offset'] ? side_config['drawer_box_height_offset'] : section.params.fetch('drawer_box_height_offset', 40.mm)
      drawer_box_height = [front_height - drawer_box_height_offset, 0].max

      drawer_box_front_y = y
      drawer_box_back_y = @internal_depth - @panel_thickness

      drawer_count.times do |index|
        z_bottom = section_bottom + (index * compartment_height)
        z_top = z_bottom + front_height

        points = [
          [drawer_x_min, y, z_bottom],
          [drawer_x_min + drawer_width, y, z_bottom],
          [drawer_x_min + drawer_width, y, z_top],
          [drawer_x_min, y, z_top]
        ]

        draw_front_leaf(
          name: "Section #{section.id} #{sub_section_name(sub_name)}Drawer #{index + 1}",
          points: points,
          entities: section_entities,
          extrusion: @front_thickness
        )

        draw_section_drawer_box(
          section_entities: section_entities,
          section_id: section.id,
          sub_name: sub_name,
          drawer_index: index,
          x_min: drawer_x_min,
          drawer_width: drawer_width,
          z_bottom: z_bottom,
          z_top: z_bottom + drawer_box_height,
          front_y: drawer_box_front_y,
          back_y: drawer_box_back_y
        )
      end
    end

    def draw_section_drawer_box(section_entities:, section_id:, sub_name:, drawer_index:, x_min:, drawer_width:, z_bottom:, z_top:, front_y:, back_y:)
      return if back_y <= front_y
      return if z_top <= z_bottom

      left_side_points = [
        [x_min, front_y, z_bottom],
        [x_min, back_y, z_bottom],
        [x_min, back_y, z_top],
        [x_min, front_y, z_top]
      ]

      draw_named_panel(
        name: "Section #{section_id} #{sub_section_name(sub_name)}Drawer #{drawer_index + 1} Side Left",
        points: left_side_points,
        thickness: @panel_thickness,
        extrusion: @panel_thickness,
        entities: section_entities
      )

      right_x = x_min + drawer_width
      right_side_points = [
        [right_x, front_y, z_bottom],
        [right_x, back_y, z_bottom],
        [right_x, back_y, z_top],
        [right_x, front_y, z_top]
      ]

      draw_named_panel(
        name: "Section #{section_id} #{sub_section_name(sub_name)}Drawer #{drawer_index + 1} Side Right",
        points: right_side_points,
        thickness: @panel_thickness,
        extrusion: @panel_thickness,
        entities: section_entities
      )

      back_x_min = x_min + @panel_thickness
      back_x_max = x_min + drawer_width - @panel_thickness
      return if back_x_max <= back_x_min

      back_points = [
        [back_x_min, back_y, z_bottom],
        [back_x_max, back_y, z_bottom],
        [back_x_max, back_y, z_top],
        [back_x_min, back_y, z_top]
      ]

      draw_named_panel(
        name: "Section #{section_id} #{sub_section_name(sub_name)}Drawer #{drawer_index + 1} Back",
        points: back_points,
        thickness: @panel_thickness,
        extrusion: @panel_thickness,
        entities: section_entities
      )

      bottom_x_min = x_min + @panel_thickness
      bottom_x_max = x_min + drawer_width - @panel_thickness
      return if bottom_x_max <= bottom_x_min

      bottom_points = horizontal_rectangle(
        x_min: bottom_x_min,
        x_max: bottom_x_max,
        y_min: front_y,
        y_max: back_y,
        z: z_bottom
      )

      draw_named_panel(
        name: "Section #{section_id} #{sub_section_name(sub_name)}Drawer #{drawer_index + 1} Bottom",
        points: bottom_points,
        thickness: @panel_thickness,
        extrusion: @panel_thickness,
        entities: section_entities
      )
    end

    def draw_section_shelves(section_entities, section, section_bottom, section_top, x_min, x_max, sub_name = nil, shelf_count_override = nil)
      shelf_count = (shelf_count_override || section.params.fetch('shelf_count', 0)).to_i
      return if shelf_count < 1

      return if x_max <= x_min

      top_panel_thickness = truthy?(section.params['top_panel']) ? @panel_thickness : 0
      clear_space = section.height - (shelf_count * @panel_thickness) - top_panel_thickness
      return if clear_space < 0

      niche_segment = clear_space / (shelf_count + 1).to_f

      shelf_count.times do |index|
        shelf_z = section_bottom + (niche_segment * (index + 1)) + (@panel_thickness * index)

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
          name: "Section #{section.id} #{sub_section_name(sub_name)}Shelf #{index + 1}",
          points: points,
          thickness: @panel_thickness,
          extrusion: @panel_thickness,
          entities: section_entities
        )
      end
    end

    def draw_section_rod(section_entities, section, section_bottom, section_top, x_min, x_max, sub_name = nil, rod_offset_override = nil)
      return if x_max <= x_min

      y_center = @internal_depth / 2.0
      rod_radius = ROD_DIAMETER / 2.0
      rod_y_min = [y_center - rod_radius, 0].max
      rod_y_max = [y_center + rod_radius, @internal_depth].min
      return if rod_y_max <= rod_y_min

      rod_offset = rod_offset_override.nil? ? section.params.fetch('rod_offset', section.height / 2.0) : to_length(rod_offset_override)
      raise ArgumentError, "Sekcja #{section.id}: drążek poza granicą sekcji." if rod_offset > section.height + SECTION_EPSILON

      rod_center_z = section_bottom + rod_offset
      rod_z_min = rod_center_z - rod_radius
      rod_z_max = rod_center_z + rod_radius

      if rod_z_min < section_bottom - SECTION_EPSILON || rod_z_max > section_top + SECTION_EPSILON
        raise ArgumentError, "Sekcja #{section.id}: drążek poza granicą sekcji."
      end

      rod_group = section_entities.add_group
      rod_group.name = "Section #{section.id} #{sub_section_name(sub_name)}Rod"
      assign_panel_tag(rod_group, 'Section Rod')

      rod_face = rod_group.entities.add_face(
        rod_group.entities.add_circle(
          [x_min, y_center, rod_center_z],
          [1, 0, 0],
          rod_radius,
          24
        )
      )
      return unless rod_face

      rod_face.material = @material_color
      rod_face.back_material = @material_color
      rod_face.pushpull(x_max - x_min)
    end

    def interior_niche_height
      [@height, 0].max
    end

    def interior_niche_bottom
      @panel_thickness
    end

    def to_length(raw_value)
      if defined?(Length) && raw_value.is_a?(Length)
        raw_value
      elsif raw_value.respond_to?(:to_l) && raw_value.class.to_s == 'Length'
        raw_value.to_l
      else
        raw_value.to_f.round.mm
      end
    end

    def truthy?(value)
      value == true || value.to_s == 'true'
    end

    def sub_section_name(name)
      name ? "#{name} " : ''
    end
  end
end
