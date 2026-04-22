# SuperOnce seed data — development
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

# ── Academy 1: Galicia Soccer Academy ───────────────────────────
academy = Academy.find_or_create_by!(slug: "galicia") do |a|
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
  Membership.find_or_create_by!(academy: academy, user: user) { |m| m.role = attrs[:role] }
end

ActsAsTenant.with_tenant(academy) do

  # ── Employees ────────────────────────────────────────────────
  head_coach = Employee.find_or_create_by!(academy: academy, email: "coach.main@galicia.com") do |e|
    e.full_name     = "Roberto Núñez"
    e.employee_type = :coach
    e.status        = :active
    e.hire_date     = 2.years.ago.to_date
    e.base_salary   = 1800
    e.phone         = "+34 600 111 222"
  end

  asst_coach = Employee.find_or_create_by!(academy: academy, email: "asst@galicia.com") do |e|
    e.full_name     = "Laura Díaz"
    e.employee_type = :assistant_coach
    e.status        = :active
    e.hire_date     = 1.year.ago.to_date
    e.base_salary   = 1200
  end

  staff = Employee.find_or_create_by!(academy: academy, email: "staff@galicia.com") do |e|
    e.full_name     = "Pedro Vázquez"
    e.employee_type = :staff
    e.status        = :active
    e.hire_date     = 6.months.ago.to_date
    e.base_salary   = 1000
  end

  puts "  Employees: #{Employee.where(academy: academy).count}"

  # ── Salaries — last 2 months ─────────────────────────────────
  [academy].each do
    [head_coach, asst_coach, staff].each do |emp|
      [-1, 0].each do |offset|
        date = Date.current >> offset
        Salary.find_or_create_by!(academy: academy, employee: emp, month: date.month, year: date.year) do |s|
          s.amount  = emp.base_salary
          s.status  = offset == -1 ? :paid : :pending
          s.paid_on = offset == -1 ? (date.end_of_month - 2.days) : nil
        end
      end
    end
  end

  puts "  Salaries: #{Salary.where(academy: academy).count}"

  # ── Income / Expenses ────────────────────────────────────────
  ledger_entries = [
    { kind: :income,  amount: 3200, description: "Monthly player fees — U12",     category: :player_fees,  recorded_on: 5.days.ago.to_date  },
    { kind: :income,  amount: 2800, description: "Monthly player fees — U14",     category: :player_fees,  recorded_on: 5.days.ago.to_date  },
    { kind: :income,  amount:  500, description: "Kit sponsorship — SportsBrand", category: :sponsorship,  recorded_on: 10.days.ago.to_date },
    { kind: :expense, amount:  800, description: "Pitch rental — Municipal field", category: :rent,        recorded_on: 3.days.ago.to_date  },
    { kind: :expense, amount:  150, description: "Electricity — changing rooms",   category: :utilities,   recorded_on: 8.days.ago.to_date  },
    { kind: :expense, amount:  320, description: "Footballs × 12",                 category: :equipment,   recorded_on: 12.days.ago.to_date },
    { kind: :income,  amount: 1500, description: "Monthly player fees — U16",     category: :player_fees,  recorded_on: 4.days.ago.to_date  },
    { kind: :expense, amount:  200, description: "First aid supplies",             category: :equipment,   recorded_on: 15.days.ago.to_date },
  ]

  ledger_entries.each do |attrs|
    IncomeExpense.find_or_create_by!(
      academy: academy, description: attrs[:description]
    ) do |e|
      e.kind        = attrs[:kind]
      e.amount      = attrs[:amount]
      e.category    = attrs[:category]
      e.recorded_on = attrs[:recorded_on]
    end
  end

  puts "  Ledger entries: #{IncomeExpense.where(academy: academy).count}"

  # ── Player payments ──────────────────────────────────────────
  [
    { player_name: "Alejandro Pérez",  amount: 80, status: :paid,    paid_on: 3.days.ago.to_date },
    { player_name: "Diego Rodríguez",  amount: 80, status: :paid,    paid_on: 5.days.ago.to_date },
    { player_name: "Lucía Martínez",   amount: 80, status: :pending, paid_on: nil                },
    { player_name: "Pablo González",   amount: 80, status: :overdue, paid_on: nil                },
    { player_name: "Sara Fernández",   amount: 80, status: :pending, paid_on: nil                },
  ].each do |attrs|
    PlayerPayment.find_or_create_by!(academy: academy, player_name: attrs[:player_name],
                                     month: Date.current.month, year: Date.current.year) do |p|
      p.amount  = attrs[:amount]
      p.due_on  = Date.current.beginning_of_month + 5.days
      p.status  = attrs[:status]
      p.paid_on = attrs[:paid_on]
    end
  end

  puts "  Player payments: #{PlayerPayment.where(academy: academy).count}"

  # ── Inventory ────────────────────────────────────────────────
  [
    { name: "Match footballs",      category: :equipment, condition: :good,     quantity: 12, unit_value: 35,  location: "Equipment room" },
    { name: "Training bibs",        category: :apparel,   condition: :fair,     quantity: 24, unit_value:  5,  location: "Equipment room" },
    { name: "Corner flags",         category: :equipment, condition: :good,     quantity:  8, unit_value: 15,  location: "Equipment room" },
    { name: "First aid kit",        category: :medical,   condition: :new_item, quantity:  2, unit_value: 45,  location: "Medical room"   },
    { name: "Training cones",       category: :equipment, condition: :good,     quantity: 50, unit_value:  1,  location: "Equipment room" },
    { name: "Goalkeeper gloves",    category: :apparel,   condition: :good,     quantity:  3, unit_value: 25,  location: "Equipment room" },
  ].each do |attrs|
    InventoryItem.find_or_create_by!(academy: academy, name: attrs[:name]) do |i|
      i.category   = attrs[:category]
      i.condition  = attrs[:condition]
      i.quantity   = attrs[:quantity]
      i.unit_value = attrs[:unit_value]
      i.location   = attrs[:location]
    end
  end

  puts "  Inventory items: #{InventoryItem.where(academy: academy).count}"

  # ── Tax / permits ────────────────────────────────────────────
  [
    { name: "Municipal operating permit", document_type: :permit,    status: :active,          expires_on: 8.months.from_now.to_date,  reference_number: "PERM-2024-001", issuing_authority: "Ourense City Council" },
    { name: "Public liability insurance", document_type: :insurance, status: :active,          expires_on: 3.months.from_now.to_date,  reference_number: "INS-2024-887",  issuing_authority: "Seguros Galicia"       },
    { name: "VAT registration",           document_type: :tax,       status: :active,          expires_on: nil,                        reference_number: "ESB12345678",   issuing_authority: "AEAT"                  },
    { name: "Sports facility license",    document_type: :license,   status: :pending_renewal, expires_on: 15.days.from_now.to_date,   reference_number: "LIC-2023-044",  issuing_authority: "Xunta de Galicia"      },
  ].each do |attrs|
    TaxPermit.find_or_create_by!(academy: academy, name: attrs[:name]) do |t|
      t.document_type      = attrs[:document_type]
      t.status             = attrs[:status]
      t.expires_on         = attrs[:expires_on]
      t.reference_number   = attrs[:reference_number]
      t.issuing_authority  = attrs[:issuing_authority]
      t.issued_on          = 1.year.ago.to_date
    end
  end

  puts "  Tax permits: #{TaxPermit.where(academy: academy).count}"
end

puts "\n  galicia.lvh.me:3000"
puts "  owner@galicia.com / password123  (owner)"
puts "  admin@galicia.com / password123  (admin)"
puts "  coach@galicia.com / password123  (member)"

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

puts "\n  porto.lvh.me:3000"
puts "  owner@porto.com / password123  (owner)"
puts "\nSuperadmin: admin.lvh.me:3000 — admin@nubbe.net / password123"
puts "\nDone."
