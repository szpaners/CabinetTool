require 'json'

# Dialog do konfiguracji szafki z zakładkami
module CabinetDialog
  class CabinetPropertiesDialog
    def initialize(edit_target: nil, initial_params: nil)
      @edit_target = edit_target
      @initial_params = initial_params

      @dialog = UI::HtmlDialog.new(
        preferences_key: 'cabinet-properties',
        width: 600,
        height: 400,
        left: 100,
        top: 100,
        resizable: true,
        title: 'Właściwości szafki'
      )

      @dialog.set_file(File.join(File.dirname(__FILE__), 'dialog.html'))
      @dialog.add_action_callback('saveCabinet') { |_, params| save_cabinet(params) }
      @dialog.add_action_callback('closeDialog') { |_, _| @dialog.close }
      @dialog.add_action_callback('dialogReady') { |_, _| prefill_form }
    end

    def show
      @dialog.show
      @dialog.bring_to_front
    end

    private

    def prefill_form
      return unless @initial_params

      @dialog.execute_script("setFormData(#{JSON.generate(@initial_params)})")
    end

    def save_cabinet(raw_params)
      params = JSON.parse(raw_params)

      model = Sketchup.active_model
      model.start_operation('Create / Update Cabinet', true)

      new_group = nil
      begin
        if @edit_target&.valid?
          transformation = @edit_target.transformation
          @edit_target.erase!
          new_group = CabinetBuilder::Cabinet.new(cabinet_params(params)).draw_cabinet
          new_group.transformation = transformation if new_group
        else
          new_group = CabinetBuilder::Cabinet.new(cabinet_params(params)).draw_cabinet
        end

        model.commit_operation
      rescue StandardError => e
        model.abort_operation
        UI.messagebox("Błąd podczas zapisu szafki: #{e.message}")
      end

      @dialog.close
    end

def cabinet_params(params)
  {
    width: params['width'].to_f.round.mm,
    height: params['height'].to_f.round.mm,
    depth: params['depth'].to_f.round.mm,
    cabinet_type: params['cabinet_type'],
    kitchen_base_enabled: params['kitchen_base_enabled'],
    connector_width: params['connector_width'].to_f.round.mm,
    panel_thickness: params['panel_thickness'].to_f.round.mm,
    front_thickness: params['front_thickness'].to_f.round.mm,
    back_thickness: params['back_thickness'].to_f.round.mm,
    nazwa_szafki: params['nazwa_szafki'],
    color: params['color'],
    filling: params['filling'],
    shelf_count: params['shelf_count'].to_i,
    drawer_count: params['drawer_count'].to_i,
    drawers_asymmetric: params['drawers_asymmetric'],
    first_drawer_height: params['first_drawer_height'].to_f.mm,
    front_enabled: params['front_enabled'],
    front_technological_gap: params['front_technological_gap'].to_f.mm,
    front_quantity: params['front_quantity'].to_i,
    front_type: params['front_type'],
    frame_width: params['frame_width'].to_f.mm,
    frame_inner_thickness: params['frame_inner_thickness'].to_f.mm,
    groove_width: params['groove_width'].to_f.mm,
    groove_spacing: params['groove_spacing'].to_f.mm,
    groove_depth: params['groove_depth'].to_f.mm,
    front_opening_direction: params['front_opening_direction'],
    blend_left_value: params['blend_left_value'].to_f.round.mm,
    blend_right_value: params['blend_right_value'].to_f.round.mm,
    blend_left_depth_value: params['blend_left_depth_value'].to_f.round.mm,
    blend_right_depth_value: params['blend_right_depth_value'].to_f.round.mm,
    cokol_dolny_value: params['cokol_dolny_value'].to_f.round.mm,
    cokol_gorny_value: params['cokol_gorny_value'].to_f.round.mm,
    cokol_dolny_offset_value: params['cokol_dolny_offset_value'].to_f.round.mm,
    cokol_gorny_offset_value: params['cokol_gorny_offset_value'].to_f.round.mm,
    interior_sections_fill_remaining: params['interior_sections_fill_remaining'],
    interior_sections: parse_interior_sections(params['interior_sections']),
  }
    end


    def parse_interior_sections(raw_sections)
      return [] unless raw_sections.is_a?(Array)

      raw_sections.each_with_object([]) do |section, result|
        next unless section.is_a?(Hash)

        params = section['params'].is_a?(Hash) ? section['params'] : {}

        result << {
          id: section['id'].to_i,
          height: section['height'].to_f.round.mm,
          filling: section['filling'].to_s,
          params: {
            drawer_count: params['drawer_count'].to_i,
            shelf_count: params['shelf_count'].to_i,
            rod_offset: params['rod_offset'].to_f.round.mm
          }
        }
      end
    end
  end
end
