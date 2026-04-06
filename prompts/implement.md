## Context
Study: specs/README.md

## Task
1. Read `specs/implementation-plans/active-plan.md`
2. Find FIRST unchecked `- [ ]` task
3. Implement ONLY that task

## Execution
1. Search specs/README.md for related code
2. Implement following specs/conventions/
3. Write tests / validation scripts
4. Run: `./test-wrapper.sh`

## On Success
1. Change task from `- [ ]` to `- [x]` in the plan
2. STOP

## On Failure  
1. Fix and retry (max 3 attempts)
2. If still failing, STOP and leave as `- [ ]`

## CRITICAL
- ONE task only
- Do NOT continue to next task
- Exit cleanly for fresh context
