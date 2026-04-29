# Budget and Alerts Setup Guide

This guide provides step-by-step instructions for creating the budget and action group required for screenshots 12-14.

---

## Prerequisites

- Logged into Azure Portal: https://portal.azure.com
- Have appropriate permissions on the subscription

---

## Step 1: Create Action Group (for Email Alerts)

### Portal Method (Recommended)

1. **Navigate to Monitor:**
   - Azure Portal → Search "Monitor" → Click "Monitor"

2. **Open Action Groups:**
   - Left sidebar → "Alerts" → "Action groups"

3. **Create New Action Group:**
   - Click "+ Create" button

4. **Basic Information:**
   - **Subscription:** Select your subscription
   - **Resource Group:** Select `rg-shared-vault` (or create new)
   - **Region:** Global
   - **Action Group Name:** `financeteam`
   - **Display Name:** `Finance Team`
   - Click "Next: Notifications"

5. **Configure Notifications:**
   - **Notification Type:** Select "Email/SMS message/Push/Voice"
   - **Name:** `Finance Team Email`
   - Check "Email" checkbox
   - **Email:** `financeteam@example.com`
   - Click "OK"
   - Click "Next: Actions" (leave empty)
   - Click "Next: Tags" (leave empty)

6. **Review and Create:**
   - Click "Review + create"
   - Click "Create"

7. **Verify:**
   - Action group "financeteam" should now appear in the list
   - **Take Screenshot 13** of this action group

### CLI Method (Alternative)

```bash
# Login to Azure CLI (if not already)
az login

# Create action group
az monitor action-group create \
    --name 'financeteam' \
    --short-name 'finteam' \
    --resource-group 'rg-shared-vault' \
    --action email finance financeteam@example.com
```

---

## Step 2: Create Budget with Alerts

### Portal Method (Recommended)

1. **Navigate to Cost Management:**
   - Azure Portal → Search "Cost Management" → Click "Cost Management + Billing"

2. **Open Budgets:**
   - In the left sidebar under "Cost Management" → Click "Budgets"
   - If prompted, select your subscription scope

3. **Create New Budget:**
   - Click "+ Add" or "+ Create" button

4. **Budget Details:**
   - **Scope:** Verify your subscription is selected
   - Click "Next" or continue

5. **Set Budget Amount:**
   - **Name:** `targetspend`
   - **Reset Period:** `Monthly`
   - **Creation Date:** Select today's date
   - **Expiration Date:** Select a future date (e.g., 1 year from now)
   - **Amount:** `250`
   - Click "Next"

6. **Set Alert Conditions - First Alert (80%):**
   - Click "+ Add alert condition"
   - **Alert Conditions:**
     - **Type:** `Actual`
     - **% of budget:** `80`
   - **Alert Recipients:**
     - **Action Groups:** Click "Select" and choose `financeteam`
     - **Email Recipients:** (Optional) Add additional emails
     - **Language:** English
   - Click "Save" or "Add"

7. **Set Alert Conditions - Second Alert (100%):**
   - Click "+ Add alert condition" again
   - **Alert Conditions:**
     - **Type:** `Actual`
     - **% of budget:** `100`
   - **Alert Recipients:**
     - **Action Groups:** Click "Select" and choose `financeteam`
     - **Email Recipients:** (Optional) Add additional emails
     - **Language:** English
   - Click "Save" or "Add"

8. **Review and Create:**
   - Review all settings
   - Click "Create"

9. **Verify Budget:**
   - Navigate back to Cost Management → Budgets
   - You should see "targetspend" budget
   - **Take Screenshot 12** of the budget configuration
   - Click on the budget to see alert conditions
   - **Take Screenshot 14** of the alert rules showing both 80% and 100% thresholds

### CLI Method (Alternative)

