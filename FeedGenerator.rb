#!/bin/ruby
# frozen_string_literal: true

require 'date'
require 'yaml'

# TODO: add append mode that just puts at the end of the feed the episodes that have mp3 files in my computer
class FeedGenerator
  def initialize(site_config, data_directory)
    @config = parse_yaml site_config
    @data = parse_data data_directory
    @episode_list = []
  end

  def generate
    load_episode_list
    output_feed
  end

  private

  def parse_data(path)
    data = {}
    Dir.entries(path).each do |file|
      next if ['.', '..'].include? file

      data[file.split('.')[0]] = YAML.load_file "#{path}/#{file}"
    end
    data
  end

  def parse_yaml(file)
    YAML.load_file file
  end

  def output_feed
    build_date = DateTime.now.strftime(@config['podcast']['datetime_format_string'])
    base_url = @config['url']
    managing_editor = @config['podcast']['managing_editor']
    editor_email = @config['podcast']['editor_email']
    desc = @config['description']
    feed_file = @config['podcast']['feed_file']

    feed = XMLFeed::Feed.new
    channel = XMLFeed::XMLNode.new 'channel'
    atom_link = XMLFeed::XMLNode.new 'atom:link'
    atom_link.set_propperty 'href', "#{base_url}/#{feed_file}"
    atom_link.set_propperty 'rel', 'self'
    atom_link.set_propperty 'type', 'application/rss+xml'
    channel.add_child atom_link
    channel.add_child XMLFeed::XMLNode.new('title', content: @config['title'])
    channel.add_child XMLFeed::XMLNode.new('pubDate', content: @episode_list[0]['pub_date'])
    channel.add_child XMLFeed::XMLNode.new('lastBuildDate', content: build_date)
    channel.add_child XMLFeed::XMLNode.new('link', content: base_url)
    channel.add_child XMLFeed::XMLNode.new('language', content: 'pt')
    channel.add_child(
      XMLFeed::XMLNode.new(
        'copyright',
        cdata: true,
        content: "#{@config['title']} #{DateTime.now.year}, todos os direitos reservados."
      )
    )
    channel.add_child XMLFeed::XMLNode.new('docs', content: base_url)
    channel.add_child XMLFeed::XMLNode.new('managingEditor', content: "#{editor_email} (#{managing_editor})")
    channel.add_child XMLFeed::XMLNode.new('itunes:summary', cdata: true, content: desc)
    image = XMLFeed::XMLNode.new 'image'
    image.add_child XMLFeed::XMLNode.new('url', content: "#{base_url}#{@config['logo']}")
    image.add_child XMLFeed::XMLNode.new('title', content: @config['title'])
    image.add_child XMLFeed::XMLNode.new('link', cdata: true, content: base_url)
    channel.add_child image
    channel.add_child XMLFeed::XMLNode.new('itunes:author', content: @config['podcast']['author'])
    category = XMLFeed::XMLNode.new 'itunes:category'
    category.set_propperty 'text', 'Society &amp; Culture'
    channel.add_child category
    channel.add_child XMLFeed::XMLNode.new('itunes:keywords', content: @config['podcast']['keywords'])
    channel.add_child XMLFeed::XMLNode.new('itunes:image', propperties: { href: "#{base_url}#{@config['logo']}" })
    channel.add_child XMLFeed::XMLNode.new('itunes:explict', content: 'true')
    owner = XMLFeed::XMLNode.new 'itunes:owner'
    owner.add_child(XMLFeed::XMLNode.new('itunes:email', content: @config['email']))
    itunes_name = XMLFeed::XMLNode.new 'itunes:name'
    itunes_name.add_child XMLFeed::XMLNode.new('cdata', content: @config['title'])
    owner.add_child(itunes_name)
    channel.add_child owner
    description = XMLFeed::XMLNode.new 'description'
    description.add_child(XMLFeed::XMLNode.new('cdata', content: desc, cdata: true))
    channel.add_child description
    subtitle = XMLFeed::XMLNode.new 'itunes:subtitle'
    subtitle.add_child(
      XMLFeed::XMLNode.new(
        'cdata',
        content: @config['short_description'],
        cdata: true
      )
    )
    channel.add_child subtitle
    channel.add_child XMLFeed::XMLNode.new('itunes:type', content: 'episodic')
    channel.add_child XMLFeed::XMLNode.new('itunes:new-feed-url', content: "#{base_url}/#{feed_file}")
    channel.add_children generate_episode_items

    feed.nodes << channel
    File.open(feed_file, 'w') { |f| f.write(feed) }
    puts "#{feed_file} written!"
  end

  # TODO: add episode attribute names on config so they're dynamic
  def generate_episode_items
    episode_items = []
    @episode_list.each do |episode|
      next if episode['hide']

      description = format_description(episode['desc'], details: episode['detalhes'], indent_level: 3)
      subtitle = format_description(
        episode['desc'].length > 255 ? "#{episode['desc'].slice(0, 252)}..." : episode['desc']
      )
      current_item = XMLFeed::XMLNode.new 'item'
      current_item.add_child XMLFeed::XMLNode.new('guid', content: "#{@config['url']}#{episode['url']}")
      current_item.add_child XMLFeed::XMLNode.new('title', content: episode['nome'])
      current_item.add_child XMLFeed::XMLNode.new('pubDate', content: episode['pub_date'])
      link = XMLFeed::XMLNode.new 'link'
      link.add_child(XMLFeed::XMLNode.new('cdata', cdata: true, content: "#{@config['url']}#{episode['url']}"))
      current_item.add_child link
      current_item.add_child XMLFeed::XMLNode.new(
        'itunes:image',
        propperties: { href: "#{@config['url']}#{episode['img']}" }
      )
      description_attr = XMLFeed::XMLNode.new 'description'
      description_attr.add_child(XMLFeed::XMLNode.new('cdata', cdata: true, content: description))
      current_item.add_child description_attr
      current_item.add_child(
        XMLFeed::XMLNode.new(
          'enclosure',
          propperties: {
            length: episode_bytes_length(episode['url']),
            type: 'audio/mpeg',
            url: "#{@config['url']}#{episode['url']}"
          }
        )
      )
      current_item.add_child XMLFeed::XMLNode.new('itunes:duration', content: episode_duration(episode['url']))
      current_item.add_child XMLFeed::XMLNode.new('itunes:explic', content: true)
      current_item.add_child XMLFeed::XMLNode.new(
        'itunes:keywords',
        content: @config['podcast']['keywords']
      )
      subtitle_attr = XMLFeed::XMLNode.new('itunes:subtitle')
      subtitle_attr.add_child(XMLFeed::XMLNode.new('cdata', content: subtitle, cdata: true))
      current_item.add_child subtitle_attr
      current_item.add_child XMLFeed::XMLNode.new('itunes:episodeType', content: 'full')
      episode_items << current_item
    rescue StandardError => e
      puts "Failed to generate item for #{episode['nome']}: #{e}"
    end
    episode_items
  end

  def format_description(description, details: '', indent_level: 0)
    indentation = "\t" * indent_level
    description = "#{description}\n#{indentation}#{details}".gsub '</br>', "\n#{indentation}"
    description.gsub! '<p>', ''
    description.gsub! '</p>', "\n#{indentation}"
    description.gsub! '<ul>', ''
    description.gsub! '<li>', "\n#{indentation} + "
    description.gsub! '</li>', ''
    description.gsub! '</ul>', "\n#{indentation}"

    # strip rest of html tags (a tags are allowed)
    description.gsub!(%r{<[^a][^a]/?[^>]+>}, '')
    description.strip
  end

  def episode_bytes_length(episode_path)
    File.new("#{Dir.getwd}#{episode_path}").size
  end

  def episode_duration(episode_path)
    raise 'FFMPEG not found. ffmpeg is needed to fech episode length' unless which('ffmpeg')

    cmd = "ffmpeg -i #{Dir.getwd}#{episode_path} 2>&1 | grep 'Duration' | cut -d ' ' -f 4 | sed s/\.[0-9]*,//"
    `#{cmd}`.strip!
  end

  def which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each do |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return exe if File.executable?(exe) && !File.directory?(exe)
      end
    end
    nil
  end

  def load_episode_list
    episodes
    episodes_from_seasons
    @episode_list.sort_by! do |episode|
      DateTime.strptime(
        episode['pub_date'],
        @config['podcast']['datetime_format_string']
      )
    end
  end

  def episodes
    episode_data = @config['podcast']['episode_data']
    puts 'No episodes found' && return if episode_data.nil?

    episode_data.each do |file|
      puts "No data found for #{file}" && next unless @data[file]

      @episode_list += @data[file]
    end
  end

  def episodes_from_seasons
    season_data = @config['podcast']['season_data']
    puts 'No seasons found' && return if season_data.nil?

    episode_list_name = @config['podcast']['season_episode_list_attribute']
    season_data.each do |file|
      puts "No data found for #{file}" && next unless @data[file]

      @data[file].each do |season|
        @episode_list += season[episode_list_name]
      end
    end
  end
