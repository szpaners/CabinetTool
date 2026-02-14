module CabinetBuilder
  class BackPanel < BasePanel
    def initialize(config)
      super(config.merge(name: 'Back Panel'))
      @thickness = config[:thickness]
    end
  end
end
