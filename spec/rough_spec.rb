require 'sana-mvcbase'
require 'ostruct'

describe SanaRouter do
  module RendererModule
    def render_response(text = nil)
      text || "[empty]"
    end
  end

  class BaseController < SanaController
    include RendererModule
  end

  class DefaultController < BaseController
    def OnClose
      render "close"
    end

    def OnSecondChange
    end
  end

  class AController < BaseController
    def OnBoot
      render "boot"
    end
  end

  class BController < BaseController
    def OnFirstBoot
      render "first boot"
    end

    def OnBoot
      render "boot2 #{params.shell_name} #{params.halted} #{params.ng} #{params.halted_ghost_name}"
    end
  end

  class DLController < SanaController
    def _load(dirpath)
      :load
    end

    def _unload
      :unload
    end
  end

  class AnyController < SanaAnyEventController
    include RendererModule
  end

  let(:router) do
    router = SanaRouter.new(DefaultController)
    router.draw &draw
    router
  end
  let(:request) { OpenStruct.new({Reference0: 'master', Reference6: 'halt', Reference7: 'sana'}) }
  let(:events) { router.events }
  subject { events.public_send(event_id, request) }

  context "with Controllers" do
    let(:draw) do
      Proc.new do
        controller AController do
          route :OnBoot
        end
        controller BController do
          route :OnFirstBoot
        end
        route :OnSecondChange
      end
    end

    context :OnBoot do
      let(:event_id) { "OnBoot" }
      it { is_expected.to be == "boot" }
    end

    context :OnFirstBoot do
      let(:event_id) { "OnFirstBoot" }
      it { is_expected.to be == "first boot" }
    end

    context :OnClose do
      let(:event_id) { "OnClose" }
      it { is_expected.to be == "close" }
    end

    context :OnSecondChange do
      let(:event_id) { "OnSecondChange" }
      it { is_expected.to be == "[empty]" }
    end
  end

  context "with duplication" do
    let(:draw) do
      Proc.new do
        controller BController do
          route :OnBoot
        end
        controller AController do
          route :OnBoot
        end
      end
    end

    context :OnBoot do
      let(:event_id) { "OnBoot" }
      it { is_expected.to be == "boot" }
    end
  end

  context "with mapping" do
    let(:draw) do
      Proc.new do
        controller BController do
          r :OnBoot, {shell_name: 0, halted: 6, halted_ghost_name: 7}
        end
      end
    end

    context :OnBoot do
      let(:event_id) { "OnBoot" }
      it { is_expected.to be == "boot2 master halt  sana" }
    end
  end

  context "with multi routes" do
    let(:draw) do
      Proc.new do
        controller BController do
          route [:OnBoot, :OnFirstBoot], {shell_name: 0, halted: 6, halted_ghost_name: 7}
        end
      end
    end

    context :OnFirstBoot do
      let(:event_id) { "OnFirstBoot" }
      it { is_expected.to be == "first boot" }
    end

    context :OnBoot do
      let(:event_id) { "OnBoot" }
      it { is_expected.to be == "boot2 master halt  sana" }
    end
  end

  context "load, unload" do
    let(:draw) do
      Proc.new do
        controller DLController do
          load
          unload
        end
      end
    end

    context :load do
      subject { events.public_send("_load", "dir") }
      it { is_expected.to be == :load }
    end

    context :unload do
      subject { events.public_send("_unload") }
      it { is_expected.to be == :unload }
    end
  end

  context SanaAnyEventController do
    let(:draw) do
      Proc.new do
        controller AnyController do
          route :OnBoot
        end
      end
    end

    context :OnBoot do
      let(:event_id) { "OnBoot" }
      it { is_expected.to be == "[empty]" }
    end
  end
end
