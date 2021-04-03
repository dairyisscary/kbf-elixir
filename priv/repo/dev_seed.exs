# Script for populating the database. You can run it as:
#     mix run priv/repo/seeds.exs
#
now = Date.utc_today()

Kbf.Repo.insert!(
  %Kbf.Transaction{
    when: now,
    description: "Amazon",
    amount: -20.20
  }
)

Kbf.Repo.insert!(
  %Kbf.Transaction{
    when: Date.add(now, -58),
    description: "Amazon",
    amount: -10.20
  }
)

Kbf.Repo.insert!(
  %Kbf.Transaction{
    when: Date.add(now, -10),
    description: "Dan - GS3",
    amount: -2037.0
  }
)

Kbf.Repo.insert!(
  %Kbf.Transaction{
    description: "UNKNOWN",
    amount: -134.20
  }
)

Kbf.Repo.insert!(
  %Kbf.Transaction{
    when: Date.add(now, 8),
    description: "Coffee Beans",
    amount: -76.99
  }
)

Kbf.Repo.insert!(
  %Kbf.Transaction{
    when: Date.add(now, -4),
    description: "Government Check",
    amount: 1300.0
  }
)
