output "budget_id" {
  value = aws_budgets_budget.monthly_spending_budget.id
}

output "budget_name" {
  value = aws_budgets_budget.monthly_spending_budget.name
}
