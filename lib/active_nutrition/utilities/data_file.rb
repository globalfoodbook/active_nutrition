# encoding: UTF-8
require 'iconv'

module ActiveNutrition
  module Utilities
    class DataFile
      attr_reader :file, :handle

      FIELD_SEP = '^'
      FIELD_ENC = '~'
      NULL_FIELDS = ['^^', '~~', "\r\n", '']

      def initialize(file)
        @file = file
        @file_system_encoding = file_system_encoding(file)
        @handle = File.open(file, "r")
      end

      def each
        @handle.each do |line|
          yield self.convert_parse(line)
        end
        self.clean_up
      end

      protected

      def clean_up
        @handle.close
      end

      def convert_parse(line)
        parse(Iconv.conv("UTF-8//TRANSLIT//IGNORE", @file_system_encoding, line))
      end

      def parse(line)
        line.chomp!("\r\n")
        fields = line.split('^')
        p_fields = []

        fields.each do |field|
          # strip the '~' if present
          if field.index('"')
            field.gsub!(/[\"]/, "'")
          end

          if field.index(FIELD_ENC) && field.size > 2
            p_fields << field[1..-2]
          else
            # else if the field matches a null field
            if NULL_FIELDS.include?(field)
              p_fields << ''
            elsif field.include?('.')
              # else the field must be a number
              p_fields << field.to_f
            elsif field.include?('/')
              # check to see if its a date, add as a string for now
              p_fields << field
            else
              p_fields << field.to_i
            end
          end
        end
        p_fields
      rescue => e
        puts line
        puts e.message
        puts e.backtrace
      end

      def file_system_encoding(file)
        `file --brief --mime "#{file}" | cut -d '=' -f 2`.strip!
      end
    end
  end
end