```bash
# Get subscription ID
SUB_ID=$(az account show --query id -o tsv)

# Get action group resource ID
ACTION_GROUP_ID=$(az monitor action-group show \
    --name 'financeteam' \
    --resource-group 'rg-shared-vault' \
    --query id -o tsv)

# Create budget with alerts
az consumption budget create \
    --budget-name 'targetspend' \
    --amount 250 \
    --time-grain Monthly \
    --time-period start-date=$(date -u +"%Y-%m-01T00:00:00Z") end-date="2027-12-31T23:59:59Z" \
    --category Cost \
    --notifications '{
        "Actual_GreaterThan_80_Percent": {
            "enabled": true,
            "operator": "GreaterThan",
            "threshold": 80,
            "contactEmails": [],
            "contactRoles": [],
            "thresholdType": "Actual",
            "contactGroups": ["'$ACTION_GROUP_ID'"]
        },
        "Actual_GreaterThan_100_Percent": {
            "enabled": true,
            "operator": "GreaterThan",
            "threshold": 100,
            "contactEmails": [],
            "contactRoles": [],
            "thresholdType": "Actual",
            "contactGroups": ["'$ACTION_GROUP_ID'"]
        }
    }'
```

---

## Step 3: Capture Screenshots

### Screenshot 12: Budget Configuration
1. Navigate to: Cost Management + Billing → Budgets
2. Click on "targetspend" budget
3. Ensure visible:
   - Budget name: targetspend
   - Amount: $250
   - Period: Monthly
   - Current status/progress bar
4. **Capture screenshot:** `screenshot-12-budget-configuration.png`

### Screenshot 13: Action Group
1. Navigate to: Monitor → Alerts → Action groups
2. Click on "financeteam" action group
3. Ensure visible:
   - Action group name: financeteam
   - Notifications section showing email: financeteam@example.com
   - Notification type: Email/SMS/Push/Voice
4. **Capture screenshot:** `screenshot-13-action-group.png`

### Screenshot 14: Alert Rules
1. Navigate to: Cost Management + Billing → Budgets → targetspend
2. Scroll to "Alert conditions" section or click "Alert conditions" tab
3. Ensure visible:
   - Alert 1: 80% of budget (Actual cost)
   - Alert 2: 100% of budget (Actual cost)
   - Both alerts show "financeteam" action group
   - Both alerts are enabled
4. **Capture screenshot:** `screenshot-14-alert-rules.png`

**Alternative for Screenshot 14:**
- If the budget details page doesn't clearly show the alerts, you can also screenshot the budget creation/edit page where you configured the alerts

---

## Verification Commands

After creating the budget and action group, verify they exist:

```powershell
# Check action group (requires Azure CLI)
az monitor action-group list --query "[?name=='financeteam']" -o table

# Check budget
az consumption budget list --query "[?name=='targetspend']" -o table
```

---

## Troubleshooting

### Issue: Can't find "Budgets" in Cost Management
**Solution:** Make sure you've selected the subscription scope. Look for a scope selector at the top of the Cost Management page.

### Issue: Action group doesn't appear when creating budget alerts
**Solution:**
1. Make sure action group is created in the same subscription
2. Refresh the page
3. Try typing the action group name instead of using the picker

### Issue: Budget alerts not triggering
**Solution:**
- Alerts only trigger when actual costs reach the threshold
- For testing purposes, you can use "Forecasted" instead of "Actual" to see alerts sooner
- Email notifications may take a few minutes to arrive

### Issue: Can't create budget (permissions error)
**Solution:** You need "Cost Management Contributor" or "Contributor" role on the subscription

---

## Testing Your Budget Alerts

To test that alerts are working:

1. **Wait for actual costs:** Alerts trigger when costs reach thresholds
2. **Check alert history:** Monitor → Alerts → Alert History
3. **Verify email:** Check that financeteam@example.com would receive notifications (in production)

**Note:** In a lab environment with minimal spending, you may not see alerts trigger. This is expected and okay for the project.

---

## Summary

By the end of this guide, you should have:

- ✅ Action group "financeteam" created with email notification
- ✅ Budget "targetspend" created for $250/month
- ✅ Two alert conditions: 80% and 100% of budget
- ✅ Both alerts configured to use "financeteam" action group
- ✅ Screenshots 12, 13, and 14 captured

---

## Next Steps

After completing this setup:

1. Mark off screenshots 12-14 in your checklist
2. Verify all 14 screenshots are captured
3. Review `SCREENSHOT-CHECKLIST.md` to ensure nothing is missing
4. Prepare your final submission package

---

**Good luck!** 🚀

If you encounter any issues, refer to:
- `SCREENSHOT-CAPTURE-GUIDE.md` for general screenshot guidance
- `REVIEWER-FEEDBACK-RESOLUTION.md` for understanding what reviewers expect
- Azure documentation: https://docs.microsoft.com/azure
