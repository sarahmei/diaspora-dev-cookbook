WS_USER = ENV['SUDO_USER'].strip

homebrew_git_revision_hash  = "2abfba1a91bfda3017d23a631ef237933e29c2f5"

if (`which brew`.empty?)
  git "/tmp/homebrew" do
    repository "https://github.com/mxcl/homebrew.git"
    revision homebrew_git_revision_hash
    destination "/tmp/homebrew"
    action :sync
    user WS_USER
  end

  execute "Copying homebrew's .git to /usr/local" do
    command "rsync -axSH /tmp/homebrew/ /usr/local/"
    user WS_USER
  end

  directory "/usr/local/Cellar" do
    owner WS_USER
    recursive true
  end

  directory "/usr/local/Library" do
    owner WS_USER
    recursive true
  end
end

ruby_block "Check that homebrew is running & working" do
  block do
    `brew --version`
    if $? != 0
      raise "Couldn't find brew"
    end
  end
end