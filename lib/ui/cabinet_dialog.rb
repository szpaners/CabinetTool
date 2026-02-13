# Dialog do konfiguracji szafki z zakładkami
module CabinetDialog
  class CabinetPropertiesDialog
def initialize
      @dialog = UI::HtmlDialog.new(
        preferences_key: "cabinet-properties",
        width: 600,
        height: 400,
        left: 100,
        top: 100,
        resizable: true,
        title: "Właściwości szafki"
      )
      @dialog.set_file(File.join(File.dirname(__FILE__), "dialog.html"))
      @dialog.add_action_callback("saveCabinet") do |_, params|
        save_cabinet(params)
      end
      @dialog.add_action_callback("closeDialog") do |_, _|
        @dialog.close
      end
    end

def show
      @dialog.show
      @dialog.bring_to_front
    end

    private

def save_cabinet(params)
      params = JSON.parse(params)
      width = params["width"].to_f.mm
      height = params["height"].to_f.mm
      depth = params["depth"].to_f.mm
      panel_thickness = params["panel_thickness"].to_f.mm
      back_thickness = params["back_thickness"].to_f.mm

      puts params
      puts width
      puts height
      puts depth
      puts panel_thickness
      puts back_thickness

      cabinet = CabinetBuilder::Cabinet.new(width, height, depth, panel_thickness, back_thickness)
      cabinet.draw_cabinet

      @dialog.close
    end
  end
end