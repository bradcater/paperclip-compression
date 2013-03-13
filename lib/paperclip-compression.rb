require "paperclip"

module Paperclip
  # Compresses the JPEG and PNG files
  class Compression < Processor

    attr_accessor :format

    EXTRA_OPTIONS ||= {
      'image/jpeg' => nil,
      'image/png'  => nil
    }
    FORCE_FORMAT ||= nil
    def initialize(file, options = {}, attachment = nil)
      super
      @format         = options[:format]
      @current_format = File.extname(@file.path)
      @basename       = File.basename(@file.path, @current_format)
    end

    def make
      src = @file
      dst = Tempfile.new([@basename, @format ? ".#{@format}" : ''])
      dst.binmode

      src_path = File.expand_path(src.path)
      dst_path = File.expand_path(dst.path)

      begin
        if FORCE_FORMAT == 'image/jpeg' || (FORCE_FORMAT.nil? && @attachment.content_type.eql?("image/jpeg"))
          Paperclip.run("jpegtran", "-copy none -optimize -perfect #{EXTRA_OPTIONS['image/jpeg'] || ''} #{src_path} > #{dst_path}")
        elsif FORCE_FORMAT == 'image/png' || (FORCE_FORMAT.nil? && @attachment.content_type.eql?("image/png"))
          Paperclip.run("optipng", "-o 5 #{EXTRA_OPTIONS['image/png'] || ''} #{src_path}")
          return src
        else
          return src
        end
      rescue
        # TODO
      end
      dst
    end

  end

end
