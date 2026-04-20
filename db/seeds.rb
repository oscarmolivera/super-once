# ─────────────────────────────────────────────────────────────────
# SuperOnce seed data — development only
# Run with: rails db:seed
# Reset and reseed: rails db:seed:replant
# ─────────────────────────────────────────────────────────────────

puts "Seeding SuperOnce..."

# ── Superadmin ────────────────────────────────────────────────────
superadmin = User.find_or_create_by!(email_address: "admin@nubbe.net") do |u|
  u.password    = "S3cretP4zz"
  u.full_name   = "Oscar Olivera"
  u.superadmin  = true
end
puts "  Superadmin: #{superadmin.email_address}"

# ── Academy 1: Galicia Soccer Academy ────────────────────────────
academy1 = Academy.find_or_create_by!(slug: "galicia") do |a|
  a.name       = "Galicia Soccer Academy"
  a.plan       = :starter
  a.status     = :active
  a.sport_type = "soccer"
end

owner1 = User.find_or_create_by!(email_address: "owner@galicia.com") do |u|
  u.password  = "password123"
  u.full_name = "Carlos García"
end

Membership.find_or_create_by!(academy: academy1, user: owner1) do |m|
  m.role = :owner
end

admin1 = User.find_or_create_by!(email_address: "admin@galicia.com") do |u|
  u.password  = "password123"
  u.full_name = "Ana López"
end

Membership.find_or_create_by!(academy: academy1, user: admin1) do |m|
  m.role = :admin
end

coach1 = User.find_or_create_by!(email_address: "coach@galicia.com") do |u|
  u.password  = "password123"
  u.full_name = "Marcos Silva"
end

Membership.find_or_create_by!(academy: academy1, user: coach1) do |m|
  m.role = :member
end

puts "  Academy: #{academy1.name} (#{academy1.slug}.lvh.me:3000)"
puts "    owner@galicia.com / password123"
puts "    admin@galicia.com / password123"
puts "    coach@galicia.com / password123"

# ── Academy 2: Porto Futsal Club ──────────────────────────────────
academy2 = Academy.find_or_create_by!(slug: "porto") do |a|
  a.name       = "Porto Futsal Club"
  a.plan       = :free
  a.status     = :trial
  a.sport_type = "futsal"
end

owner2 = User.find_or_create_by!(email_address: "owner@porto.com") do |u|
  u.password  = "password123"
  u.full_name = "João Ferreira"
end

Membership.find_or_create_by!(academy: academy2, user: owner2) do |m|
  m.role = :owner
end

puts "  Academy: #{academy2.name} (#{academy2.slug}.lvh.me:3000)"
puts "    owner@porto.com / password123"

puts "\nDone. Access admin panel at: admin.lvh.me:3000"
puts "Superadmin login: admin@nubbe.net / S3cretP4zz"