end

module XMLFeed
  class Feed
    attr_accessor :nodes

    def initialize(nodes = [])
      @nodes = nodes
    end

    def header
      "<?xml version='1.0' encoding='UTF-8'?>\n<rss version='2.0' xmlns:atom='http://www.w3.org/2005/Atom'"\
      "xmlns:cc='http://web.resource.org/cc/' xmlns:itunes='http://www.itunes.com/dtds/podcast-1.0.dtd'"\
      "xmlns:media='http://search.yahoo.com/mrss/' xmlns:content='http://purl.org/rss/1.0/modules/content/' xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'>\n"
    end

    def footer
      "</rss>\n"
    end

    def to_s
      '' unless @nodes

      nodes_string = @nodes.reduce('') do |prev, node|
        "#{prev}#{node.to_s(1)}"
      end

      "#{header}#{nodes_string}#{footer}"
    end
  end

  class XMLNode
    attr_reader :children, :propperties

    def initialize(tag_name, content: nil, cdata: false, propperties: {})
      @tag_name = tag_name
      @content = content
      @cdata = cdata
      @propperties = propperties
      @children = []
    end

    def parent?
      !@children.empty?
    end

    def set_propperty(name, value)
      @propperties[name] = value
    end

    def add_child(child)
      @children << child
    end

    def add_children(children)
      raise TypeError 'Children must be an Array of nodes' unless children.is_a? Array

      @children += children
    end

    def open_tag
      if @cdata
        '<![CDATA['
      elsif @propperties.empty?
        "<#{@tag_name}>"
      else
        prop_string = @propperties.reduce('') { |prev, values| "#{prev} #{values[0]}='#{values[1]}'" }
        "<#{@tag_name} #{prop_string.strip}#{@content ? '' : '/'}>"
      end
    end

    def to_s(indent_level = 1)
      result_str = "#{"\t" * indent_level}#{open_tag}"
      if parent?
        result_str += "\n"
        @children.each { |child| result_str += child.to_s(indent_level + 1) }
        result_str += "#{"\t" * indent_level}</#{@tag_name}>"
      elsif @propperties.empty?
        result_str += "#{@content}#{@cdata ? ']]>' : "</#{@tag_name}>"}"
      end
      "#{result_str}\n"
    end
  end
end

f = FeedGenerator.new '_config.yml', '_data'
f.generate
