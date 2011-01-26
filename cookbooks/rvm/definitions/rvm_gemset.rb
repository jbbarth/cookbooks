define :rvm_gemset, :action => :create do
  ruby_gemset = params[:gemset_name] || params[:name]

  raise "Bad gemset format ! Should be <ruby>@<gemset_name>" unless ruby_gemset.include?("@")

  ruby, gemset = ruby_gemset.split("@")

  #installled?
  installed = %x(rvm use #{ruby}@#{gemset} 2>&1 | grep error >/dev/null; echo $?).chomp == "1"

  #INSTALL
  if params[:action] == :create
    bash "create-gemset-#{ruby}@#{gemset}" do
      code <<-EOH
        rvm use #{ruby}@#{gemset} --create
      EOH
      not_if { installed }
    end
  #DELETE
  elsif params[:action] == :delete
    bash "delete-gemset-#{ruby}@#{gemset}" do
      code <<-EOH
        source /usr/local/rvm/scripts/rvm
        rvm use #{ruby}
        echo "yes"|rvm gemset delete #{gemset}
      EOH
      only_if { installed }
    end
  end
end
