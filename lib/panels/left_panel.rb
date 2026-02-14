module CabinetBuilder
  class LeftPanel < BasePanel
    def initialize(config)
      super(config.merge(name: 'Left Panel'))
      @thickness = config[:thickness]
    end
  end
end
