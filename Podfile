platform :ios, "8.0"

# Specifies which targets will link against the unnested pods
link_with 'Timber', 'TimberTests'

# TimberTests specific pods
target :TimberTests, :exclusive => true do
  pod 'TUDelorean', '0.9.0', :inhibit_warnings => true
end
