# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "docker"
require "extras/all"
require "erb/context"
require "forwardable/extended"
require "simple/ansi"
require "pathutil"
require "set"

# ----------------------------------------------------------------------------

Excon.defaults[ :read_timeout] = 1440
Excon.defaults[:write_timeout] = 1440

# ----------------------------------------------------------------------------

module Docker
  module Template
    module_function

    # ------------------------------------------------------------------------

    def project?
      dir = root.join("docker")
      any = Builder.all.dup.keep_if(&:projects_allowed?)
      any = any.map(&:files).reduce(&:|).any? { |file| root.join(file).file? }
      return true if any && root.join(Metadata.opts_file(:force => \
        :project)).file?
    end

    # ------------------------------------------------------------------------

    def root
      @root ||= begin
        Pathutil.new(Dir.pwd)
      end
    end

    # ------------------------------------------------------------------------

    def gem_root
      @gem_root ||= begin
        Pathutil.new("../../").expand_path(
          __dir__
        )
      end
    end

    # ------------------------------------------------------------------------

    def template_root
      @template_root ||= begin
        gem_root.join("templates")
      end
    end

    # ------------------------------------------------------------------------
    # Pull a `template` from the `template_root` to parse it's data.
    # TODO: Rename this to get_template!
    # ------------------------------------------------------------------------

    def get(name, data = {})
      data = ERB::Context.new(data)
      template = template_root.join("#{name}.erb").read unless name.is_a?(Pathutil)
      template = name.read if name.is_a?(Pathutil)
      template = ERB.new(template)

      return template.result(
        data._binding
      )
    end

    # ------------------------------------------------------------------------

    def _require(what)
      require what
      if block_given?
        yield
      end

    rescue LoadError
      $stderr.puts "The gem '#{what}' wasn't found."
      $stderr.puts "You can install it with `gem install #{what}'"
      abort "Hope you install it so you can report back."
    end
  end
end

# ----------------------------------------------------------------------------
# Trick extras into merging array's into array's for us so users can inherit.
# ----------------------------------------------------------------------------

class Array
  def deep_merge(new_)
    self | new_
  end
end

# ----------------------------------------------------------------------------

require "docker/template/error"
require "docker/template/cache"
require "docker/template/notify"
require "docker/template/builder"
require "docker/template/logger"
require "docker/template/repo"
require "docker/template/metadata"
require "docker/template/auth"
