# SuperOnce seed data — development + staging
# Run: rails db:seed
# Reset + reseed: rails db:seed:replant

puts "Seeding SuperOnce..."

# ── Superadmin ──────────────────────────────────────────────────
superadmin = User.find_or_create_by!(email_address: "admin@nubbe.net") do |u|
  u.password   = "password123"
  u.full_name  = "Super Admin"
  u.superadmin = true
end
puts "  Superadmin: #{superadmin.email_address}"

# ── Academy 1: Galicia Soccer Academy ──────────────────────────
academy1 = Academy.find_or_create_by!(slug: "galicia") do |a|
  a.name          = "Galicia Soccer Academy"
  a.plan          = :starter
  a.status        = :active
  a.sport_type    = "soccer"
  a.description   = "The leading youth soccer academy in Galicia. Developing talent since 2010."
  a.city          = "Ourense"
  a.country       = "ES"
  a.phone         = "+34 988 000 000"
  a.primary_color = "#4f46e5"
end

[
  { email: "owner@galicia.com",  name: "Carlos García",  role: :owner  },
  { email: "admin@galicia.com",  name: "Ana López",      role: :admin  },
  { email: "coach@galicia.com",  name: "Marcos Silva",   role: :member },
].each do |attrs|
  user = User.find_or_create_by!(email_address: attrs[:email]) do |u|
    u.password  = "password123"
    u.full_name = attrs[:name]
  end
  Membership.find_or_create_by!(academy: academy1, user: user) { |m| m.role = attrs[:role] }
end

puts "  Academy: #{academy1.name}"
puts "    galicia.lvh.me:3000"
puts "    owner@galicia.com / password123  (owner)"
puts "    admin@galicia.com / password123  (admin)"
puts "    coach@galicia.com / password123  (member)"

# ── Academy 2: Porto Futsal Club ────────────────────────────────
academy2 = Academy.find_or_create_by!(slug: "porto") do |a|
  a.name          = "Porto Futsal Club"
  a.plan          = :free
  a.status        = :trial
  a.sport_type    = "futsal"
  a.description   = "Elite futsal training for players aged 6-18."
  a.city          = "Porto"
  a.country       = "PT"
  a.primary_color = "#0f766e"
end

owner2 = User.find_or_create_by!(email_address: "owner@porto.com") do |u|
  u.password  = "password123"
  u.full_name = "João Ferreira"
end
Membership.find_or_create_by!(academy: academy2, user: owner2) { |m| m.role = :owner }

puts "  Academy: #{academy2.name}"
puts "    porto.lvh.me:3000"
puts "    owner@porto.com / password123  (owner)"

puts "\nSuperadmin panel: admin.lvh.me:3000"
puts "Login: admin@nubbe.net / password123"
puts "\nDone."
