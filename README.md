# [Sana MVC Base](https://github.com/Narazaka/sana-mvcbase)

[![Gem](https://img.shields.io/gem/v/sana-mvcbase.svg)](https://rubygems.org/gems/sana-mvcbase)
[![Gem](https://img.shields.io/gem/dtv/sana-mvcbase.svg)](https://rubygems.org/gems/sana-mvcbase)
[![Gemnasium](https://gemnasium.com/Narazaka/sana-mvcbase.svg)](https://gemnasium.com/Narazaka/sana-mvcbase)
[![Inch CI](http://inch-ci.org/github/Narazaka/sana-mvcbase.svg)](http://inch-ci.org/github/Narazaka/sana-mvcbase)
[![Travis Build Status](https://travis-ci.org/Narazaka/sana-mvcbase.svg)](https://travis-ci.org/Narazaka/sana-mvcbase)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/Narazaka/sana-mvcbase?svg=true)](https://ci.appveyor.com/project/Narazaka/sana-mvcbase)
[![codecov.io](https://codecov.io/github/Narazaka/sana-mvcbase/coverage.svg?branch=master)](https://codecov.io/github/Narazaka/sana-mvcbase?branch=master)
[![Code Climate](https://codeclimate.com/github/Narazaka/sana-mvcbase/badges/gpa.svg)](https://codeclimate.com/github/Narazaka/sana-mvcbase)

Ukagaka SHIORI subsystem 'Sana' MVC Helper

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sana-mvcbase'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sana-mvcbase

## Usage

```ruby
require 'sana-mvcbase'
require 'shiolink'

# define controllers

# for load(), unload()
class DLController < SanaController
  def _load(dirpath)
    MySave.load
    p dirpath
  end

  def _unload
    p :unload
  end
end

# view rendering module
module MyViewModule
  def render_response(name)
    MyView.talk(name || event_id)
  end
end

# view rendering base controller
class MyWithViewController < SanaAnyEventController
  include MyViewModule
end

# normal talk controller
class TalkEventsController < MyWithViewController
  def OnBoot
    @foo = MySave.foo_flag
    @bar = MyModel.bar(params.shell_name)
  end

  def OnFirstBoot
    @foo = MySave.foo_flag
    render :OnBoot
  end
end

# resource controller
class ResourcesController < SanaController
  def homeurl
    "http://www.example.com/foo/"
  end
end

# register routing

router = SanaRouter.new(TalkEventsController)
router.draw do
  controller DLController do
    load
    unload
  end

  controller ResourcesController do
    route :homeurl
  end

  route :OnBoot, {shell_name: 0, halted: 6, halted_ghost_name: 7}

  # OnFirstBoot is not registered but will called with default controller (= TalkEventsController)
end

# app start

sana = Sana.new(router.events)
shiolink = Shiolink.new(sana.method(:load), sana.method(:unload), sana.method(:request))
shiolink.start
```

## API

[API Document](http://www.rubydoc.info/github/Narazaka/sana-mvcbase)

## License

This is released under [MIT License](http://narazaka.net/license/MIT?2016).
