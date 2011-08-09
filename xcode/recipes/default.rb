ruby_block "Check that xcode is installed" do
  block do
    `gcc --version`
    if $? != 0
      raise <<-XCODEMSG
Sadly, you need to install XCode before installing other Diaspora dependencies. :(
You can get it from your OSX install DVD, download it from Apple's developer site, or if you're really cool,
download it for free from the Apple App Store.
XCODEMSG
    end
  end
end