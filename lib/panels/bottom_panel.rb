module CabinetBuilder
  class BottomPanel < BasePanel
    def initialize(config)
      super(config.merge(name: 'Bottom Panel'))
      @thickness = config[:thickness]
    end
  end
end
