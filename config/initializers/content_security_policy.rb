# Define an application-wide content security policy.
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    policy.script_src      :self, :https, :unsafe_inline, :unsafe_eval, "https://cdn.jsdelivr.net", "https://*.clerk.accounts.dev", "https://*.clerk.com"
    policy.script_src_elem :self, :https, :unsafe_inline, :unsafe_eval, "https://cdn.jsdelivr.net", "https://*.clerk.accounts.dev", "https://*.clerk.com"
    policy.style_src       :self, :https, :unsafe_inline
    policy.connect_src     :self, :https, "https://*.clerk.accounts.dev", "https://*.clerk.com", "wss://*.clerk.accounts.dev"
    policy.frame_src       :self, :https, "https://*.clerk.accounts.dev", "https://*.clerk.com"
  end

  # Generate session nonces for permitted importmaps and inline scripts
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src script-src-elem style-src]
  config.content_security_policy_report_only = true
end
