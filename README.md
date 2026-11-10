# aws-multi-account-guardrails

## The problem
A growing Australian health provider is adding AWS accounts for each team.
Participant data must stay in Australia, nobody should be able to switch off
audit logs, and engineers keep getting full admin rights.

This project sets up guardrails across every account using AWS Organizations
and Terraform.

## Phases
- [ ] Phase 1 — OUs and SCPs (Australia-only Regions, protect CloudTrail)
- [ ] Phase 2 — Organisation-wide CloudTrail into a locked log bucket
- [ ] Phase 3 — IAM Identity Center with permission sets
- [ ] Phase 4 — GuardDuty across all accounts