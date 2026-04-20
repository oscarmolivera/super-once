ActsAsTenant.configure do |config|
  # Raise an error if a query is made without a tenant set.
  # This catches bugs at dev time rather than leaking cross-tenant data.
  config.require_tenant = true
end
