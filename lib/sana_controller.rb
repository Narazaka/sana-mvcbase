# Sana Controller
class SanaController
  # constructor
  # @param [SanaRouter::Events] events events
  # @param [Symbol] event_id event id
  # @param [OpenStruct] request request
  # @param [Hash<Symbol, Integer>] mapping request argument mappings
  def initialize(events, event_id, request, mapping = {})
    @events = events
    @event_id = event_id
    @request = request
    @mapping = mapping
  end

  # events
  # @return [SanaRouter::Events]
  attr_reader :events
  # event id
  # @return [Symbol]
  attr_reader :event_id
  # request
  # @return [OpenStruct]
  attr_reader :request

  # named access to request headers
  # @return [SanaController::Params] params
  def params
    @params ||= Params.new(request, @mapping)
  end

  # exec action and get response
  # @return [String, Openstruct] response
  def action
    @return_value = public_send(@event_id)
    if @response
      @response
    else
      render
    end
  end

  private

  # render result
  # @param args various result options
  # @return [String, Openstruct] response
  def render(*args)
    @response = render_response(*args)
  end

  # make result by given options
  # @param args various result options
  # @return [String, Openstruct] response
  # @note this method should be overridden for convenient view rendering
  # @example override
  #   class HogeViewController < SanaController
  #     def render_response(value = nil)
  #       # @return_value is event method's return value
  #       eval (value || @return_value)
  #     end
  #   end
  def render_response(*args)
    args[0] || @return_value
  end

  # named access to request headers
  class Params
    # constructor
    # @param [OpenStruct] request request
    # @param [Hash<Symbol, Integer>] mapping request argument mappings
    # @example mapping
    #   params = SanaController::Params.new(request, {shell_name: 0, halted: 6, halted_ghost_name: 7}) # mapping for Reference0, 6 and 7
    def initialize(request, mapping = {})
      @request = request
      @mapping = mapping
    end

    # named access to the header
    # @example named access
    #   params.shell_name == params.Reference0
    # @param [Symbol] method param name
    # @return [String] header value
    def method_missing(method)
      @request[method] || @request["Reference#{@mapping[method]}".to_sym]
    end
  end
end

# Sana Controller (any event accepted)
class SanaAnyEventController < SanaController
  # SHIORI request()
  # @param [Symbol] method method name = event id
  def method_missing(method)
    render
  end
end
