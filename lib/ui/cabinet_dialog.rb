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
    panel_thickness: params['panel_thickness'].to_f.round.mm,
    front_thickness: params['front_thickness'].to_f.round.mm,
    back_thickness: params['back_thickness'].to_f.round.mm,
    nazwa_szafki: params['nazwa_szafki'],
    color: params['color'],
    filling: params['filling'],
    shelf_count: params['shelf_count'].to_i,
    front_enabled: params['front_enabled'],
    front_technological_gap: params['front_technological_gap'].to_f.mm,
    front_quantity: params['front_quantity'].to_i,
    blend_left_value: params['blend_left_value'].to_f.round.mm,
    blend_right_value: params['blend_right_value'].to_f.round.mm,
    blend_left_depth_value: params['blend_left_depth_value'].to_f.round.mm,
    blend_right_depth_value: params['blend_right_depth_value'].to_f.round.mm,
    cokol_dolny_value: params['cokol_dolny_value'].to_f.round.mm,
    cokol_gorny_value: params['cokol_gorny_value'].to_f.round.mm
  }
    end
  end
end
