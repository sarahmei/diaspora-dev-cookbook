WS_USER = ENV['SUDO_USER'].strip
WS_HOME = ENV['HOME']

rvm_git_revision_hash  = "019d77a93662a4a6c56e46416776e92ca9a42d58"

::RVM_HOME = "#{WS_HOME}/.rvm"
::RVM_COMMAND = "#{::RVM_HOME}/bin/rvm"

if (`which rvm`.empty?)
  recursive_directories [RVM_HOME, 'src', 'rvm'] do
    owner WS_USER
    recursive true
  end

  execute "download rvm" do
    command "curl -Lsf http://github.com/wayneeseguin/rvm/tarball/#{rvm_git_revision_hash} | tar xvz -C#{RVM_HOME}/src/rvm --strip 1"
    user WS_USER
  end

  execute "install rvm" do
    cwd "#{RVM_HOME}/src/rvm"
    command "./install"
    user WS_USER
  end

  bash_profile_include("rvm")

  execute "check rvm" do
    command "#{RVM_COMMAND} --version | grep Wayne"
    user WS_USER
  end

  execute "HACK the rvm openssl install script.  ./Configure was failing with 'target already defined'.  we've filed a bug about this" do
    command "perl -pi -e 's/os\\/compiler darwin/darwin/g' #{::RVM_HOME}/scripts/package"
  end

  %w{readline autoconf openssl zlib}.each do |rvm_package|
    execute "install rvm package: #{rvm_package}" do
      command "#{::RVM_COMMAND} package install #{rvm_package}"
      user WS_USER
    end
  end
end

ruby_version = "ree-1.8.7-2011.03"

unless File.exists?("#{::RVM_HOME}/bin/#{ruby_version}")

  execute "clean out the archive and src directories each time.  bad downloads cause problems with rvm" do
    command "rm -rf #{::RVM_HOME}/archives/*; rm -rf #{::RVM_HOME}/src/*"
    user WS_USER
  end

  install_cmd = "#{RVM_COMMAND} install #{ruby_version}"

  #this fixes an rvm problem with openssl when installing an mri version
  install_cmd << " -C --with-openssl-dir=#{::RVM_HOME}/usr" if ruby_version =~ /^ruby-/

  #| (! grep 'error') : if we see rvm errors in stderr, fail
  #this is due to an rvm bug (we've notified the author).  as soon as curl error cause rvm to exit nonzero,
  #we can get rid of this
  install_cmd << " 2>&1 | (! grep error)"

  execute "installing #{ruby_version} with RVM: #{install_cmd}" do
    command install_cmd
    user WS_USER
  end

  execute "check #{ruby_version}" do
    command "#{RVM_COMMAND} list | grep #{ruby_version}"
    user WS_USER
  end
end
