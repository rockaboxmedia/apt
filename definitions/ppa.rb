# borrowed from: https://github.com/sometimesfood/chef-apt-repo
# and adapted to fit with the opscode apt cookbook
# (untested)

define :ppa,
    :key_id => nil,
    :distribution => nil,
    :source_packages => false,
    :description => nil do

  # ppa name should have the form "user/archive"
  unless params[:name].count('/') == 1
    raise "Invalid PPA name"
  end

  # also accept Launchpad-style ppa names
  ppa = params[:name].gsub(/^ppa:/, '')
  user, archive = ppa.split('/')
  key_id = params[:key_id]

  description = params[:description]
  description = description ? "PPA: #{description}" : "ppa:#{ppa}"
  distribution = params[:distribution]
  source_packages = params[:source_packages]

  unless key_id
    # use the Launchpad API to get the correct archive signing key id
    require 'open-uri'
    base_url = 'https://api.launchpad.net/1.0'
    archive_url = "#{base_url}/~#{user}/+archive/#{archive}"
    key_fingerprint_url = "#{archive_url}/signing_key_fingerprint"
    key_id_long = open(key_fingerprint_url).read.tr('"', '')
    key_id = key_id_long[-8..-1]
  end

  # let apt_repository do the heavy lifting
  apt_repository "#{user}_#{archive}.ppa" do
    uri "http://ppa.launchpad.net/#{ppa}/ubuntu"
    distribution distribution
    components ["main"]
    keyserver "keyserver.ubuntu.com"
    key key_id
    deb_src source_packages
  end
end