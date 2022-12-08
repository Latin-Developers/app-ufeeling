# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/rg'

require_relative '../../require_app'
require_app

AUTHOR_ID = 'UCc96wBaIMkjH2JedZ5LIO4g'
VIDEO_ID = 'VBsB3FgqEx4'
VIDEO_IDS = %w[VBsB3FgqEx4 9reTrHdL7rQ].freeze
VIDEO_TITLE = "Marvel's Midnight Suns Developer Livestream | Rise Up With The Midnight Suns"
