directory "/usr/local/bin" do
  owner WS_USER
  recursive true
end

execute "your current user owns /usr/local" do
  command "chown -R #{WS_USER} /usr/local"
end

homebrew_git_revision_hash  = version_string_for("homebrew")

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
end

ruby_block "Check that homebrew is running & working" do
  block do
    `brew --version`
    if $? != 0
      raise "Couldn't find brew"
    end
  end
end