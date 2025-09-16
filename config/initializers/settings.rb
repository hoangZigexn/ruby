class Settings < Settingslogic
  source Rails.root.join("config", "settings", "#{Rails.env}.yml")
end
