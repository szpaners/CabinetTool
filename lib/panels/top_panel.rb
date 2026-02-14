module CabinetBuilder
  class TopPanel < BasePanel
    def initialize(config)
      super(config.merge(name: 'Top Panel'))
      @thickness = config[:thickness]
    end
  end
end
