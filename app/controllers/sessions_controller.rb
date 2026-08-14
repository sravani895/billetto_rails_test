class SessionsController < ApplicationController
  def destroy
    cookie_names = [ "__session", "__clerk_db_jwt", "__client_uat", "__dev_session", "__refresh_token" ]
    domains = [ nil, "localhost", "127.0.0.1", request.host, ".#{request.host}" ]

    cookie_names.each do |name|
      domains.each do |domain_name|
        if domain_name
          cookies.delete(name, domain: domain_name, path: "/")
        else
          cookies.delete(name, path: "/")
        end
      end
    end

    session.clear if respond_to?(:session)
    redirect_to root_path, notice: "Signed out successfully", status: :see_other
  end
end
