define :rvm_ruby, :action => :install do
  #convert short string to full string
  short_version = params[:version] || params[:name]
  version = %x(rvm strings #{short_version}).chomp
  
  #search wether specified ruby is installed
  installed = %x(rvm list strings).split("\n").include?(version)

  #INSTALL
  if params[:action] == :install
    execute "rvm install #{version}" do
      only_if { version && !installed }
    end
  #REMOVE/PURGE
  elsif params[:action] == :remove || params[:action] == :purge
    execute "rvm #{params[:action]} #{version}" do
      only_if { version && installed }
    end
  end
end
