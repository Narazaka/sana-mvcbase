require 'sana'
# Sana Router
class SanaRouter
  # constructor
  # @param [SanaController] default_controller default scope controller
  def initialize(default_controller = nil)
    @default_controller = default_controller
    @controller = @default_controller
    @route = {}
    @mapping = {}
  end

  # register event route to controller
  # @param [Symbol, Array<Symbol>] events event names
  # @param [Hash<Symbol, Integer>] mapping request argument mappings
  # @example register to various controllers
  #   router.draw do
  #     # register to specific controller
  #     controller BootController do
  #       route [:OnBoot, :OnFirstBoot]
  #     end
  #     controller CloseController do
  #       route [:OnClose, :OnCloseAll]
  #     end
  #     # register to default controller
  #     route :OnSecondChange
  #   end
  # @example mapping usage
  #   route :OnBoot, {shell_name: 0, halted: 6, halted_ghost_name: 7} # mapping for Reference0, 6 and 7
  def route(events, mapping = {})
    Array(events).each do |method|
      @route[method.to_sym] = @controller
      @mapping[method.to_sym] = mapping
    end
    return
  end

  alias_method :r, :route

  # register SHIORI load() route to controller
  # @example register to specific controller
  #   router.draw do
  #     controller DLController do
  #       load
  #     end
  #   end
  def load
    @load_controller = @controller
  end

  # register SHIORI unload() route to controller
  # @example register to specific controller
  #   router.draw do
  #     controller DLController do
  #       unload
  #     end
  #   end
  def unload
    @unload_controller = @controller
  end

  # execute register methods in instance context
  # @yield instance_exec context
  def draw(&block)
    instance_exec &block
  end

  # set controller context
  # @param [SanaController] controller target controller
  # @yield controller context block
  def controller(controller)
    @controller = controller
    yield if block_given?
    @controller = @default_controller
  end

  # router events
  # @example with Sana
  #   sana = Sana.new(router.events)
  # @return [SanaRouter::Events] events
  def events
    @events ||= Events.new(@route, @mapping, @load_controller, @unload_controller, @default_controller)
  end

  # router events
  class Events
    # constructor
    # @param [Hash<Symbol, SanaController>] route route hash
    # @param [Hash<Symbol, Hash<Symbol, Integer>>] mapping mapping hash
    # @param [SanaController] load_controller load controller
    # @param [SanaController] unload_controller unload controller
    # @param [SanaController] default_controller default controller
    def initialize(route, mapping, load_controller, unload_controller, default_controller = nil)
      @route = route
      @mapping = mapping
      @load_controller = load_controller
      @unload_controller = unload_controller
      @default_controller = default_controller
    end

    # SHIORI request()
    # @param [Symbol] method method name = event id
    # @param [OpenStruct] request request
    # @return [String, Openstruct] response
    # @example request()
    #   events.OnBoot(request)
    def method_missing(method, request)
      if controller = @route[method] || @default_controller
        controller.new(self, method, request, @mapping[method]).action
      else
        super
      end
    end

    # SHIORI load()
    # @param [String] dirpath "ghost/master" path
    def _load(dirpath)
      @load_controller.new(self, __method__, nil, nil)._load(dirpath)
    end

    # SHIORI unload()
    def _unload
      @load_controller.new(self, __method__, nil, nil)._unload
    end
  end
end
