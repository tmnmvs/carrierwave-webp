# encoding: utf-8

require 'webp-ffi'

module CarrierWave
  module WebP
    module Converter
      def convert_to_webp(options = {})
        manipulate! do |img|
          img          = yield(img) if block_given?
          webp_path    = "#{path}.webp"
          old_filename = filename

          ::WebP.encode(path, webp_path, options)

          # XXX: Hacks ahead!
          # I can't find any other way to store an alomost exact copy
          # of file for any particular version
          instance_variable_set('@filename', "#{filename}.webp")

          storage.store! SanitizedFile.new({
            tempfile: webp_path, filename: webp_path,
            content_type: 'image/webp'
          })

          FileUtils.rm(webp_path) rescue nil

          instance_variable_set('@filename', old_filename)

          img
        end
      end
    end
  end
end
