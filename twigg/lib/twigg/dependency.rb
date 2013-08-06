module Twigg
  module Dependency
  private

    def with_dependency(gem, &block)
      require gem
      yield
    rescue LoadError => e
      Console.die "#{e}: try `gem install #{gem}`"
    end
  end
end
